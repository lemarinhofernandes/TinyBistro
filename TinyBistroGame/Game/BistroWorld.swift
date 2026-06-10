import Foundation

enum SessionState: Sendable {
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
            sessionState: .inProgress,
            nextCustomerNumber: 1
        )
    }
}
