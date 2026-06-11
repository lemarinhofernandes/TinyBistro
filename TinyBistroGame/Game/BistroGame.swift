import Combine
import Foundation

@MainActor
final class BistroGame: ObservableObject {
    @Published private(set) var world: BistroWorld
    var isPaused = false

    private var lastTickDate: Date?
    private var selectedBlueprint: FurnitureBlueprint?

    var placementBlueprint: FurnitureBlueprint? {
        selectedBlueprint
    }

    init(world: BistroWorld = .firstRoom) {
        self.world = world
    }

    func tick(now: Date = Date()) {
        let deltaTime = TimeUtils.clampedDeltaTime(since: lastTickDate, now: now)
        lastTickDate = now
        tick(deltaTime: deltaTime)
    }

    func tick(deltaTime: TimeInterval) {
        guard !isPaused else {
            return
        }

        guard deltaTime > 0 else {
            if world.sessionState == .inProgress {
                CustomerSystem.spawnCustomer(in: &world)
            }
            return
        }

        advanceStaffMovement(deltaTime: deltaTime)

        guard world.sessionState == .inProgress else {
            return
        }

        CookingSystem.tick(world: &world, deltaTime: deltaTime)
        CustomerSystem.tick(world: &world, deltaTime: deltaTime)
    }

    func handleTap(_ target: SceneTapTarget) {
        guard !isPaused else {
            return
        }

        world.selectedTarget = target

        if let selectedBlueprint {
            handlePlacementTap(target, blueprint: selectedBlueprint)
            return
        }

        switch target {
        case .furniture(let id):
            guard let furniture = world.furniture(id: id) else {
                return
            }

            if furniture.kind == .stove || furniture.kind == .counter {
                CookingSystem.startCooking(world: &world)
            } else {
                world.postEvent(L10n.format(L10n.Event.selectedFurniture, furniture.kind.displayName))
            }

        case .entity(let id):
            guard let entity = world.entity(id: id) else {
                return
            }

            if entity.role == .customer {
                CookingSystem.deliverReadyOrder(world: &world, customerID: id)
            } else {
                world.postEvent(
                    L10n.format(
                        L10n.Event.staffState,
                        entity.name,
                        entity.staffState?.displayName.lowercased() ?? L10n.string(L10n.HUD.ready).lowercased()
                    )
                )
            }

        case .tile(let position):
            guard world.gridSize.contains(position) else {
                return
            }

            moveStaff(to: position)
        }
    }

    func startCooking() {
        guard !isPaused else {
            return
        }

        CookingSystem.startCooking(world: &world)
    }

    func deliverOrder() {
        guard !isPaused else {
            return
        }

        CookingSystem.deliverReadyOrder(world: &world)
    }

    func openShop() {
        guard !isPaused else {
            return
        }

        guard world.sessionState != .inProgress else {
            return
        }

        world.sessionState = .inProgress
        world.servedCustomers = 0
        world.lostCustomers = 0
        world.orders.removeAll()
        world.entities.removeAll { $0.role == .customer }
        world.postEvent(L10n.string(L10n.Event.shopOpened))
        CustomerSystem.spawnCustomer(in: &world)
    }

    func showComingSoon(_ feature: String) {
        guard !isPaused else {
            return
        }

        world.postEvent(L10n.format(L10n.Event.comingSoon, feature))
    }

    func selectBlueprint(_ blueprint: FurnitureBlueprint?) {
        guard !isPaused else {
            return
        }

        selectedBlueprint = blueprint

        if let blueprint {
            world.postEvent(L10n.format(L10n.Event.placementPrompt, blueprint.displayName))
        } else {
            world.postEvent(L10n.string(L10n.Event.placementCancelled))
        }
    }

    private func moveStaff(to position: GridPosition) {
        guard let staffIndex = world.firstEntityIndex(where: {
            $0.role.isManager
        }) else {
            return
        }

        guard world.isWalkable(position, ignoring: world.entities[staffIndex].id) else {
            world.postEvent(L10n.string(L10n.Event.tileBlocked))
            return
        }

        if world.entities[staffIndex].taskKind != nil {
            CookingSystem.cancelManagerTask(world: &world)
        }

        guard let managerIndex = world.firstEntityIndex(where: { $0.role.isManager }) else {
            return
        }

        if world.entities[managerIndex].position == position {
            world.entities[managerIndex].destination = nil
            world.entities[managerIndex].path.removeAll()
            world.entities[managerIndex].staffState = .idle
            return
        }

        world.entities[managerIndex].destination = position
        world.entities[managerIndex].path.removeAll()
        world.entities[managerIndex].staffState = .moving
        world.entities[managerIndex].stateElapsedTime = 0
        world.postEvent(L10n.format(L10n.Event.staffMoved, world.entities[managerIndex].name, position.column, position.row))
    }

    private func advanceStaffMovement(deltaTime: TimeInterval) {
        guard let staffIndex = world.firstEntityIndex(where: {
            $0.role.isManager && $0.taskKind == nil && $0.destination != nil
        })
        else {
            return
        }

        var staff = world.entities[staffIndex]
        let arrived = MovementSystem.advance(entity: &staff, world: world, deltaTime: deltaTime)
        world.entities[staffIndex] = staff

        if arrived || staff.destination == nil {
            world.entities[staffIndex].staffState = .idle
        }
    }

    private func handlePlacementTap(_ target: SceneTapTarget, blueprint: FurnitureBlueprint) {
        guard case .tile(let position) = target else {
            world.postEvent(L10n.string(L10n.Event.pickEmptyFloorTile))
            return
        }

        if world.placeFurniture(blueprint, at: position) {
            selectedBlueprint = nil
        } else {
            world.postEvent(L10n.format(L10n.Event.cannotPlace, blueprint.displayName))
        }
    }
}
