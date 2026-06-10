import Foundation

enum MovementSystem {
    static func advance(entity: inout Entity) -> Bool {
        guard let destination = entity.destination else {
            return false
        }

        if entity.position == destination {
            entity.destination = nil
            return true
        }

        entity.position = entity.position.movedToward(destination)

        if entity.position == destination {
            entity.destination = nil
            return true
        }

        return false
    }
}
