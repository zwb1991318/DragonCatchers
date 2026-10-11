import SpriteKit

/// 顶部信息条：城墙血条、本关收益、波次
@MainActor
final class HUDNode: SKNode {
    private let barWidth: CGFloat = 200
    private let hpFill: SKSpriteNode
    private let incomeLabel = SKLabelNode(fontNamed: "PingFangSC-Semibold")
    private let waveLabel = SKLabelNode(fontNamed: "PingFangSC-Semibold")

    init(sceneSize: CGSize) {
        hpFill = SKSpriteNode(color: .systemGreen, size: CGSize(width: barWidth, height: 14))
        super.init()
        let top = sceneSize.height - 28

        let hpBackground = SKSpriteNode(color: SKColor(white: 0, alpha: 0.45), size: CGSize(width: barWidth + 4, height: 18))
        hpBackground.anchorPoint = CGPoint(x: 0, y: 0.5)
        hpBackground.position = CGPoint(x: 18, y: top)
        hpFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        hpFill.position = CGPoint(x: 20, y: top)

        for label in [incomeLabel, waveLabel] {
            label.fontSize = 22
            label.fontColor = .white
            label.verticalAlignmentMode = .center
        }
        incomeLabel.position = CGPoint(x: sceneSize.width / 2, y: top)
        waveLabel.horizontalAlignmentMode = .right
        waveLabel.position = CGPoint(x: sceneSize.width - 24, y: top)

        addChild(hpBackground)
        addChild(hpFill)
        addChild(incomeLabel)
        addChild(waveLabel)
        zPosition = 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("HUDNode 只能用代码创建")
    }

    func update(wallHP: Double, maxHP: Double, income: Double, wave: Int, waveCount: Int) {
        let ratio = max(0, min(1, wallHP / maxHP))
        hpFill.xScale = ratio
        hpFill.color = ratio > 0.3 ? .systemGreen : .systemRed
        incomeLabel.text = "收益 \(Int(income))"
        waveLabel.text = "波次 \(min(wave, waveCount))/\(waveCount)"
    }
}
