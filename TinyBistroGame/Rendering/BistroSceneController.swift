import SceneKit

final class BistroSceneController {
    private struct Constants {
        static let entityMoveAnimationDuration = 0.22
        static let timeoutPopScale: CGFloat = 1.2
        static let timeoutPopDuration = 0.16
        static let timeoutSettleScale: CGFloat = 1.0
        static let timeoutSettleDuration = 0.12
        static let timeoutHoldDuration = 0.45
        static let timeoutRiseDistance: CGFloat = 1.45
        static let timeoutRiseDuration = 1.85
        static let timeoutFadeDelay = 1.05
        static let timeoutFadeDuration = 0.8
    }

    let scene: SCNScene

    private var world: BistroWorld
    private var furnitureNodes: [Furniture.ID: SCNNode] = [:]
    private var entityNodes: [Entity.ID: SCNNode] = [:]
    private var selectionNode: SCNNode?
    private let effectsController: BistroEffectsController

    init(world: BistroWorld) {
        self.world = world
        self.scene = SceneBuilder.buildBaseScene(world: world)
        self.effectsController = BistroEffectsController(scene: scene)
        sync(to: world, animated: false)
    }

    func sync(to world: BistroWorld, animated: Bool = true) {
        let previousWorld = self.world
        self.world = world
        syncFurniture(world: world)
        syncEntities(world: world, animated: animated)
        syncTimeoutEffects(previousWorld: previousWorld, world: world)
        effectsController.sync(world: world, furnitureNodes: furnitureNodes, entityNodes: entityNodes)
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
                    SCNTransaction.animationDuration = Constants.entityMoveAnimationDuration
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

    private func syncTimeoutEffects(previousWorld: BistroWorld, world: BistroWorld) {
        guard world.lostCustomers > previousWorld.lostCustomers,
              let customer = timedOutCustomer(previousWorld: previousWorld, world: world),
              let node = entityNodes[customer.id]
        else {
            return
        }

        let effectNode = NodeFactory.timeoutEffectNode()
        node.addChildNode(effectNode)

        let pop = SCNAction.scale(to: Constants.timeoutPopScale, duration: Constants.timeoutPopDuration)
        pop.timingMode = .easeOut

        let settle = SCNAction.scale(to: Constants.timeoutSettleScale, duration: Constants.timeoutSettleDuration)
        settle.timingMode = .easeInEaseOut

        let hold = SCNAction.wait(duration: Constants.timeoutHoldDuration)

        let rise = SCNAction.moveBy(
            x: 0,
            y: Constants.timeoutRiseDistance,
            z: 0,
            duration: Constants.timeoutRiseDuration
        )
        rise.timingMode = .easeOut

        let lateFade = SCNAction.sequence([
            .wait(duration: Constants.timeoutFadeDelay),
            .fadeOut(duration: Constants.timeoutFadeDuration)
        ])
        let fade = SCNAction.group([rise, lateFade])
        fade.timingMode = .easeIn

        effectNode.runAction(.sequence([pop, settle, hold, fade, .removeFromParentNode()]))
    }

    private func timedOutCustomer(previousWorld: BistroWorld, world: BistroWorld) -> Entity? {
        let previousWaitingCustomerIDs = Set(
            previousWorld.entities
                .filter { $0.role == .customer && $0.customerState == .waitingForFood }
                .map(\.id)
        )
        let activeOrderCustomerIDs = Set(world.orders.map(\.customerID))

        return world.entities.first { entity in
            entity.role == .customer &&
            entity.customerState == .leaving &&
            previousWaitingCustomerIDs.contains(entity.id) &&
            !activeOrderCustomerIDs.contains(entity.id)
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
