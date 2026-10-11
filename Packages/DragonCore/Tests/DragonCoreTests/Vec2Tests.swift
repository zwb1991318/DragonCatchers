import Foundation
import Testing
@testable import DragonCore

struct Vec2Tests {
    @Test func arithmetic() {
        let a = Vec2(3, 4)
        let b = Vec2(1, 2)
        #expect(a + b == Vec2(4, 6))
        #expect(a - b == Vec2(2, 2))
        #expect(a * 2 == Vec2(6, 8))
    }

    @Test func lengthAndDistance() {
        #expect(Vec2(3, 4).length == 5)
        #expect(Vec2(1, 1).distance(to: Vec2(4, 5)) == 5)
    }

    @Test func decodesFromJSON() throws {
        let data = Data(#"{"x": 1.5, "y": -2}"#.utf8)
        let v = try JSONDecoder().decode(Vec2.self, from: data)
        #expect(v == Vec2(1.5, -2))
    }
}
