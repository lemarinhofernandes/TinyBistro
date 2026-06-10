import SceneKit

final class BistroSceneController {
    let scene: SCNScene

    private var world: BistroWorld
    private var furnitureNodes: [Furniture.ID: SCNNode] = [:]
    private var entityNodes: [Entity.ID: SCNNode] = [:]
    private var selectionNode: SCNNode?

    init(world: BistroWorld) {
        self.world = world
        self.scene = SceneBuilder.buildBaseScene(world: world)
        sync(to: world, animated: false)
    }

    func sync(to world: BistroWorld, animated: Bool = true) {
        self.world = world
        syncFurniture(world: world)
        syncEntities(world: world, animated: animated)
        syncSelection(world: world)
    }

    private func syncFurniture(world: BistroWorld) {
        let currentIDs = Set(world.furniture.map(\.id))
        let removedIDs = furnitureNodes.keys.filter { !currentIDs.contains($0) }

        for id in removedIDs {
            furnitureNodes[id]?.removeFromParentNode()
            furnitureNodes[id] = nil
        }

        for furniture in world.furniture {
            if furnitureNodes[furniture.id] == nil {
                let node = NodeFactory.furnitureNode(furniture, world: world)
                furnitureNodes[furniture.id] = node
                scene.rootNode.addChildNode(node)
            }
        }
    }

    private func syncEntities(world: BistroWorld, animated: Bool) {
        let currentIDs = Set(world.entities.map(\.id))
        let removedIDs = entityNodes.keys.filter { !currentIDs.contains($0) }

        for id in removedIDs {
            entityNodes[id]?.removeFromParentNode()
            entityNodes[id] = nil
        }

        for entity in world.entities {
            let targetPosition = SceneCoordinates.worldPosition(for: entity.position, in: world, y: 0.12)

            if let node = entityNodes[entity.id] {
                if animated {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.22
                    node.position = targetPosition
                    SCNTransaction.commit()
                } else {
                    node.position = targetPosition
                }
            } else {
                let node = NodeFactory.entityNode(entity, world: world)
                entityNodes[entity.id] = node
                scene.rootNode.addChildNode(node)
            }
        }
    }

    private func syncSelection(world: BistroWorld) {
        selectionNode?.removeFromParentNode()
        selectionNode = nil

        guard let selectedPosition = selectedGridPosition(in: world) else {
            return
        }

        let node = NodeFactory.selectionNode(position: selectedPosition, world: world)
        selectionNode = node
        scene.rootNode.addChildNode(node)
    }

    private func selectedGridPosition(in world: BistroWorld) -> GridPosition? {
        switch world.selectedTarget {
        case .tile(let position):
            return position
        case .furniture(let id):
            return world.furniture.first { $0.id == id }?.position
        case .entity(let id):
            return world.entities.first { $0.id == id }?.position
        case .none:
            return nil
        }
    }
}
