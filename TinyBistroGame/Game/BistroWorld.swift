import Foundation

enum SessionState: Sendable {
    case closed
    case inProgress
    case success
}

/// Authoritative gameplay snapshot for the entire session.
///
/// Rendering mirrors this state, but does not own it. Systems read and mutate
/// this type directly, so the helpers below keep common queries and invariants
/// in one place.
struct BistroWorld: Sendable {
    /// Tile grid used by movement and placement.
    var gridSize: GridSize
    /// All live entities currently in the room.
    var entities: [Entity]
    /// Static and placed furniture pieces.
    var furniture: [Furniture]
    /// All orders in flight or already resolved.
    var orders: [Order]
    /// Last tapped scene target, used by the HUD and renderer.
    var selectedTarget: SceneTapTarget?
    /// Most recent event text surfaced to the HUD.
    var statusMessage: String
    /// Sequence number for UI updates so identical messages still animate.
    var lastEventID: Int
    /// Successful visits counted so far.
    var servedCustomers: Int
    /// Visits that left without being served.
    var lostCustomers: Int
    /// Win condition for the current session.
    var targetServed: Int
    /// Maximum wait time before a seated guest gives up.
    var waitTimeout: TimeInterval
    /// Session lifecycle state.
    var sessionState: SessionState
    /// Number assigned to the next spawned customer.
    var nextCustomerNumber: Int
    /// Available furniture blueprints shown in the HUD.
    var catalog: [FurnitureBlueprint]

    var staff: Entity? {
        entities.first { $0.role.isManager } ?? entities.first { $0.role.isStaff }
    }

    var activeCustomer: Entity? {
        firstEntity(role: .customer)
    }

    var activeOrder: Order? {
        orders.first { $0.status != .completed }
    }

    mutating func postEvent(_ text: String) {
        lastEventID += 1
        statusMessage = text
    }

    func entity(id: EntityID) -> Entity? {
        entities.first { $0.id == id }
    }

    func firstEntity(role: EntityRole) -> Entity? {
        entities.first { $0.role == role }
    }

    func firstEntityIndex(role: EntityRole) -> Int? {
        entities.firstIndex { $0.role == role }
    }

    func firstEntityIndex(where predicate: (Entity) -> Bool) -> Int? {
        entities.firstIndex(where: predicate)
    }

    func furniture(id: FurnitureID) -> Furniture? {
        furniture.first { $0.id == id }
    }

    func firstFurniture(of kind: FurnitureKind) -> Furniture? {
        furniture.first { $0.kind == kind }
    }

    func firstFurniture(of kind: FurnitureKind, where predicate: (Furniture) -> Bool) -> Furniture? {
        furniture.first { $0.kind == kind && predicate($0) }
    }

    func firstFurnitureIndex(of kind: FurnitureKind) -> Int? {
        furniture.firstIndex { $0.kind == kind }
    }

    func firstFurnitureIndex(of kind: FurnitureKind, where predicate: (Furniture) -> Bool) -> Int? {
        furniture.firstIndex { $0.kind == kind && predicate($0) }
    }

    func firstFurniture(occupiedBy entityID: EntityID) -> Furniture? {
        furniture.first { $0.occupiedBy == entityID }
    }

    func firstFurnitureIndex(occupiedBy entityID: EntityID) -> Int? {
        furniture.firstIndex { $0.occupiedBy == entityID }
    }

    func order(id: OrderID) -> Order? {
        orders.first { $0.id == id }
    }

    func firstOrder(status: OrderStatus) -> Order? {
        orders.first { $0.status == status }
    }

    func activeOrder(for customerID: EntityID? = nil) -> Order? {
        orders.first { order in
            order.status != .completed &&
            (customerID == nil || order.customerID == customerID)
        }
    }

    func orderIsAssignedToStaff(_ orderID: OrderID) -> Bool {
        entities.contains { entity in
            switch entity.taskKind {
            case .cooking(let assignedOrderID),
                 .pickingUpDish(let assignedOrderID, _),
                 .delivering(let assignedOrderID, _):
                return assignedOrderID == orderID
            case nil:
                return false
            }
        }
    }

    func firstFreeChair() -> Furniture? {
        firstFurniture(of: .chair, where: { $0.occupiedBy == nil })
    }

    func nearestTable(to chair: Furniture) -> Furniture? {
        furniture
            .filter(\.isTable)
            .min(by: { lhs, rhs in
                distanceSquared(from: chair.position, to: lhs.position) <
                distanceSquared(from: chair.position, to: rhs.position)
            })
    }

    func entranceFurniture() -> Furniture? {
        firstFurniture(of: .entrance)
    }

    func firstAvailableChefIndex() -> Int? {
        firstEntityIndex {
            $0.role == .chef &&
            $0.taskKind == nil &&
            $0.destination == nil &&
            ($0.staffState == nil || $0.staffState == .idle)
        }
    }

    func firstAvailableManagerIndex() -> Int? {
        firstEntityIndex {
            $0.role.isManager &&
            $0.taskKind == nil &&
            $0.destination == nil &&
            ($0.staffState == nil || $0.staffState == .idle)
        }
    }

    func firstAvailableWaiterIndex() -> Int? {
        firstEntityIndex {
            $0.role == .waiter &&
            $0.taskKind == nil &&
            $0.destination == nil &&
            ($0.staffState == nil || $0.staffState == .idle)
        }
    }

    func canStartCooking() -> Bool {
        firstOrder(status: .created) != nil && firstAvailableManagerIndex() != nil
    }

    func canDeliverReadyOrder(customerID: EntityID? = nil) -> Bool {
        firstAvailableManagerIndex() != nil &&
        orders.contains { order in
            order.status == .ready &&
            !orderIsAssignedToStaff(order.id) &&
            (customerID == nil || order.customerID == customerID)
        }
    }

    func canAutoStartCooking() -> Bool {
        firstOrder(status: .created) != nil && firstAvailableChefIndex() != nil
    }

    func canAutoDeliverReadyOrder(customerID: EntityID? = nil) -> Bool {
        firstAvailableWaiterIndex() != nil &&
        orders.contains { order in
            order.status == .ready &&
            !orderIsAssignedToStaff(order.id) &&
            (customerID == nil || order.customerID == customerID)
        }
    }

    func deliveryPickupFurniture() -> Furniture? {
        firstFurniture(of: .counter) ?? firstFurniture(of: .stove)
    }

    func actionPosition(near furniture: Furniture, from origin: GridPosition, ignoring entityID: EntityID? = nil) -> GridPosition? {
        furniture.position
            .neighbors(includeDiagonals: true)
            .filter { isWalkable($0, ignoring: entityID) }
            .min { lhs, rhs in
                distanceSquared(from: origin, to: lhs) < distanceSquared(from: origin, to: rhs)
            }
    }

    func actionPosition(for customer: Entity, ignoring entityID: EntityID? = nil) -> GridPosition {
        guard let chair = firstFurniture(of: .chair, where: { $0.occupiedBy == customer.id }),
              let table = nearestTable(to: chair)
        else {
            return customer.position
        }

        return actionPosition(near: table, from: customer.position, ignoring: entityID) ?? customer.position
    }

    func isWalkable(
        _ position: GridPosition,
        ignoring entityID: EntityID? = nil,
        allowsChair: Bool = false
    ) -> Bool {
        guard gridSize.contains(position) else {
            return false
        }

        if furniture.contains(where: { furniture in
            furniture.position == position && furniture.blocksWalking(allowsChair: allowsChair)
        }) {
            return false
        }

        return true
    }

    func isWalkable(
        _ precisePosition: SIMD2<Float>,
        ignoring entityID: EntityID? = nil,
        allowsChair: Bool = false
    ) -> Bool {
        let position = GridPosition.from(precisePosition: precisePosition)
        return isWalkable(position, ignoring: entityID, allowsChair: allowsChair)
    }

    func canPlaceFurniture(at position: GridPosition) -> Bool {
        guard gridSize.contains(position) else {
            return false
        }

        return !furniture.contains { $0.position == position }
    }

    mutating func placeFurniture(_ blueprint: FurnitureBlueprint, at position: GridPosition) -> Bool {
        guard canPlaceFurniture(at: position) else {
            return false
        }

        furniture.append(blueprint.furniture(at: position))
        postEvent(L10n.format(L10n.Event.placedFurniture, blueprint.displayName))
        return true
    }

    nonisolated static let firstRoom: BistroWorld = {
        let entrance = Furniture(kind: .entrance, position: GridPosition(column: 0, row: 3))
        let table = Furniture(kind: .table, position: GridPosition(column: 5, row: 3))
        let chair = Furniture(kind: .chair, position: GridPosition(column: 5, row: 4))
        let stove = Furniture(kind: .stove, position: GridPosition(column: 2, row: 1))
        let counter = Furniture(kind: .counter, position: GridPosition(column: 3, row: 1))
        let manager = Entity(
            name: "Duda Manager",
            role: .manager,
            position: GridPosition(column: 2, row: 3),
            speed: 2.35,
            staffState: .idle
        )
        let chef = Entity(
            name: "Mia Chef",
            role: .chef,
            position: GridPosition(column: 1, row: 1),
            speed: 2.55,
            staffState: .idle
        )
        let waiter = Entity(
            name: "Leo Waiter",
            role: .waiter,
            position: GridPosition(column: 4, row: 1),
            speed: 2.75,
            staffState: .idle
        )

        return BistroWorld(
            gridSize: GridSize(columns: 8, rows: 7),
            entities: [manager, chef, waiter],
            furniture: [entrance, table, chair, stove, counter],
            orders: [],
            selectedTarget: nil,
            statusMessage: L10n.string(L10n.Event.firstOrderPrompt),
            lastEventID: 0,
            servedCustomers: 0,
            lostCustomers: 0,
            targetServed: 5,
            waitTimeout: 12,
            sessionState: .closed,
            nextCustomerNumber: 1,
            catalog: FurnitureBlueprint.allCases
        )
    }()
}

private extension Furniture {
    func blocksWalking(allowsChair: Bool) -> Bool {
        switch kind {
        case .stove, .counter, .table:
            return true
        case .chair:
            return !allowsChair
        case .entrance:
            return false
        }
    }
}

private func distanceSquared(from lhs: GridPosition, to rhs: GridPosition) -> Int {
    let dx = lhs.column - rhs.column
    let dy = lhs.row - rhs.row
    return dx * dx + dy * dy
}
