public enum BattleOutcome: Equatable, Sendable {
    case playing
    /// 已经胜利，船还在收尾打捞
    case victoryGrace(remaining: Double)
    case won
    case lost
}

/// 给画面层播放特效用的事件。实体的出现和消失由画面层对比状态自行处理，不走事件。
public enum BattleEvent: Equatable, Sendable {
    case arrowFired(EntityID)
    case dragonHit(EntityID)
    case dragonKilled(EntityID)
    case dragonAttacked(EntityID)
    case carcassLanded(EntityID)
    case carcassLost(EntityID)
    case carcassCollected(EntityID)
    case cargoUnloaded(income: Double)
    case outcomeChanged(BattleOutcome)
}

public struct BattleSummary: Equatable, Sendable {
    public var won: Bool
    public var income: Double
    public var dragonsKilled: Int
    public var dragonsCollected: Int
    public var dragonsLost: Int
}

/// 一关的全部局内状态和规则。纯逻辑，不依赖 SpriteKit：画面层每帧调用 step，再根据状态和事件来画。
/// 每关开始时新建一个 Battle，就等于重置了局内状态。
public struct Battle: Sendable {
    public let balance: BalanceConfig
    public let level: LevelConfig
    public internal(set) var bow: Bow
    public internal(set) var wallHP: Double
    public internal(set) var arrows: [Arrow] = []
    public internal(set) var dragons: [Dragon] = []
    public internal(set) var carcasses: [Carcass] = []
    public internal(set) var boat: Boat
    public internal(set) var spawner: WaveSpawner
    /// 本关已经卸货结算的收益
    public internal(set) var income: Double = 0
    public internal(set) var outcome: BattleOutcome = .playing
    public internal(set) var dragonsKilled = 0
    public internal(set) var dragonsCollected = 0
    public internal(set) var dragonsLost = 0
    var nextID = 1
    var rng: SeededRandom

    public init(balance: BalanceConfig, level: LevelConfig, seed: UInt64) {
        self.balance = balance
        self.level = level
        bow = Bow(config: balance.bow)
        wallHP = balance.wall.maxHP
        boat = Boat(x: balance.boat.dockX)
        spawner = WaveSpawner(level: level)
        rng = SeededRandom(seed: seed)
    }

    public var isPlaying: Bool { outcome == .playing }

    public var summary: BattleSummary {
        BattleSummary(
            won: outcome == .won,
            income: income,
            dragonsKilled: dragonsKilled,
            dragonsCollected: dragonsCollected,
            dragonsLost: dragonsLost
        )
    }

    // MARK: 输入

    @discardableResult
    public mutating func beginAim(at point: Vec2) -> Bool {
        guard isPlaying else { return false }
        return bow.begin(at: point)
    }

    public mutating func moveAim(to point: Vec2) {
        bow.move(to: point)
    }

    public mutating func cancelAim() {
        bow.cancel()
    }

    public mutating func endAim() -> [BattleEvent] {
        guard isPlaying, case .fired(let velocity) = bow.release() else {
            bow.cancel()
            return []
        }
        let origin = balance.bow.anchor
        let arrow = Arrow(id: makeID(), origin: origin, launchVelocity: velocity, position: origin, velocity: velocity)
        arrows.append(arrow)
        return [.arrowFired(arrow.id)]
    }

    /// 预瞄虚线上的点；没在拉弓，或者手指在取消圈内时为空
    public func aimPreview(pointCount: Int = 14, step: Double = 0.08) -> [Vec2] {
        guard let velocity = bow.aimVelocity else { return [] }
        return Trajectory.previewPoints(
            origin: balance.bow.anchor, velocity: velocity,
            gravity: balance.world.gravity, step: step, count: pointCount
        )
    }

    // MARK: 推进

    /// 推进一帧。调用方要保证 dt 不为负，并且单帧不要太长（画面层限制在 1/30 秒以内），
    /// 否则高速飞行的箭可能一帧就穿过龙而没有判定命中。
    public mutating func step(dt: Double) -> [BattleEvent] {
        var events: [BattleEvent] = []
        switch outcome {
        case .won, .lost:
            return []
        case .playing:
            bow.update(dt: dt)
            spawnDragons(dt: dt)
            moveDragons(dt: dt, events: &events)
            moveArrows(dt: dt, events: &events)
            moveCarcasses(dt: dt, events: &events)
            moveBoat(dt: dt, events: &events)
            if wallHP <= 0 {
                // 失败立即结束，河里和船上没卸货的都不算
                finish(.lost, events: &events)
            } else if spawner.isFinished && dragons.isEmpty {
                // 所有波次出完且龙全部死亡才算胜利；两波之间暂时没龙不算
                finish(.victoryGrace(remaining: balance.victoryGraceTime), events: &events)
            }
        case .victoryGrace(let remaining):
            moveArrows(dt: dt, events: &events)
            moveCarcasses(dt: dt, events: &events)
            moveBoat(dt: dt, events: &events)
            let left = remaining - dt
            let nothingLeft = carcasses.isEmpty && boat.cargo.isEmpty
            if left <= 0 || nothingLeft {
                finish(.won, events: &events)
            } else {
                outcome = .victoryGrace(remaining: left)
            }
        }
        return events
    }

    mutating func finish(_ newOutcome: BattleOutcome, events: inout [BattleEvent]) {
        outcome = newOutcome
        bow.cancel()
        events.append(.outcomeChanged(newOutcome))
    }

    mutating func makeID() -> EntityID {
        defer { nextID += 1 }
        return nextID
    }

    func dragonKind(_ dragon: Dragon) -> DragonKind {
        guard let kind = balance.dragons[dragon.kind] else {
            preconditionFailure("未知的龙种类：\(dragon.kind)")
        }
        return kind
    }
}
