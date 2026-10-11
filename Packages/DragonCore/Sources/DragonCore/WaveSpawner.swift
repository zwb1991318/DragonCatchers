/// 按关卡配置决定什么时候出哪条龙。只管出龙，不管龙的死活；调用方每帧告诉它场上还有几条活龙。
public struct WaveSpawner: Sendable {
    private enum State: Equatable, Sendable {
        /// 等待本波开始
        case delay(remaining: Double)
        /// 正在出本波的龙，timer 是距离下一条龙出场的时间
        case spawning(timer: Double)
        /// 本波出完了，等场上的龙全部死亡
        case waitingForClear
        case finished
    }

    private struct PendingSpawn: Equatable, Sendable {
        var kind: String
        /// 距离上一条龙出场的间隔
        var wait: Double
    }

    private let waves: [WaveConfig]
    /// 当前波次（从 0 开始）
    public private(set) var waveIndex = 0
    private var state: State
    private var queue: [PendingSpawn] = []

    public init(level: LevelConfig) {
        waves = level.waves
        state = waves.isEmpty ? .finished : .delay(remaining: waves[0].delay)
    }

    public var waveCount: Int { waves.count }

    /// 所有波次的龙都已经出完
    public var isFinished: Bool { state == .finished }

    /// 推进时间，返回这一帧要生成的龙的种类
    public mutating func step(dt: Double, aliveDragons: Int) -> [String] {
        switch state {
        case .finished:
            return []
        case .waitingForClear:
            guard aliveDragons == 0 else { return [] }
            waveIndex += 1
            state = .delay(remaining: waves[waveIndex].delay)
            return []
        case .delay(let remaining):
            let left = remaining - dt
            guard left <= 0 else {
                state = .delay(remaining: left)
                return []
            }
            queue = Self.schedule(for: waves[waveIndex])
            return advanceSpawning(timer: 0)
        case .spawning(let timer):
            return advanceSpawning(timer: timer - dt)
        }
    }

    private mutating func advanceSpawning(timer: Double) -> [String] {
        var timer = timer
        var spawned: [String] = []
        while timer <= 0, !queue.isEmpty {
            spawned.append(queue.removeFirst().kind)
            if let next = queue.first {
                timer += next.wait
            }
        }
        if queue.isEmpty {
            state = waveIndex == waves.count - 1 ? .finished : .waitingForClear
        } else {
            state = .spawning(timer: timer)
        }
        return spawned
    }

    private static func schedule(for wave: WaveConfig) -> [PendingSpawn] {
        wave.groups.flatMap { group in
            Array(repeating: PendingSpawn(kind: group.kind, wait: group.interval), count: max(0, group.count))
        }
    }
}
