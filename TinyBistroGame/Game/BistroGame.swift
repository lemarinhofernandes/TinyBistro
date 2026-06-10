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
        let deltaTime = TimeUtils.clampedDeltaTime(since: lastTickDate, now: now)
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
        world.postEvent(L10n.string(L10n.Event.shopOpened))
        CustomerSystem.spawnCustomer(in: &world)
    }

    func showComingSoon(_ feature: String) {
        world.postEvent(L10n.format(L10n.Event.comingSoon, feature))
    }

    func selectBlueprint(_ blueprint: FurnitureBlueprint?) {
        selectedBlueprint = blueprint

        if let blueprint {
            world.postEvent(L10n.format(L10n.Event.placementPrompt, blueprint.displayName))
        } else {
            world.postEvent(L10n.string(L10n.Event.placementCancelled))
        }
    }

    private func moveStaff(to position: GridPosition) {
        guard let staffIndex = world.firstEntityIndex(role: .staff) else {
            return
        }

        guard world.isWalkable(position, ignoring: world.entities[staffIndex].id) else {
            world.postEvent(L10n.string(L10n.Event.tileBlocked))
            return
        }

        world.entities[staffIndex].position = position
        world.postEvent(L10n.format(L10n.Event.staffMoved, world.entities[staffIndex].name, position.column, position.row))
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
