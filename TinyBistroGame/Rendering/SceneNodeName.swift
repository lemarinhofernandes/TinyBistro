import Foundation
import SceneKit

enum SceneNodeName {
    private static let separator = ":"

    static func tile(_ position: GridPosition) -> String {
        "tile\(separator)\(position.column)\(separator)\(position.row)"
    }

    static func furniture(_ id: UUID) -> String {
        "furniture\(separator)\(id.uuidString)"
    }

    static func entity(_ id: UUID) -> String {
        "entity\(separator)\(id.uuidString)"
    }

    /// Walks up the hit-tested node chain and resolves the nearest gameplay target.
    static func target(from node: SCNNode?) -> SceneTapTarget? {
        var current = node

        while let node = current {
            if let target = parse(node.name) {
                return target
            }

            current = node.parent
        }

        return nil
    }

    private static func parse(_ name: String?) -> SceneTapTarget? {
        guard let name else {
            return nil
        }

        let parts = name.split(separator: Character(separator)).map(String.init)
        guard let kind = parts.first else {
            return nil
        }

        switch kind {
        case "tile" where parts.count == 3:
            guard let column = Int(parts[1]), let row = Int(parts[2]) else {
                return nil
            }
            return .tile(GridPosition(column: column, row: row))

        case "furniture" where parts.count == 2:
            guard let id = UUID(uuidString: parts[1]) else {
                return nil
            }
            return .furniture(id)

        case "entity" where parts.count == 2:
            guard let id = UUID(uuidString: parts[1]) else {
                return nil
            }
            return .entity(id)

        default:
            return nil
        }
    }
}
