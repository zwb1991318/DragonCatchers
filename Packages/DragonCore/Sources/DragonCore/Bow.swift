public enum ShotResult: Equatable, Sendable {
    case fired(velocity: Vec2)
    case cancelled
}

/// 拉弓输入的状态机：只负责把"按下—拖动—松手"变成一次发射或取消，不管箭怎么飞。
public struct Bow: Sendable {
    public let config: BowConfig
    public private(set) var reloadRemaining: Double = 0
    /// 按下的位置（起点）；为 nil 表示当前没在拉弓
    public private(set) var start: Vec2?
    public private(set) var current: Vec2?

    public init(config: BowConfig) {
        self.config = config
    }

    public var isAiming: Bool { start != nil }
    public var isReady: Bool { reloadRemaining <= 0 }

    public mutating func update(dt: Double) {
        reloadRemaining = max(0, reloadRemaining - dt)
    }

    /// 只有按在弓箭手附近才开始拉弓
    @discardableResult
    public mutating func begin(at point: Vec2) -> Bool {
        guard point.distance(to: config.anchor) <= config.grabRadius else { return false }
        start = point
        current = point
        return true
    }

    public mutating func move(to point: Vec2) {
        guard isAiming else { return }
        current = point
    }

    /// 当前拉弓对应的箭初速度：方向和拖动方向相反，大小随拖动距离增加，超过 maxPull 后不再增加。
    /// 手指还在取消圈内时返回 nil。
    public var aimVelocity: Vec2? {
        guard let start, let current else { return nil }
        let pull = start - current
        let distance = pull.length
        guard distance > config.cancelRadius else { return nil }
        let clamped = min(distance, config.maxPull)
        return pull * (clamped / distance * config.launchSpeedPerPoint)
    }

    /// 松手。装填没完成，或者手指在取消圈内，都视为取消。
    public mutating func release() -> ShotResult {
        defer { cancel() }
        guard isReady, let velocity = aimVelocity else { return .cancelled }
        reloadRemaining = config.reloadTime
        return .fired(velocity: velocity)
    }

    public mutating func cancel() {
        start = nil
        current = nil
    }
}
