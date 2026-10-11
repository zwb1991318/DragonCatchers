@testable import DragonCore

/// 测试专用的固定数值，和 Data/*.json 的手感调整互不影响。
enum Fixtures {
    static let dragon = DragonKind(
        maxHP: 2, speed: 100, attackRange: 200, attackDamage: 10,
        attackInterval: 1, hitRadius: 20, value: 10
    )

    static let balance = BalanceConfig(
        world: WorldConfig(width: 1000, height: 500, gravity: 500, spawnX: 1000, spawnMinY: 300, spawnMaxY: 300),
        bow: BowConfig(
            anchor: Vec2(100, 300), grabRadius: 50, cancelRadius: 20, maxPull: 100,
            launchSpeedPerPoint: 10, reloadTime: 1, damage: 1
        ),
        wall: WallConfig(frontX: 150, topY: 280, maxHP: 30),
        river: RiverConfig(surfaceY: 80, floatY: 60, flowSpeed: 50, exitX: 1000),
        boat: BoatConfig(dockX: 200, speed: 150, capacity: 2, pickupRadius: 20),
        economy: EconomyConfig(incomeMultiplier: 2),
        dragons: ["normal": dragon],
        victoryGraceTime: 5
    )

    static func wave(delay: Double = 0, count: Int, interval: Double = 1, kind: String = "normal") -> WaveConfig {
        WaveConfig(delay: delay, groups: [SpawnGroup(kind: kind, count: count, interval: interval)])
    }

    static func level(_ waves: [WaveConfig]) -> LevelConfig {
        LevelConfig(name: "test", waves: waves)
    }

    /// 一直在等第一波的关卡：不会出龙，也不会判胜，方便手动摆放实体做测试
    static let idleLevel = level([wave(delay: 999, count: 1)])
}
