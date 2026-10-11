import DragonCore
import SpriteKit

/// 拉弓时显示：从按下点到手指的拉弓线，以及箭的预瞄虚线。
/// 拉弓线颜色：白色表示可以发射，橙色表示还在装填，灰色表示在取消圈内（松手会取消）。
@MainActor
final class AimPreviewNode: SKNode {
    private let pullLine = SKShapeNode()
    private var dots: [SKShapeNode] = []

    override init() {
        super.init()
        pullLine.lineWidth = 3
        addChild(pullLine)
        zPosition = 50
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("AimPreviewNode 只能用代码创建")
    }

    func update(bow: Bow, points: [Vec2]) {
        if let start = bow.start, let current = bow.current {
            let path = CGMutablePath()
            path.move(to: CGPoint(start))
            path.addLine(to: CGPoint(current))
            pullLine.path = path
            pullLine.strokeColor = bow.aimVelocity == nil ? .lightGray : (bow.isReady ? .white : .systemOrange)
            pullLine.isHidden = false
        } else {
            pullLine.isHidden = true
        }

        while dots.count < points.count {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = .white
            dot.strokeColor = .clear
            addChild(dot)
            dots.append(dot)
        }
        for (index, dot) in dots.enumerated() {
            guard index < points.count else {
                dot.isHidden = true
                continue
            }
            dot.isHidden = false
            dot.position = CGPoint(points[index])
            dot.alpha = 1 - CGFloat(index) / CGFloat(points.count) * 0.8
        }
    }
}
