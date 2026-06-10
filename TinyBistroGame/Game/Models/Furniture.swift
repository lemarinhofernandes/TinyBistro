import Foundation

enum FurnitureKind: String, Sendable {
    case entrance = "Entrance"
    case table = "Table"
    case chair = "Chair"
    case stove = "Stove"
    case counter = "Counter"
}

struct Furniture: Identifiable, Hashable, Sendable {
    let id: FurnitureID
    var kind: FurnitureKind
    var position: GridPosition
    var occupiedBy: Entity.ID?

    init(
        id: FurnitureID = UUID(),
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

extension FurnitureKind {
    var displayName: String {
        switch self {
        case .entrance:
            return L10n.string(L10n.Furniture.entrance)
        case .table:
            return L10n.string(L10n.Furniture.table)
        case .chair:
            return L10n.string(L10n.Furniture.chair)
        case .stove:
            return L10n.string(L10n.Furniture.stove)
        case .counter:
            return L10n.string(L10n.Furniture.counter)
        }
    }
}
