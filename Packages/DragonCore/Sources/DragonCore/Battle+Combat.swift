extension Battle {
    mutating func spawnDragons(dt: Double) {
        let world = balance.world
        for kindName in spawner.step(dt: dt, aliveDragons: dragons.count) {
            guard let kind = balance.dragons[kindName] else {
                preconditionFailure("未知的龙种类：\(kindName)")
            }
            let y = Double.random(in: world.spawnMinY...world.spawnMaxY, using: &rng)
            dragons.append(Dragon(id: makeID(), kind: kindName, position: Vec2(world.spawnX, y), hp: kind.maxHP))
        }
    }

    /// 龙飞向城墙，进入攻击距离后停下，按间隔远程喷火；不需要接触城墙
    mutating func moveDragons(dt: Double, events: inout [BattleEvent]) {
        for i in dragons.indices {
            let stats = dragonKind(dragons[i])
            switch dragons[i].phase {
            case .approaching:
                let stopX = balance.wall.frontX + stats.attackRange
                if dragons[i].position.x > stopX {
                    dragons[i].position.x = max(stopX, dragons[i].position.x - stats.speed * dt)
                }
                if dragons[i].position.x <= stopX {
                    dragons[i].phase = .attacking
                    dragons[i].attackCooldown = 0
                }
            case .attacking:
                dragons[i].attackCooldown -= dt
                if dragons[i].attackCooldown <= 0 {
                    dragons[i].attackCooldown += stats.attackInterval
                    wallHP = max(0, wallHP - stats.attackDamage)
                    events.append(.dragonAttacked(dragons[i].id))
                }
            }
        }
    }

    mutating func moveArrows(dt: Double, events: inout [BattleEvent]) {
        let gravity = balance.world.gravity
        var remaining: [Arrow] = []
        for var arrow in arrows {
            arrow.age += dt
            arrow.position = Trajectory.position(origin: arrow.origin, velocity: arrow.launchVelocity, gravity: gravity, time: arrow.age)
            arrow.velocity = Trajectory.velocity(launch: arrow.launchVelocity, gravity: gravity, time: arrow.age)
            let tip = arrow.position
            if let index = dragons.firstIndex(where: { $0.position.distance(to: tip) <= dragonKind($0).hitRadius }) {
                hitDragon(at: index, events: &events)
                continue
            }
            if isOutOfPlay(tip) { continue }
            remaining.append(arrow)
        }
        arrows = remaining
    }

    mutating func hitDragon(at index: Int, events: inout [BattleEvent]) {
        dragons[index].hp -= balance.bow.damage
        let dragon = dragons[index]
        guard dragon.hp <= 0 else {
            events.append(.dragonHit(dragon.id))
            return
        }
        // HP 归零即死亡；之后的下坠、漂流和打捞属于收集流程
        dragons.remove(at: index)
        dragonsKilled += 1
        carcasses.append(Carcass(id: dragon.id, kind: dragon.kind, value: dragonKind(dragon).value, position: dragon.position, phase: .falling))
        events.append(.dragonKilled(dragon.id))
    }

    /// 箭落进河里，或者飞出屏幕左右两侧，就移除
    func isOutOfPlay(_ point: Vec2) -> Bool {
        point.y < balance.river.surfaceY || point.x < -50 || point.x > balance.world.width + 50
    }
}
