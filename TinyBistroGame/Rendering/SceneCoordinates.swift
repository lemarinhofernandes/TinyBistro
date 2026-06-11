import SceneKit

enum SceneCoordinates {
    private static func centeredOffset(for world: BistroWorld) -> SIMD2<Float> {
        SIMD2<Float>(
            Float(world.gridSize.columns - 1) / 2,
            Float(world.gridSize.rows - 1) / 2
        )
    }

    /// Converts a grid tile to a centered SceneKit position.
    ///
    /// The grid origin lives in the middle of the room so both rendering and
    /// hit testing stay symmetric around the playable space.
    static func worldPosition(for position: GridPosition, in world: BistroWorld, y: Float) -> SCNVector3 {
        worldPosition(for: position.precisePosition(), in: world, y: y)
    }

    static func worldPosition(for precisePosition: SIMD2<Float>, in world: BistroWorld, y: Float) -> SCNVector3 {
        let offset = centeredOffset(for: world)
        let x = precisePosition.x - offset.x
        let z = precisePosition.y - offset.y
        return SCNVector3(x, y, z)
    }

    static func worldPosition(for entity: Entity, in world: BistroWorld, y: Float) -> SCNVector3 {
        worldPosition(for: entity.preciseXZ, in: world, y: y)
    }
}
