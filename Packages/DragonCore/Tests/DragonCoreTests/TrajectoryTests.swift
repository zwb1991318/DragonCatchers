import Testing
@testable import DragonCore

struct TrajectoryTests {
    @Test func withoutGravityItIsAStraightLine() {
        let p = Trajectory.position(origin: Vec2(1, 2), velocity: Vec2(10, 0), gravity: 0, time: 2)
        #expect(p == Vec2(21, 2))
    }

    @Test func gravityPullsDown() {
        // y = 100·1 − ½·100·1² = 50
        #expect(Trajectory.position(origin: .zero, velocity: Vec2(0, 100), gravity: 100, time: 1) == Vec2(0, 50))
        #expect(Trajectory.velocity(launch: Vec2(5, 100), gravity: 100, time: 1) == Vec2(5, 0))
    }

    @Test func previewPointsStartOneStepAfterLaunch() {
        let points = Trajectory.previewPoints(origin: .zero, velocity: Vec2(10, 0), gravity: 0, step: 0.5, count: 3)
        #expect(points == [Vec2(5, 0), Vec2(10, 0), Vec2(15, 0)])
    }

    @Test func previewWithZeroCountIsEmpty() {
        #expect(Trajectory.previewPoints(origin: .zero, velocity: Vec2(10, 0), gravity: 0, step: 0.5, count: 0).isEmpty)
    }
}
