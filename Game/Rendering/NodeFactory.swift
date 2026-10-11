import DragonCore
import SpriteKit

/// M1 的占位图形：全部用色块和简单形状，M4 再换成卡通素材。
@MainActor
enum NodeFactory {
    static func wall(_ wall: WallConfig) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: wall.frontX, height: wall.topY))
        node.fillColor = SKColor(white: 0.6, alpha: 1)
        node.strokeColor = SKColor(white: 0.35, alpha: 1)
        node.lineWidth = 3
        return node
    }

    static func river(_ river: RiverConfig, width: Double) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: river.surfaceY))
        node.fillColor = SKColor(red: 0.2, green: 0.45, blue: 0.85, alpha: 1)
        node.strokeColor = .clear
        return node
    }

    static func dock(_ boat: BoatConfig, river: RiverConfig) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: boat.dockX - 40, y: river.surfaceY - 4, width: 80, height: 8))
        node.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1)
        node.strokeColor = .clear
        return node
    }

    /// 弓箭手，外圈淡淡的圆表示可以起手拉弓的范围
    static func archer(_ bow: BowConfig) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(bow.anchor)
        let grabArea = SKShapeNode(circleOfRadius: bow.grabRadius)
        grabArea.fillColor = .clear
        grabArea.strokeColor = SKColor(white: 1, alpha: 0.3)
        grabArea.lineWidth = 2
        let body = SKShapeNode(circleOfRadius: 18)
        body.fillColor = .systemGreen
        body.strokeColor = SKColor(red: 0, green: 0.35, blue: 0, alpha: 1)
        body.lineWidth = 3
        node.addChild(grabArea)
        node.addChild(body)
        return node
    }

    static func dragon(hitRadius: Double) -> SKNode {
        let node = SKNode()
        let wing = SKShapeNode(path: triangle(width: hitRadius * 1.6, height: hitRadius))
        wing.fillColor = SKColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: 0, y: hitRadius * 0.4)
        let body = SKShapeNode(ellipseOf: CGSize(width: hitRadius * 2.2, height: hitRadius * 1.4))
        body.fillColor = .systemRed
        body.strokeColor = .black
        body.lineWidth = 2
        node.addChild(wing)
        node.addChild(body)
        return node
    }

    static func arrow() -> SKNode {
        let node = SKShapeNode(rectOf: CGSize(width: 28, height: 3))
        node.fillColor = SKColor(red: 0.35, green: 0.2, blue: 0.05, alpha: 1)
        node.strokeColor = .clear
        return node
    }

    /// 被击落的龙：颜色变暗，翻过来
    static func carcass(hitRadius: Double) -> SKNode {
        let node = SKShapeNode(ellipseOf: CGSize(width: hitRadius * 2.2, height: hitRadius * 1.2))
        node.fillColor = SKColor(red: 0.45, green: 0.1, blue: 0.1, alpha: 1)
        node.strokeColor = .black
        node.lineWidth = 2
        return node
    }

    static func boat() -> SKNode {
        let node = SKShapeNode(rectOf: CGSize(width: 56, height: 18), cornerRadius: 7)
        node.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
        node.strokeColor = SKColor(red: 0.3, green: 0.18, blue: 0.05, alpha: 1)
        node.lineWidth = 3
        return node
    }

    private static func triangle(width: Double, height: Double) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
}
