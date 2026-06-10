import Foundation

enum CookingSystem {
    static func tick(world: inout BistroWorld, deltaTime: TimeInterval) {
        guard let orderIndex = world.orders.firstIndex(where: { $0.status == .cooking }) else {
            return
        }

        world.orders[orderIndex].remainingTime = max(0, world.orders[orderIndex].remainingTime - deltaTime)

        if world.orders[orderIndex].remainingTime == 0 {
            world.orders[orderIndex].status = .ready
            setStaffState(.carryingDish(orderID: world.orders[orderIndex].id), in: &world)
            world.postEvent("\(world.orders[orderIndex].recipe.name) is ready. Tap the customer.")
        }
    }

    static func startCooking(world: inout BistroWorld) {
        guard let orderIndex = world.orders.firstIndex(where: { $0.status == .created }) else {
            world.postEvent("No order is waiting yet.")
            return
        }

        world.orders[orderIndex].status = .cooking
        world.orders[orderIndex].remainingTime = world.orders[orderIndex].recipe.duration
        setStaffState(.cooking(orderID: world.orders[orderIndex].id), in: &world)
        world.postEvent("Cooking \(world.orders[orderIndex].recipe.name)...")
    }

    static func deliverReadyOrder(world: inout BistroWorld, customerID: Entity.ID? = nil) {
        guard let orderIndex = world.orders.firstIndex(where: { order in
            order.status == .ready && (customerID == nil || order.customerID == customerID)
        }) else {
            world.postEvent("No ready dish to deliver.")
            return
        }

        let order = world.orders[orderIndex]
        guard let customerIndex = world.entities.firstIndex(where: { $0.id == order.customerID }) else {
            return
        }

        world.orders[orderIndex].status = .delivered
        world.entities[customerIndex].customerState = .eating
        world.entities[customerIndex].stateElapsedTime = 0
        setStaffState(.idle, in: &world)
        world.postEvent("\(world.entities[customerIndex].name) is eating \(order.recipe.name).")
    }

    private static func setStaffState(_ state: StaffState, in world: inout BistroWorld) {
        guard let staffIndex = world.entities.firstIndex(where: { $0.role == .staff }) else {
            return
        }

        world.entities[staffIndex].staffState = state
    }
}
