/// 全局数值配置，对应 Data/balance.json。
public struct BalanceConfig: Codable, Equatable, Sendable {
    public var world: WorldConfig
    public var bow: BowConfig
    public var wall: WallConfig
    public var river: RiverConfig
    public var boat: BoatConfig
    public var economy: EconomyConfig
    public var dragons: [String: DragonKind]
    /// 胜利后留给船继续打捞的收尾时间（秒）
    public var victoryGraceTime: Double
}

public struct WorldConfig: Codable, Equatable, Sendable {
    public var width: Double
    public var height: Double
    /// 重力加速度（正数，方向向下）
    public var gravity: Double
    /// 龙出现的位置：屏幕右侧外的 x 坐标，以及 y 的随机范围
    public var spawnX: Double
    public var spawnMinY: Double
    public var spawnMaxY: Double
}

public struct BowConfig: Codable, Equatable, Sendable {
    /// 弓箭手位置，也是箭的发射点
    public var anchor: Vec2
    /// 可起手区域半径，约为弓箭手图形的 2 倍
    public var grabRadius: Double
    /// 取消圈半径：手指离按下点不超过这个距离时松手，视为取消
    public var cancelRadius: Double
    /// 最大拉弓距离，超过后力度不再增加
    public var maxPull: Double
    /// 每拉 1 点距离对应的箭初速度
    public var launchSpeedPerPoint: Double
    public var reloadTime: Double
    public var damage: Double
}

public struct WallConfig: Codable, Equatable, Sendable {
    /// 城墙正面（朝向龙的一侧）的 x 坐标
    public var frontX: Double
    public var topY: Double
    public var maxHP: Double
}

public struct RiverConfig: Codable, Equatable, Sendable {
    /// 水面高度：箭低于它就算落水
    public var surfaceY: Double
    /// 龙尸漂浮时的高度
    public var floatY: Double
    /// 水流速度（向右，正数）
    public var flowSpeed: Double
    /// 龙尸漂过这个 x 坐标就算被冲走
    public var exitX: Double
}

public struct BoatConfig: Codable, Equatable, Sendable {
    public var dockX: Double
    public var speed: Double
    /// 载量（条数），普通龙每条占一个位置
    public var capacity: Int
    /// 船和龙尸的水平距离小于这个值就能捞上来
    public var pickupRadius: Double
}

public struct EconomyConfig: Codable, Equatable, Sendable {
    /// 收益系数：卸货收益 = 龙的基础回收价值之和 × 系数
    public var incomeMultiplier: Double
}

public struct DragonKind: Codable, Equatable, Sendable {
    public var maxHP: Double
    public var speed: Double
    /// 离城墙正面多远时停下来喷火
    public var attackRange: Double
    public var attackDamage: Double
    public var attackInterval: Double
    public var hitRadius: Double
    /// 基础回收价值
    public var value: Double
}
