import DragonCore
import Observation

/// 持有当前这一局的场景。restart 会换一个新场景，等于重置局内状态。
@MainActor
@Observable
final class GameSession {
    private(set) var scene: GameScene
    private(set) var summary: BattleSummary?

    init() {
        scene = GameScene.makeLevel1()
        attachFinishHandler()
    }

    func restart() {
        summary = nil
        scene = GameScene.makeLevel1()
        attachFinishHandler()
    }

    private func attachFinishHandler() {
        scene.onFinish = { [weak self] summary in
            self?.summary = summary
        }
    }
}
