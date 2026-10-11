import Testing
@testable import DragonCore

/// 夹具：水流 50（向右），出口 x = 1000，船速 150
struct BoatAITests {
    private let boat = Fixtures.balance.boat
    private let river = Fixtures.balance.river

    private func floating(_ id: EntityID, x: Double) -> Carcass {
        Carcass(id: id, kind: "normal", value: 10, position: Vec2(x, 60), phase: .floating)
    }

    @Test func interceptDownstreamTarget() {
        // 目标在船右边（下游）：相对速度 150 − 50 = 100，距离 200
        #expect(BoatAI.interceptTime(boatX: 200, targetX: 400, boatSpeed: 150, flowSpeed: 50) == 2)
    }

    @Test func interceptUpstreamTarget() {
        // 目标在船左边（上游），迎面靠近：相对速度 150 + 50 = 200，距离 200
        #expect(BoatAI.interceptTime(boatX: 400, targetX: 200, boatSpeed: 150, flowSpeed: 50) == 1)
    }

    @Test func cannotCatchWhenSlowerThanTheCurrent() {
        #expect(BoatAI.interceptTime(boatX: 0, targetX: 100, boatSpeed: 40, flowSpeed: 50) == nil)
    }

    @Test func targetsTooCloseToTheExitAreUnreachable() {
        #expect(BoatAI.isReachable(boatX: 200, targetX: 400, boat: boat, river: river))
        #expect(BoatAI.isReachable(boatX: 200, targetX: 950, boat: boat, river: river) == false)
    }

    @Test func choosesTheReachableOneThatLeavesSoonest() {
        var falling = floating(4, x: 700)
        falling.phase = .falling
        let carcasses = [floating(1, x: 400), floating(2, x: 600), floating(3, x: 950), falling]
        #expect(BoatAI.chooseTarget(boatX: 200, carcasses: carcasses, boat: boat, river: river) == 2)
    }

    @Test func noTargetWhenNothingIsReachable() {
        #expect(BoatAI.chooseTarget(boatX: 200, carcasses: [floating(1, x: 990)], boat: boat, river: river) == nil)
        #expect(BoatAI.chooseTarget(boatX: 200, carcasses: [], boat: boat, river: river) == nil)
    }
}
