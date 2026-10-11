/// 一关的波次配置，对应 Data/levelXX.json。
public struct LevelConfig: Codable, Equatable, Sendable {
    public var name: String
    public var waves: [WaveConfig]
}

public struct WaveConfig: Codable, Equatable, Sendable {
    /// 第一波：开局后等待的秒数；之后各波：上一波的龙全部死亡后等待的秒数
    public var delay: Double
    /// 按顺序依次出场的龙组
    public var groups: [SpawnGroup]
}

public struct SpawnGroup: Codable, Equatable, Sendable {
    public var kind: String
    public var count: Int
    /// 这一组里每条龙之间的出场间隔（秒）
    public var interval: Double
}
