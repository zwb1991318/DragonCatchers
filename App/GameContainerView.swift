import SpriteKit
import SwiftUI

/// 承载游戏场景；一关结束时在上面盖一层结算界面
struct GameContainerView: View {
    @State private var session = GameSession()

    var body: some View {
        ZStack {
            SpriteView(scene: session.scene, debugOptions: [.showsFPS, .showsNodeCount])
                .id(ObjectIdentifier(session.scene))
            if let summary = session.summary {
                ResultOverlay(summary: summary, onRestart: session.restart)
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }
}
