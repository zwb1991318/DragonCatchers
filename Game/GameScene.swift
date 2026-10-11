import DragonCore
import SpriteKit

/// 一关的画面层：每帧推进 Battle，再把局内状态画出来。规则都在 DragonCore 里，这里只负责显示和触摸。
final class GameScene: SKScene {
    /// 一关结束（胜利收尾完成或失败）时调用一次
    var onFinish: (@MainActor (BattleSummary) -> Void)?

    private var battle: Battle
    private var lastUpdateTime: TimeInterval?
    private var reportedFinish = false
    private var aimTouch: UITouch?

    private let wallNode: SKShapeNode
    private let archerNode: SKNode
    private let boatNode: SKNode
    private let hud: HUDNode
    private let aimPreview = AimPreviewNode()
    private let effectsLayer = SKNode()
    private let dragonLayer: EntityLayer<Dragon>
    private let arrowLayer: EntityLayer<Arrow>
    private let carcassLayer: EntityLayer<Carcass>

    init(battle: Battle) {
        self.battle = battle
        let balance = battle.balance
        let size = CGSize(width: balance.world.width, height: balance.world.height)
        let hitRadius: (String) -> Double = { balance.dragons[$0]?.hitRadius ?? 24 }

        wallNode = NodeFactory.wall(balance.wall)
        archerNode = NodeFactory.archer(balance.bow)
        boatNode = NodeFactory.boat()
        hud = HUDNode(sceneSize: size)
        dragonLayer = EntityLayer(
            id: \.id,
            make: { NodeFactory.dragon(hitRadius: hitRadius($0.kind)) },
            update: { dragon, node in node.position = CGPoint(dragon.position) }
        )
        arrowLayer = EntityLayer(
            id: \.id,
            make: { _ in NodeFactory.arrow() },
            update: { arrow, node in
                node.position = CGPoint(arrow.position)
                node.zRotation = atan2(arrow.velocity.y, arrow.velocity.x)
            }
        )
        carcassLayer = EntityLayer(
            id: \.id,
            make: { NodeFactory.carcass(hitRadius: hitRadius($0.kind)) },
            update: { carcass, node in node.position = CGPoint(carcass.position) }
        )
        super.init(size: size)
        scaleMode = .aspectFill
        backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("GameScene 只能用代码创建")
    }

    override func didMove(to view: SKView) {
        guard children.isEmpty else { return }
        let balance = battle.balance
        addChild(NodeFactory.river(balance.river, width: balance.world.width))
        addChild(wallNode)
        addChild(NodeFactory.dock(balance.boat, river: balance.river))
        addChild(archerNode)
        addChild(carcassLayer.root)
        boatNode.position = CGPoint(x: balance.boat.dockX, y: balance.river.floatY)
        addChild(boatNode)
        addChild(dragonLayer.root)
        addChild(arrowLayer.root)
        addChild(aimPreview)
        addChild(effectsLayer)
        addChild(hud)
        render()
    }

    override func update(_ currentTime: TimeInterval) {
        // 限制单帧最长 1/30 秒，避免切后台回来时一帧跳太远
        let dt = lastUpdateTime.map { min(currentTime - $0, 1.0 / 30) } ?? 0
        lastUpdateTime = currentTime
        let events = battle.step(dt: dt)
        play(events)
        render()
        reportFinishIfNeeded()
    }

    // MARK: 触摸

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 只有第一根落在弓箭手上的手指控制弓，其余手指一律忽略
        guard aimTouch == nil, let touch = touches.first else { return }
        if battle.beginAim(at: Vec2(touch.location(in: self))) {
            aimTouch = touch
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = aimTouch, touches.contains(touch) else { return }
        battle.moveAim(to: Vec2(touch.location(in: self)))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = aimTouch, touches.contains(touch) else { return }
        play(battle.endAim())
        aimTouch = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = aimTouch, touches.contains(touch) else { return }
        battle.cancelAim()
        aimTouch = nil
    }

    // MARK: 画面

    private func render() {
        let balance = battle.balance
        dragonLayer.sync(battle.dragons)
        arrowLayer.sync(battle.arrows)
        carcassLayer.sync(battle.carcasses)
        boatNode.position.x = battle.boat.x
        archerNode.alpha = battle.bow.isReady ? 1 : 0.6
        aimPreview.update(bow: battle.bow, points: battle.aimPreview())
        hud.update(
            wallHP: battle.wallHP, maxHP: balance.wall.maxHP, income: battle.income,
            wave: battle.spawner.waveIndex + 1, waveCount: battle.spawner.waveCount
        )
    }

    /// 播放特效。要在 render 之前调用，这样被打死的龙节点还没被删掉，事件里的 id 还能找到对应节点。
    private func play(_ events: [BattleEvent]) {
        let balance = battle.balance
        for event in events {
            switch event {
            case .dragonHit(let id):
                if let node = dragonLayer.node(for: id) {
                    Effects.flash(node)
                }
            case .dragonAttacked(let id):
                // 同一帧里喷火后又被射死的龙已不在 battle.dragons 里，所以从节点取位置
                if let node = dragonLayer.node(for: id) {
                    let target = CGPoint(x: balance.wall.frontX, y: min(node.position.y, balance.wall.topY - 10))
                    Effects.fireball(from: node.position, to: target, in: effectsLayer)
                }
                Effects.shake(wallNode, home: .zero)
            case .carcassLanded(let id):
                // 落水和被船捞起可能发生在同一帧，所以从节点取位置，找不到就跳过
                if let node = carcassLayer.node(for: id) {
                    Effects.splash(at: node.position, in: effectsLayer)
                }
            case .cargoUnloaded(let income):
                Effects.floatingText(
                    "+\(Int(income))",
                    at: CGPoint(x: balance.boat.dockX, y: balance.river.surfaceY + 30),
                    in: effectsLayer
                )
            case .arrowFired, .dragonKilled, .carcassLost, .carcassCollected, .outcomeChanged:
                break
            }
        }
    }

    private func reportFinishIfNeeded() {
        guard !reportedFinish, battle.outcome == .won || battle.outcome == .lost else { return }
        reportedFinish = true
        onFinish?(battle.summary)
    }
}

extension GameScene {
    /// 读取自带的数值和第 1 关配置，新建一局
    static func makeLevel1() -> GameScene {
        do {
            let balance = try ConfigLoader.bundled(BalanceConfig.self, named: "balance")
            let level = try ConfigLoader.bundled(LevelConfig.self, named: "level01")
            try ConfigLoader.validate(level: level, against: balance)
            return GameScene(battle: Battle(balance: balance, level: level, seed: .random(in: 0...UInt64.max)))
        } catch {
            fatalError("配置文件读取失败：\(error)")
        }
    }
}
