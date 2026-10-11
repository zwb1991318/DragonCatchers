import Testing
@testable import DragonCore

struct WaveSpawnerTests {
    @Test func firstWaveWaitsForItsDelay() {
        var spawner = WaveSpawner(level: Fixtures.level([Fixtures.wave(delay: 2, count: 1)]))
        let first = spawner.step(dt: 1, aliveDragons: 0)
        #expect(first == [])
        let second = spawner.step(dt: 1, aliveDragons: 0)
        #expect(second == ["normal"])
        #expect(spawner.isFinished)
    }

    @Test func dragonsInAGroupComeAtTheInterval() {
        var spawner = WaveSpawner(level: Fixtures.level([Fixtures.wave(count: 3, interval: 1)]))
        let a = spawner.step(dt: 0.1, aliveDragons: 0)
        #expect(a == ["normal"])
        let b = spawner.step(dt: 0.5, aliveDragons: 1)
        #expect(b == [])
        let c = spawner.step(dt: 0.5, aliveDragons: 1)
        #expect(c == ["normal"])
        #expect(spawner.isFinished == false)
        let d = spawner.step(dt: 1, aliveDragons: 2)
        #expect(d == ["normal"])
        #expect(spawner.isFinished)
    }

    @Test func aLongFrameCanSpawnSeveral() {
        var spawner = WaveSpawner(level: Fixtures.level([Fixtures.wave(count: 3, interval: 1)]))
        let a = spawner.step(dt: 0, aliveDragons: 0)
        #expect(a.count == 1)
        let b = spawner.step(dt: 5, aliveDragons: 1)
        #expect(b.count == 2)
    }

    @Test func groupsComeOneAfterAnother() {
        let wave = WaveConfig(delay: 0, groups: [
            SpawnGroup(kind: "normal", count: 1, interval: 1),
            SpawnGroup(kind: "fast", count: 1, interval: 2),
        ])
        var spawner = WaveSpawner(level: Fixtures.level([wave]))
        let a = spawner.step(dt: 0, aliveDragons: 0)
        #expect(a == ["normal"])
        let b = spawner.step(dt: 1, aliveDragons: 1)
        #expect(b == [])
        let c = spawner.step(dt: 1, aliveDragons: 1)
        #expect(c == ["fast"])
    }

    @Test func nextWaveWaitsUntilFieldIsClear() {
        var spawner = WaveSpawner(level: Fixtures.level([
            Fixtures.wave(delay: 0, count: 1),
            Fixtures.wave(delay: 1, count: 1),
        ]))
        let a = spawner.step(dt: 0, aliveDragons: 0)
        #expect(a == ["normal"])
        let b = spawner.step(dt: 10, aliveDragons: 1)
        #expect(b == [])
        #expect(spawner.waveIndex == 0)
        #expect(spawner.isFinished == false)

        let c = spawner.step(dt: 0, aliveDragons: 0) // 场上清空，进入第二波的等待
        #expect(c == [])
        #expect(spawner.waveIndex == 1)
        let d = spawner.step(dt: 0.5, aliveDragons: 0)
        #expect(d == [])
        let e = spawner.step(dt: 0.5, aliveDragons: 0)
        #expect(e == ["normal"])
        #expect(spawner.isFinished)
    }

    @Test func emptyLevelIsFinishedImmediately() {
        let spawner = WaveSpawner(level: Fixtures.level([]))
        #expect(spawner.isFinished)
        #expect(spawner.waveCount == 0)
    }
}
