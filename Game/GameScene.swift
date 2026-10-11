import DragonCore
import SpriteKit

final class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1)
        let title = SKLabelNode(fontNamed: "PingFangSC-Semibold")
        title.text = "捞龙小队"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(title)
    }
}
