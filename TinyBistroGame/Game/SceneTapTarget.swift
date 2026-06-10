import Foundation

/// Canonical tap routing target produced by SceneKit hit testing.
///
/// The renderer converts node names into one of these values, and `BistroGame`
/// decides how the gameplay should react.
enum SceneTapTarget: Hashable, Sendable {
    case tile(GridPosition)
    case furniture(Furniture.ID)
    case entity(Entity.ID)
}
