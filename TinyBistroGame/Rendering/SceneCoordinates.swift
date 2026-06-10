import SceneKit

enum SceneCoordinates {
    static func worldPosition(for position: GridPosition, in world: BistroWorld, y: Float) -> SCNVector3 {
        let x = Float(position.column) - Float(world.gridSize.columns - 1) / 2
        let z = Float(position.row) - Float(world.gridSize.rows - 1) / 2
        return SCNVector3(x, y, z)
    }
}
