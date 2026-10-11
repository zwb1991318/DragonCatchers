import DragonCore
import SpriteKit

/// 把一组实体按 id 同步成节点：新出现的就建节点，已经消失的就删掉，其余的更新位置等属性。
@MainActor
final class EntityLayer<Item> {
    let root = SKNode()
    private var nodes: [EntityID: SKNode] = [:]
    private let id: (Item) -> EntityID
    private let make: @MainActor (Item) -> SKNode
    private let update: @MainActor (Item, SKNode) -> Void

    init(
        id: @escaping (Item) -> EntityID,
        make: @escaping @MainActor (Item) -> SKNode,
        update: @escaping @MainActor (Item, SKNode) -> Void
    ) {
        self.id = id
        self.make = make
        self.update = update
    }

    func node(for id: EntityID) -> SKNode? {
        nodes[id]
    }

    func sync(_ items: [Item]) {
        var seen = Set<EntityID>()
        for item in items {
            let key = id(item)
            seen.insert(key)
            let node: SKNode
            if let existing = nodes[key] {
                node = existing
            } else {
                node = make(item)
                root.addChild(node)
                nodes[key] = node
            }
            update(item, node)
        }
        for (key, node) in nodes where !seen.contains(key) {
            node.removeFromParent()
            nodes[key] = nil
        }
    }
}
