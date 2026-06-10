import Foundation

enum FurnitureBlueprint: String, CaseIterable, Identifiable, Sendable {
    case table
    case chair
    case stove
    case counter
    case entrance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .table:
            return L10n.string(L10n.Furniture.table)
        case .chair:
            return L10n.string(L10n.Furniture.chair)
        case .stove:
            return L10n.string(L10n.Furniture.stove)
        case .counter:
            return L10n.string(L10n.Furniture.counter)
        case .entrance:
            return L10n.string(L10n.Furniture.entrance)
        }
    }

    var kind: FurnitureKind {
        switch self {
        case .table:
            return .table
        case .chair:
            return .chair
        case .stove:
            return .stove
        case .counter:
            return .counter
        case .entrance:
            return .entrance
        }
    }

    var cost: Int {
        switch self {
        case .chair:
            return 10
        case .table:
            return 20
        case .counter:
            return 25
        case .stove:
            return 40
        case .entrance:
            return 0
        }
    }

    func furniture(at position: GridPosition) -> Furniture {
        Furniture(kind: kind, position: position)
    }
}
