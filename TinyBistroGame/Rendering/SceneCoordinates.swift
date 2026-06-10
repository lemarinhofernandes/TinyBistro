import SceneKit

enum SceneCoordinates {
    /// Converts a grid tile to a centered SceneKit position.
    ///
    /// The grid origin lives in the middle of the room so both rendering and
    /// hit testing stay symmetric around the playable space.
    static func worldPosition(for position: GridPosition, in world: BistroWorld, y: Float) -> SCNVector3 {
        let x = Float(position.column) - Float(world.gridSize.columns - 1) / 2
        let z = Float(position.row) - Float(world.gridSize.rows - 1) / 2
        return SCNVector3(x, y, z)
    }
}
