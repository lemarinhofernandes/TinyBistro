import Foundation

enum FurnitureKind: String, Sendable {
    case entrance = "Entrance"
    case table = "Table"
    case chair = "Chair"
    case stove = "Stove"
    case counter = "Counter"
}

struct Furniture: Identifiable, Hashable, Sendable {
    let id: UUID
    var kind: FurnitureKind
    var position: GridPosition
    var occupiedBy: Entity.ID?

    init(
        id: UUID = UUID(),
        kind: FurnitureKind,
        position: GridPosition,
        occupiedBy: Entity.ID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.position = position
        self.occupiedBy = occupiedBy
    }
}
