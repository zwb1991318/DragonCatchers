import Testing
@testable import DragonCore

/// 夹具：弓箭手在 (100, 300)，起手半径 50，取消圈 20，最大拉弓 100，每点速度 10，装填 1 秒
struct BowTests {
    private func makeBow() -> Bow { Bow(config: Fixtures.balance.bow) }

    @Test func pressingFarFromArcherDoesNothing() {
        var bow = makeBow()
        let began = bow.begin(at: Vec2(200, 300))
        #expect(began == false)
        #expect(bow.isAiming == false)
    }

    @Test func firesOppositeToTheDrag() {
        var bow = makeBow()
        let began = bow.begin(at: Vec2(100, 300))
        #expect(began)
        bow.move(to: Vec2(60, 300)) // 往左拖 40
        let result = bow.release()
        #expect(result == .fired(velocity: Vec2(400, 0))) // 往右射，40 × 10
        #expect(bow.isAiming == false)
    }

    @Test func pullIsClampedAtMaxPull() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(-100, 300)) // 拖了 200，上限是 100
        let result = bow.release()
        #expect(result == .fired(velocity: Vec2(1000, 0)))
    }

    @Test func releasingInsideCancelCircleCancels() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(85, 300)) // 只拖了 15，小于取消圈 20
        let result = bow.release()
        #expect(result == .cancelled)
        #expect(bow.isReady) // 取消不消耗装填
    }

    @Test func draggingBackIntoCancelCircleCancels() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(40, 300))
        bow.move(to: Vec2(95, 300))
        #expect(bow.aimVelocity == nil)
        let result = bow.release()
        #expect(result == .cancelled)
    }

    @Test func releasingWhileReloadingCancels() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(60, 300))
        _ = bow.release()
        #expect(bow.reloadRemaining == 1)

        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(60, 300))
        let result = bow.release()
        #expect(result == .cancelled)
        #expect(bow.reloadRemaining == 1) // 取消不会重置装填
    }

    @Test func canAimDuringReloadWithoutAutoFire() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(60, 300))
        _ = bow.release()

        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(60, 300))
        bow.update(dt: 0.5)
        #expect(bow.aimVelocity != nil)
        #expect(bow.isReady == false)
        bow.update(dt: 0.5)
        #expect(bow.isReady)
        #expect(bow.isAiming) // 装填完成也不会自动射出
        let result = bow.release()
        #expect(result == .fired(velocity: Vec2(400, 0)))
    }

    @Test func holdingStillDoesNotIncreasePower() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.move(to: Vec2(60, 300))
        let before = bow.aimVelocity
        bow.update(dt: 5)
        #expect(bow.aimVelocity == before)
    }

    @Test func cancelClearsAim() {
        var bow = makeBow()
        bow.begin(at: Vec2(100, 300))
        bow.cancel()
        #expect(bow.isAiming == false)
    }
}
