import Foundation

enum SceneTapTarget: Hashable, Sendable {
    case tile(GridPosition)
    case furniture(Furniture.ID)
    case entity(Entity.ID)
}
