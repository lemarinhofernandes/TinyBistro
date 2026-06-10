import Combine
import Foundation

@MainActor
final class BistroGame: ObservableObject {
    @Published private(set) var world: BistroWorld

    private var lastTickDate: Date?

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
        guard deltaTime > 0 else {
            CustomerSystem.spawnCustomer(in: &world)
            return
        }

        CookingSystem.tick(world: &world, deltaTime: deltaTime)
        CustomerSystem.tick(world: &world, deltaTime: deltaTime)
    }

    func handleTap(_ target: SceneTapTarget) {
        world.selectedTarget = target

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

    private func moveStaff(to position: GridPosition) {
        guard let staffIndex = world.entities.firstIndex(where: { $0.role == .staff }) else {
            return
        }

        world.entities[staffIndex].position = position
        world.postEvent("Mia moved to tile \(position.column), \(position.row).")
    }
}
