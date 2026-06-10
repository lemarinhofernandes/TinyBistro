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
        firstEntity(role: .staff)
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

        if entities.contains(where: { entity in
            entity.id != entityID && entity.position == position
        }) {
            return false
        }

        return true
    }

    func canPlaceFurniture(at position: GridPosition) -> Bool {
        guard gridSize.contains(position) else {
            return false
        }

        let hasFurniture = furniture.contains { $0.position == position }
        let hasEntity = entities.contains { $0.position == position }
        return !hasFurniture && !hasEntity
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
        let staff = Entity(
            name: "Mia",
            role: .staff,
            position: GridPosition(column: 3, row: 5),
            staffState: .idle
        )

        return BistroWorld(
            gridSize: GridSize(columns: 8, rows: 7),
            entities: [staff],
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
