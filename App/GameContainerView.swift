import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @State private var scene = GameScene.makeLevel1()

    var body: some View {
        SpriteView(scene: scene, debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
            .statusBarHidden()
    }
}
