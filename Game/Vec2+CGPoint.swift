import CoreGraphics
import DragonCore

extension CGPoint {
    init(_ v: Vec2) {
        self.init(x: v.x, y: v.y)
    }
}

extension Vec2 {
    init(_ p: CGPoint) {
        self.init(Double(p.x), Double(p.y))
    }
}
