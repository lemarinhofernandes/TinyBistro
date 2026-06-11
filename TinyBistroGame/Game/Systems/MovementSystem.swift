import Foundation

enum MovementSystem {
    private struct Constants {
        static let arrivalEpsilon: Float = 0.02
        static let diagonalCost: Double = 1.41421356237
    }

    private struct PathNode {
        let position: GridPosition
        let cost: Double
        let estimatedTotalCost: Double
    }

    static func advance(entity: inout Entity, world: BistroWorld, deltaTime: TimeInterval) -> Bool {
        guard let destination = entity.destination else {
            entity.path.removeAll()
            return false
        }

        if entity.position == destination && distance(from: entity.preciseXZ, to: destination.precisePosition()) <= Constants.arrivalEpsilon {
            snap(entity: &entity, to: destination)
            entity.destination = nil
            entity.path.removeAll()
            return true
        }

        if entity.path.last != destination {
            entity.path = path(from: entity.position, to: destination, entity: entity, world: world) ?? []
        }

        guard let waypoint = entity.path.first else {
            entity.destination = nil
            return false
        }

        let arrivedAtWaypoint = advance(entity: &entity, toward: waypoint, deltaTime: deltaTime)
        guard arrivedAtWaypoint else {
            return false
        }

        entity.path.removeFirst()

        if waypoint == destination && entity.path.isEmpty {
            entity.destination = nil
            return true
        }

        return false
    }

    private static func advance(entity: inout Entity, toward waypoint: GridPosition, deltaTime: TimeInterval) -> Bool {
        let target = waypoint.precisePosition()
        let current = entity.preciseXZ
        let delta = target - current
        let remainingDistance = length(delta)

        if remainingDistance <= Constants.arrivalEpsilon {
            snap(entity: &entity, to: waypoint)
            return true
        }

        let step = Float(entity.speed * deltaTime)
        guard step > 0 else {
            return false
        }

        let travel = min(step, remainingDistance)
        let direction = delta / remainingDistance
        entity.preciseXZ = current + direction * travel
        entity.position = GridPosition.from(precisePosition: entity.preciseXZ)

        if remainingDistance - travel <= Constants.arrivalEpsilon {
            snap(entity: &entity, to: waypoint)
            return true
        }

        return false
    }

    private static func path(
        from start: GridPosition,
        to destination: GridPosition,
        entity: Entity,
        world: BistroWorld
    ) -> [GridPosition]? {
        if start == destination {
            return [destination]
        }

        var open: [PathNode] = [
            PathNode(position: start, cost: 0, estimatedTotalCost: heuristic(from: start, to: destination))
        ]
        var cameFrom: [GridPosition: GridPosition] = [:]
        var bestCost: [GridPosition: Double] = [start: 0]
        var closed: Set<GridPosition> = []

        while !open.isEmpty {
            let currentIndex = open.indices.min { lhs, rhs in
                open[lhs].estimatedTotalCost < open[rhs].estimatedTotalCost
            } ?? open.startIndex
            let current = open.remove(at: currentIndex)

            if current.position == destination {
                return reconstructedPath(to: destination, cameFrom: cameFrom)
            }

            if closed.contains(current.position) {
                continue
            }
            closed.insert(current.position)

            for neighbor in current.position.neighbors(includeDiagonals: true) {
                guard canStep(
                    from: current.position,
                    to: neighbor,
                    destination: destination,
                    entity: entity,
                    world: world
                ) else {
                    continue
                }

                let tentativeCost = current.cost + movementCost(from: current.position, to: neighbor)
                guard tentativeCost < (bestCost[neighbor] ?? .infinity) else {
                    continue
                }

                cameFrom[neighbor] = current.position
                bestCost[neighbor] = tentativeCost
                open.append(
                    PathNode(
                        position: neighbor,
                        cost: tentativeCost,
                        estimatedTotalCost: tentativeCost + heuristic(from: neighbor, to: destination)
                    )
                )
            }
        }

        return nil
    }

    private static func canStep(
        from origin: GridPosition,
        to destinationCandidate: GridPosition,
        destination: GridPosition,
        entity: Entity,
        world: BistroWorld
    ) -> Bool {
        let allowsChair = entity.role == .customer && destinationCandidate == destination
        guard world.isWalkable(destinationCandidate, ignoring: entity.id, allowsChair: allowsChair) else {
            return false
        }

        let columnDelta = destinationCandidate.column - origin.column
        let rowDelta = destinationCandidate.row - origin.row
        guard columnDelta != 0 && rowDelta != 0 else {
            return true
        }

        let horizontal = GridPosition(column: origin.column + columnDelta, row: origin.row)
        let vertical = GridPosition(column: origin.column, row: origin.row + rowDelta)
        return world.isWalkable(horizontal, ignoring: entity.id) &&
            world.isWalkable(vertical, ignoring: entity.id)
    }

    private static func reconstructedPath(
        to destination: GridPosition,
        cameFrom: [GridPosition: GridPosition]
    ) -> [GridPosition] {
        var current = destination
        var path: [GridPosition] = [current]

        while let previous = cameFrom[current] {
            current = previous
            path.append(current)
        }

        path.reverse()
        return Array(path.dropFirst())
    }

    private static func snap(entity: inout Entity, to destination: GridPosition) {
        entity.preciseXZ = destination.precisePosition()
        entity.position = destination
    }

    private static func movementCost(from lhs: GridPosition, to rhs: GridPosition) -> Double {
        lhs.column != rhs.column && lhs.row != rhs.row ? Constants.diagonalCost : 1
    }

    private static func heuristic(from lhs: GridPosition, to rhs: GridPosition) -> Double {
        let dx = abs(lhs.column - rhs.column)
        let dy = abs(lhs.row - rhs.row)
        let diagonal = min(dx, dy)
        let straight = max(dx, dy) - diagonal
        return Double(straight) + Double(diagonal) * Constants.diagonalCost
    }

    private static func distance(from lhs: SIMD2<Float>, to rhs: SIMD2<Float>) -> Float {
        length(rhs - lhs)
    }

    private static func length(_ vector: SIMD2<Float>) -> Float {
        sqrt(vector.x * vector.x + vector.y * vector.y)
    }
}
