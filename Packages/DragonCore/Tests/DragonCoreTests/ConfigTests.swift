import Testing
@testable import DragonCore

struct ConfigTests {
    @Test func bundledBalanceLoads() throws {
        let balance = try ConfigLoader.bundled(BalanceConfig.self, named: "balance")
        #expect(balance.world.width == 960)
        #expect(balance.dragons["normal"] != nil)
        #expect(balance.bow.cancelRadius < balance.bow.maxPull)
    }

    @Test func bundledLevelIsValid() throws {
        let balance = try ConfigLoader.bundled(BalanceConfig.self, named: "balance")
        let level = try ConfigLoader.bundled(LevelConfig.self, named: "level01")
        #expect(!level.waves.isEmpty)
        try ConfigLoader.validate(level: level, against: balance)
    }

    @Test func missingResourceThrows() {
        #expect(throws: ConfigError.missingResource("nope")) {
            try ConfigLoader.bundled(LevelConfig.self, named: "nope")
        }
    }

    @Test func unknownDragonKindIsRejected() {
        let level = Fixtures.level([Fixtures.wave(count: 1, kind: "ghost")])
        #expect(throws: ConfigError.unknownDragonKind("ghost")) {
            try ConfigLoader.validate(level: level, against: Fixtures.balance)
        }
    }

    @Test func seededRandomIsReproducible() {
        var a = SeededRandom(seed: 42)
        var b = SeededRandom(seed: 42)
        var c = SeededRandom(seed: 7)
        let seqA = (0..<5).map { _ in a.next() }
        let seqB = (0..<5).map { _ in b.next() }
        let seqC = (0..<5).map { _ in c.next() }
        #expect(seqA == seqB)
        #expect(seqA != seqC)
    }
}
