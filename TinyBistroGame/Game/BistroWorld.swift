import Foundation

enum SessionState: Sendable {
    case closed
    case inProgress
    case success
}

struct BistroWorld: Sendable {
    var gridSize: GridSize
    var entities: [Entity]
    var furniture: [Furniture]
    var orders: [Order]
    var selectedTarget: SceneTapTarget?
    var statusMessage: String
    var lastEventID: Int
    var servedCustomers: Int
    var lostCustomers: Int
    var targetServed: Int
    var waitTimeout: TimeInterval
    var sessionState: SessionState
    var nextCustomerNumber: Int
    var catalog: [FurnitureBlueprint]

    var staff: Entity? {
        entities.first { $0.role == .staff }
    }

    var activeCustomer: Entity? {
        entities.first { $0.role == .customer }
    }

    var activeOrder: Order? {
        orders.first { $0.status != .completed }
    }

    mutating func postEvent(_ text: String) {
        guard statusMessage != text else {
            return
        }

        lastEventID += 1
        statusMessage = text
    }

    func isWalkable(
        _ position: GridPosition,
        ignoring entityID: Entity.ID? = nil,
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
        postEvent("Placed \(blueprint.displayName).")
        return true
    }

    static var firstRoom: BistroWorld {
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
            statusMessage: "Tap the stove when the first order appears.",
            lastEventID: 0,
            servedCustomers: 0,
            lostCustomers: 0,
            targetServed: 5,
            waitTimeout: 12,
            sessionState: .closed,
            nextCustomerNumber: 1,
            catalog: FurnitureBlueprint.allCases
        )
    }
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
