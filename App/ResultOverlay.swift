import DragonCore
import SwiftUI

struct ResultOverlay: View {
    let summary: BattleSummary
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(summary.won ? "守住了！" : "城墙被攻破了")
                .font(.largeTitle.bold())
            Text("本关收益 \(Int(summary.income))")
                .font(.title2)
            Text("击落 \(summary.dragonsKilled) · 捞到 \(summary.dragonsCollected) · 被冲走 \(summary.dragonsLost)")
                .foregroundStyle(.secondary)
            Button("再来一次", action: onRestart)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.35))
    }
}
