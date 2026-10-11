extension Battle {
    /// 龙尸先下坠，落水后随水流向右漂，漂过出口就丢失
    mutating func moveCarcasses(dt: Double, events: inout [BattleEvent]) {
        let river = balance.river
        var kept: [Carcass] = []
        for var carcass in carcasses {
            switch carcass.phase {
            case .falling:
                carcass.fallSpeed += balance.world.gravity * dt
                carcass.position.y -= carcass.fallSpeed * dt
                if carcass.position.y <= river.floatY {
                    carcass.position.y = river.floatY
                    carcass.phase = .floating
                    events.append(.carcassLanded(carcass.id))
                }
            case .floating:
                carcass.position.x += river.flowSpeed * dt
                if carcass.position.x > river.exitX {
                    dragonsLost += 1
                    events.append(.carcassLost(carcass.id))
                    continue
                }
            }
            kept.append(carcass)
        }
        carcasses = kept
    }

    /// 船：选定目标后一直追，直到捞到、目标消失或追不上；没装满时如果出现新目标，返航途中也会掉头去捞；
    /// 装满或者没有目标时回码头卸货。M1 里打捞和卸货都是瞬间完成。
    mutating func moveBoat(dt: Double, events: inout [BattleEvent]) {
        let config = balance.boat
        if case .chasing(let id) = boat.mode, !isValidTarget(id) {
            boat.mode = .idle
        }
        if !isChasing {
            if boat.cargo.count < config.capacity,
               let id = BoatAI.chooseTarget(boatX: boat.x, carcasses: carcasses, boat: config, river: balance.river) {
                boat.mode = .chasing(id)
            } else if boat.cargo.isEmpty && boat.x == config.dockX {
                boat.mode = .idle
            } else {
                boat.mode = .returning
            }
        }

        switch boat.mode {
        case .idle:
            break
        case .chasing(let id):
            guard let index = carcasses.firstIndex(where: { $0.id == id }) else { break }
            boat.x = Self.approach(boat.x, toward: carcasses[index].position.x, maxStep: config.speed * dt)
            if abs(boat.x - carcasses[index].position.x) <= config.pickupRadius {
                let carcass = carcasses.remove(at: index)
                boat.cargo.append(carcass.value)
                boat.mode = .idle
                dragonsCollected += 1
                events.append(.carcassCollected(carcass.id))
            }
        case .returning:
            boat.x = Self.approach(boat.x, toward: config.dockX, maxStep: config.speed * dt)
            if boat.x == config.dockX {
                if !boat.cargo.isEmpty {
                    let earned = boat.cargo.reduce(0, +) * balance.economy.incomeMultiplier
                    income += earned
                    boat.cargo.removeAll()
                    events.append(.cargoUnloaded(income: earned))
                }
                boat.mode = .idle
            }
        }
    }

    /// 朝目标移动，每次最多移动 maxStep，不会越过目标
    static func approach(_ value: Double, toward target: Double, maxStep: Double) -> Double {
        let delta = target - value
        if abs(delta) <= maxStep { return target }
        return value + (delta > 0 ? maxStep : -maxStep)
    }

    private var isChasing: Bool {
        if case .chasing = boat.mode { return true }
        return false
    }

    private func isValidTarget(_ id: EntityID) -> Bool {
        guard let carcass = carcasses.first(where: { $0.id == id }), carcass.phase == .floating else { return false }
        return BoatAI.isReachable(boatX: boat.x, targetX: carcass.position.x, boat: balance.boat, river: balance.river)
    }
}
