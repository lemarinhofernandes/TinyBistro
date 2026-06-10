import Foundation

enum MovementSystem {
    static func advance(entity: inout Entity, world: BistroWorld) -> Bool {
        guard let destination = entity.destination else {
            return false
        }

        if entity.position == destination {
            entity.destination = nil
            return true
        }

        let nextPosition = entity.position.movedToward(destination)
        let allowsChair = entity.role == .customer && nextPosition == destination
        guard world.isWalkable(nextPosition, ignoring: entity.id, allowsChair: allowsChair) else {
            entity.destination = nil
            return false
        }

        entity.position = nextPosition

        if entity.position == destination {
            entity.destination = nil
            return true
        }

        return false
    }
}
