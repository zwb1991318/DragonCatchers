public typealias EntityID = Int

public struct Arrow: Equatable, Sendable {
    public let id: EntityID
    public let origin: Vec2
    public let launchVelocity: Vec2
    /// 发射后经过的时间
    public var age: Double = 0
    public var position: Vec2
    public var velocity: Vec2
}

public enum DragonPhase: Equatable, Sendable {
    /// 正在飞向城墙
    case approaching
    /// 已进入攻击距离，悬停喷火
    case attacking
}

public struct Dragon: Equatable, Sendable {
    public let id: EntityID
    public let kind: String
    public var position: Vec2
    public var hp: Double
    public var phase: DragonPhase = .approaching
    /// 距离下一次喷火还有多久
    public var attackCooldown: Double = 0
}

public enum CarcassPhase: Equatable, Sendable {
    case falling
    case floating
}

/// 被击落的龙：先下坠，落水后随水流漂走，等船来捞
public struct Carcass: Equatable, Sendable {
    public let id: EntityID
    public let kind: String
    /// 基础回收价值
    public let value: Double
    public var position: Vec2
    public var phase: CarcassPhase
    /// 下坠速度（向下为正）
    public var fallSpeed: Double = 0
}

public enum BoatMode: Equatable, Sendable {
    case idle
    case chasing(EntityID)
    case returning
}

public struct Boat: Equatable, Sendable {
    /// 船只在河面上左右移动，所以只记 x
    public var x: Double
    /// 船上每条龙的基础回收价值
    public var cargo: [Double] = []
    public var mode: BoatMode = .idle
}
