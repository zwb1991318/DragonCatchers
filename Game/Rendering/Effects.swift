import SpriteKit

/// 一次性的小特效，播放完就自动移除
@MainActor
enum Effects {
    static func fireball(from start: CGPoint, to end: CGPoint, in parent: SKNode) {
        let ball = SKShapeNode(circleOfRadius: 7)
        ball.fillColor = .systemOrange
        ball.strokeColor = .systemYellow
        ball.lineWidth = 2
        ball.position = start
        parent.addChild(ball)
        ball.run(.sequence([
            .move(to: end, duration: 0.3),
            .group([.scale(to: 2.2, duration: 0.12), .fadeOut(withDuration: 0.12)]),
            .removeFromParent(),
        ]))
    }

    static func flash(_ node: SKNode) {
        // 连续受击时先复位再重播，避免动作叠加
        node.removeAction(forKey: "flash")
        node.alpha = 1
        node.run(.sequence([.fadeAlpha(to: 0.3, duration: 0.05), .fadeAlpha(to: 1, duration: 0.1)]), withKey: "flash")
    }

    static func splash(at point: CGPoint, in parent: SKNode) {
        let ring = SKShapeNode(circleOfRadius: 10)
        ring.strokeColor = .white
        ring.lineWidth = 3
        ring.position = point
        parent.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 3, duration: 0.4), .fadeOut(withDuration: 0.4)]),
            .removeFromParent(),
        ]))
    }

    static func floatingText(_ text: String, at point: CGPoint, in parent: SKNode) {
        let label = SKLabelNode(fontNamed: "PingFangSC-Semibold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .systemYellow
        label.position = point
        parent.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 40, duration: 0.8), .fadeOut(withDuration: 0.8)]),
            .removeFromParent(),
        ]))
    }

    /// 左右抖一下，最后回到 home 位置；连续触发时先复位再重新抖
    static func shake(_ node: SKNode, home: CGPoint) {
        node.removeAction(forKey: "shake")
        node.position = home
        node.run(.sequence([
            .moveBy(x: -4, y: 0, duration: 0.03),
            .moveBy(x: 8, y: 0, duration: 0.06),
            .moveBy(x: -4, y: 0, duration: 0.03),
            .move(to: home, duration: 0),
        ]), withKey: "shake")
    }
}
