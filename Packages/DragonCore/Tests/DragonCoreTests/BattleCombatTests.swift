import Testing
@testable import DragonCore

/// 夹具：城墙正面 x = 150、HP 30；龙速度 100、攻击距离 200（停在 x = 350）、伤害 10、间隔 1 秒、HP 2、命中半径 20
struct BattleCombatTests {
    private func makeBattle(_ level: LevelConfig = Fixtures.idleLevel) -> Battle {
        Battle(balance: Fixtures.balance, level: level, seed: 1)
    }

    private func arrow(_ id: EntityID, from origin: Vec2, velocity: Vec2) -> Arrow {
        Arrow(id: id, origin: origin, launchVelocity: velocity, position: origin, velocity: velocity)
    }

    @Test func startsWithFullWallAndBoatAtDock() {
        let battle = makeBattle()
        #expect(battle.wallHP == 30)
        #expect(battle.boat.x == 200)
        #expect(battle.outcome == .playing)
    }

    @Test func releasingTheBowFiresAnArrowFromTheArcher() {
        var battle = makeBattle()
        let began = battle.beginAim(at: Vec2(100, 300))
        #expect(began)
        battle.moveAim(to: Vec2(60, 300))
        #expect(battle.aimPreview().isEmpty == false)
        let events = battle.endAim()
        #expect(events.count == 1)
        #expect(battle.arrows.count == 1)
        #expect(battle.arrows[0].origin == Vec2(100, 300))
        #expect(battle.arrows[0].launchVelocity == Vec2(400, 0))
    }

    @Test func pressingAwayFromArcherDoesNotAim() {
        var battle = makeBattle()
        let began = battle.beginAim(at: Vec2(500, 300))
        #expect(began == false)
        let events = battle.endAim()
        #expect(events.isEmpty)
        #expect(battle.arrows.isEmpty)
    }

    @Test func dragonsSpawnAtTheRightEdge() {
        var battle = makeBattle(Fixtures.level([Fixtures.wave(count: 1)]))
        _ = battle.step(dt: 0.01)
        #expect(battle.dragons.count == 1)
        #expect(battle.dragons[0].position == Vec2(999, 300)) // 出场的同一帧已经往左飞了 100 × 0.01
        #expect(battle.dragons[0].hp == 2)
    }

    @Test func dragonStopsAtAttackRangeAndBurnsTheWall() {
        var battle = makeBattle()
        battle.dragons = [Dragon(id: 99, kind: "normal", position: Vec2(360, 300), hp: 2)]

        _ = battle.step(dt: 0.1)
        #expect(battle.dragons[0].position.x == 350)
        #expect(battle.dragons[0].phase == .attacking)

        let events = battle.step(dt: 0.1)
        #expect(events.contains(.dragonAttacked(99)))
        #expect(battle.wallHP == 20)

        let events3 = battle.step(dt: 0.5)
        #expect(events3.contains(.dragonAttacked(99)) == false)
        let events4 = battle.step(dt: 0.5)
        #expect(events4.contains(.dragonAttacked(99)))
        #expect(battle.wallHP == 10)
    }

    @Test func twoHitsKillADragonAndDropACarcass() {
        var battle = makeBattle()
        battle.dragons = [Dragon(id: 99, kind: "normal", position: Vec2(310, 300), hp: 2, phase: .attacking, attackCooldown: 10)]

        battle.arrows = [arrow(50, from: Vec2(300, 300), velocity: Vec2(100, 0))]
        let events1 = battle.step(dt: 0.1)
        #expect(events1.contains(.dragonHit(99)))
        #expect(battle.dragons[0].hp == 1)
        #expect(battle.arrows.isEmpty)

        battle.arrows = [arrow(51, from: Vec2(300, 300), velocity: Vec2(100, 0))]
        let events2 = battle.step(dt: 0.1)
        #expect(events2.contains(.dragonKilled(99)))
        #expect(battle.dragons.isEmpty)
        #expect(battle.dragonsKilled == 1)
        #expect(battle.carcasses.count == 1)
        #expect(battle.carcasses[0].value == 10)
        #expect(battle.carcasses[0].phase == .falling)
    }

    @Test func arrowsDisappearInTheRiver() {
        var battle = makeBattle()
        battle.arrows = [arrow(50, from: Vec2(500, 90), velocity: Vec2(0, -100))]
        _ = battle.step(dt: 0.1)
        #expect(battle.arrows.isEmpty)
    }

    @Test func wallAtZeroLosesImmediatelyAndStopsTheGame() {
        var battle = makeBattle()
        battle.wallHP = 10
        battle.dragons = [Dragon(id: 99, kind: "normal", position: Vec2(350, 300), hp: 2, phase: .attacking, attackCooldown: 0)]

        let events = battle.step(dt: 0.1)
        #expect(events.contains(.outcomeChanged(.lost)))
        #expect(battle.outcome == .lost)
        let after = battle.step(dt: 0.1)
        #expect(after.isEmpty)
        let began = battle.beginAim(at: Vec2(100, 300))
        #expect(began == false)
        #expect(battle.summary.won == false)
    }
}
