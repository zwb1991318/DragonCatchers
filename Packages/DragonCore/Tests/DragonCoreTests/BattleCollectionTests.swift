import Testing
@testable import DragonCore

/// 夹具：漂浮高度 60，水流 50，出口 1000；码头 x = 200，船速 150，载量 2，拾取半径 20；收益系数 2；收尾 5 秒
struct BattleCollectionTests {
    private func makeBattle(_ level: LevelConfig = Fixtures.idleLevel) -> Battle {
        Battle(balance: Fixtures.balance, level: level, seed: 1)
    }

    private func floating(_ id: EntityID, x: Double) -> Carcass {
        Carcass(id: id, kind: "normal", value: 10, position: Vec2(x, 60), phase: .floating)
    }

    /// 每次推进 0.1 秒，直到条件成立或达到步数上限；返回期间所有事件
    private func run(_ battle: inout Battle, maxSteps: Int = 200, until done: (Battle) -> Bool) -> [BattleEvent] {
        var events: [BattleEvent] = []
        for _ in 0..<maxSteps where !done(battle) {
            events += battle.step(dt: 0.1)
        }
        return events
    }

    @Test func approachMovesAtMostOneStep() {
        #expect(Battle.approach(0, toward: 10, maxStep: 3) == 3)
        #expect(Battle.approach(10, toward: 0, maxStep: 3) == 7)
        #expect(Battle.approach(9, toward: 10, maxStep: 3) == 10)
    }

    @Test func carcassFallsIntoTheRiverAndFloats() {
        var battle = makeBattle()
        battle.carcasses = [Carcass(id: 7, kind: "normal", value: 10, position: Vec2(500, 200), phase: .falling)]
        let events = run(&battle, maxSteps: 10) { _ in false }
        #expect(events.contains(.carcassLanded(7)))
        #expect(battle.carcasses[0].phase == .floating)
        #expect(battle.carcasses[0].position.y == 60)
    }

    @Test func carcassPastTheExitIsLost() {
        var battle = makeBattle()
        battle.carcasses = [floating(7, x: 990)]
        let events = battle.step(dt: 0.5)
        #expect(events.contains(.carcassLost(7)))
        #expect(battle.carcasses.isEmpty)
        #expect(battle.dragonsLost == 1)
    }

    @Test func boatCollectsAndUnloadsWithTheIncomeMultiplier() {
        var battle = makeBattle()
        battle.carcasses = [floating(7, x: 300)]
        let events = run(&battle) { $0.income > 0 }
        #expect(events.contains(.carcassCollected(7)))
        #expect(events.contains(.cargoUnloaded(income: 20)))
        #expect(battle.income == 20)
        #expect(battle.dragonsCollected == 1)
        #expect(battle.boat.x == 200)
        #expect(battle.boat.cargo.isEmpty)
    }

    @Test func fullBoatGoesHomeBeforeTakingMore() {
        var battle = makeBattle()
        battle.carcasses = [floating(1, x: 300), floating(2, x: 400), floating(3, x: 500)]
        let events = run(&battle) { $0.income > 0 }
        #expect(events.contains(.cargoUnloaded(income: 40)))
        #expect(battle.dragonsCollected == 2)
        #expect(battle.carcasses.count == 1)
    }

    @Test func boatKeepsItsTargetWhenABetterOneAppears() {
        var battle = makeBattle()
        battle.carcasses = [floating(1, x: 400)]
        _ = battle.step(dt: 0.1)
        #expect(battle.boat.mode == .chasing(1))
        battle.carcasses.append(floating(2, x: 700))
        _ = battle.step(dt: 0.1)
        #expect(battle.boat.mode == .chasing(1))
    }

    @Test func boatDropsATargetItCanNoLongerCatch() {
        var battle = makeBattle()
        battle.carcasses = [floating(1, x: 400)]
        _ = battle.step(dt: 0.1)
        battle.carcasses[0].position.x = 990
        _ = battle.step(dt: 0.1)
        #expect(battle.boat.mode != .chasing(1))
    }

    @Test func noVictoryBetweenWaves() {
        var battle = makeBattle(Fixtures.level([Fixtures.wave(count: 1), Fixtures.wave(delay: 1, count: 1)]))
        _ = battle.step(dt: 0.01)
        battle.dragons = []
        _ = battle.step(dt: 0.01)
        #expect(battle.outcome == .playing)
    }

    @Test func victoryGivesTheBoatTimeToFinishCollecting() {
        var battle = makeBattle(Fixtures.level([Fixtures.wave(count: 1)]))
        _ = battle.step(dt: 0.01)
        battle.dragons = []
        battle.carcasses = [floating(7, x: 300)]

        _ = battle.step(dt: 0.1)
        guard case .victoryGrace = battle.outcome else {
            Issue.record("应进入胜利收尾，实际是 \(battle.outcome)")
            return
        }
        let aimed = battle.beginAim(at: Vec2(100, 300))
        #expect(aimed == false)

        _ = run(&battle) { $0.outcome == .won }
        #expect(battle.outcome == .won)
        #expect(battle.income == 20)
        #expect(battle.summary.won)
    }

    @Test func graceTimeoutDropsUnloadedCargo() {
        var battle = makeBattle(Fixtures.level([]))
        battle.boat = Boat(x: 1000, cargo: [10], mode: .returning) // 回码头要 5.3 秒，比收尾的 5 秒长
        _ = run(&battle) { $0.outcome == .won }
        #expect(battle.outcome == .won)
        #expect(battle.income == 0)
        #expect(battle.boat.x > 200)
    }
}
