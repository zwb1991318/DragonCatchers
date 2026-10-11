/// 二维向量。坐标系和 SpriteKit 一致：原点在左下角，y 轴向上。
public struct Vec2: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    public static let zero = Vec2(0, 0)

    public var length: Double { (x * x + y * y).squareRoot() }

    public func distance(to other: Vec2) -> Double { (self - other).length }

    public static func + (a: Vec2, b: Vec2) -> Vec2 { Vec2(a.x + b.x, a.y + b.y) }
    public static func - (a: Vec2, b: Vec2) -> Vec2 { Vec2(a.x - b.x, a.y - b.y) }
    public static func * (v: Vec2, s: Double) -> Vec2 { Vec2(v.x * s, v.y * s) }
}
