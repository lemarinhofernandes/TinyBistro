import Foundation

struct BistroWorld: Sendable {
    var gridSize: GridSize
    var entities: [Entity]
    var furniture: [Furniture]
    var orders: [Order]
    var selectedTarget: SceneTapTarget?
    var statusMessage: String
    var servedCustomers: Int
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
            servedCustomers: 0,
            nextCustomerNumber: 1
        )
    }
}
