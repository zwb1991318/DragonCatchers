/// 船怎么选打捞目标。只做计算，不改状态。
public enum BoatAI {
    /// 船追上一个漂流物要多久；追不上返回 nil
    public static func interceptTime(boatX: Double, targetX: Double, boatSpeed: Double, flowSpeed: Double) -> Double? {
        let gap = targetX - boatX
        if gap <= 0 {
            // 目标在上游，迎面靠近
            return -gap / (boatSpeed + flowSpeed)
        }
        let closing = boatSpeed - flowSpeed
        guard closing > 0 else { return nil }
        return gap / closing
    }

    /// 漂流物还要多久漂出屏幕
    public static func timeToExit(x: Double, river: RiverConfig) -> Double {
        (river.exitX - x) / river.flowSpeed
    }

    public static func isReachable(boatX: Double, targetX: Double, boat: BoatConfig, river: RiverConfig) -> Bool {
        guard let time = interceptTime(boatX: boatX, targetX: targetX, boatSpeed: boat.speed, flowSpeed: river.flowSpeed) else {
            return false
        }
        return time < timeToExit(x: targetX, river: river)
    }

    /// 先排除追不上的，再挑最快会漂出屏幕的
    public static func chooseTarget(boatX: Double, carcasses: [Carcass], boat: BoatConfig, river: RiverConfig) -> EntityID? {
        carcasses
            .filter { $0.phase == .floating && isReachable(boatX: boatX, targetX: $0.position.x, boat: boat, river: river) }
            .min { timeToExit(x: $0.position.x, river: river) < timeToExit(x: $1.position.x, river: river) }?
            .id
    }
}
