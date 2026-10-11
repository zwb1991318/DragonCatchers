import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 960, height: 440))
        scene.scaleMode = .aspectFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene, debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
            .statusBarHidden()
    }
}
