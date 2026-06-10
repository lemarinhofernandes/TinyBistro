import Combine
import Foundation

@MainActor
final class BistroGame: ObservableObject {
    @Published private(set) var world: BistroWorld

    private var lastTickDate: Date?
    private var selectedBlueprint: FurnitureBlueprint?

    var placementBlueprint: FurnitureBlueprint? {
        selectedBlueprint
    }

    init(world: BistroWorld = .firstRoom) {
        self.world = world
    }

    func tick(now: Date = Date()) {
        let deltaTime: TimeInterval

        if let lastTickDate {
            deltaTime = min(0.25, now.timeIntervalSince(lastTickDate))
        } else {
            deltaTime = 0
        }

        lastTickDate = now
        tick(deltaTime: deltaTime)
    }

    func tick(deltaTime: TimeInterval) {
        guard world.sessionState == .inProgress else {
            return
        }

        guard deltaTime > 0 else {
            CustomerSystem.spawnCustomer(in: &world)
            return
        }

        CookingSystem.tick(world: &world, deltaTime: deltaTime)
        CustomerSystem.tick(world: &world, deltaTime: deltaTime)
    }

    func handleTap(_ target: SceneTapTarget) {
        world.selectedTarget = target

        if let selectedBlueprint {
            handlePlacementTap(target, blueprint: selectedBlueprint)
            return
        }

        switch target {
        case .furniture(let id):
            guard let furniture = world.furniture.first(where: { $0.id == id }) else {
                return
            }

            if furniture.kind == .stove || furniture.kind == .counter {
                CookingSystem.startCooking(world: &world)
            } else {
                world.postEvent("Selected \(furniture.kind.rawValue).")
            }

        case .entity(let id):
            guard let entity = world.entities.first(where: { $0.id == id }) else {
                return
            }

            if entity.role == .customer {
                CookingSystem.deliverReadyOrder(world: &world, customerID: id)
            } else {
                world.postEvent("\(entity.name) is \(entity.staffState?.displayName.lowercased() ?? "ready").")
            }

        case .tile(let position):
            guard world.gridSize.contains(position) else {
                return
            }

            moveStaff(to: position)
        }
    }

    func startCooking() {
        CookingSystem.startCooking(world: &world)
    }

    func deliverOrder() {
        CookingSystem.deliverReadyOrder(world: &world)
    }

    func openShop() {
        guard world.sessionState == .closed else {
            return
        }

        world.sessionState = .inProgress
        world.servedCustomers = 0
        world.lostCustomers = 0
        world.orders.removeAll()
        world.postEvent("Shop open! First guest is on the way.")
        CustomerSystem.spawnCustomer(in: &world)
    }

    func showComingSoon(_ feature: String) {
        world.postEvent("\(feature): em breve.")
    }

    func selectBlueprint(_ blueprint: FurnitureBlueprint?) {
        selectedBlueprint = blueprint

        if let blueprint {
            world.postEvent("Tap an empty tile to place \(blueprint.displayName).")
        } else {
            world.postEvent("Placement cancelled.")
        }
    }

    private func moveStaff(to position: GridPosition) {
        guard let staffIndex = world.entities.firstIndex(where: { $0.role == .staff }) else {
            return
        }

        guard world.isWalkable(position, ignoring: world.entities[staffIndex].id) else {
            world.postEvent("Tile blocked.")
            return
        }

        world.entities[staffIndex].position = position
        world.postEvent("Mia moved to tile \(position.column), \(position.row).")
    }

    private func handlePlacementTap(_ target: SceneTapTarget, blueprint: FurnitureBlueprint) {
        guard case .tile(let position) = target else {
            world.postEvent("Pick an empty floor tile.")
            return
        }

        if world.placeFurniture(blueprint, at: position) {
            selectedBlueprint = nil
        } else {
            world.postEvent("Can't place \(blueprint.displayName) there.")
        }
    }
}
