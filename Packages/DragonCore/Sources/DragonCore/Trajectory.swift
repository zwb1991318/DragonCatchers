/// 箭的抛物线。实际飞行和预瞄虚线用同一套公式，保证两者完全一致。
public enum Trajectory {
    public static func position(origin: Vec2, velocity: Vec2, gravity: Double, time t: Double) -> Vec2 {
        Vec2(origin.x + velocity.x * t, origin.y + velocity.y * t - 0.5 * gravity * t * t)
    }

    public static func velocity(launch: Vec2, gravity: Double, time t: Double) -> Vec2 {
        Vec2(launch.x, launch.y - gravity * t)
    }

    /// 预瞄虚线上的点：从发射后 step 秒开始，每隔 step 秒取一个点
    public static func previewPoints(origin: Vec2, velocity: Vec2, gravity: Double, step: Double, count: Int) -> [Vec2] {
        guard count > 0 else { return [] }
        return (1...count).map { position(origin: origin, velocity: velocity, gravity: gravity, time: Double($0) * step) }
    }
}
