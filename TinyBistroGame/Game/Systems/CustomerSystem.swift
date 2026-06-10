import Foundation

enum CustomerSystem {
    private struct Constants {
        static let movementStepDuration: TimeInterval = 0.55
        static let seatedPauseDuration: TimeInterval = 0.75
        static let orderingDuration: TimeInterval = 1.0
        static let eatingDuration: TimeInterval = 2.0
    }

    static let movementStepDuration = Constants.movementStepDuration

    static func spawnCustomer(in world: inout BistroWorld) {
        guard world.sessionState == .inProgress,
              world.activeCustomer == nil,
              let entrance = world.firstFurniture(of: .entrance),
              let chair = world.firstFurniture(of: .chair, where: { $0.occupiedBy == nil })
        else {
            return
        }

        let customer = Entity(
            name: "Guest \(world.nextCustomerNumber)",
            role: .customer,
            position: entrance.position,
            destination: chair.position,
            customerState: .entering
        )

        world.nextCustomerNumber += 1
        world.entities.append(customer)
        world.postEvent(L10n.format(L10n.Event.customerHeadingToTable, customer.name))
    }

    static func tick(world: inout BistroWorld, deltaTime: TimeInterval) {
        guard let index = world.firstEntityIndex(role: .customer) else {
            if world.sessionState == .inProgress {
                spawnCustomer(in: &world)
            }
            return
        }

        world.entities[index].stateElapsedTime += deltaTime

        if world.entities[index].stateElapsedTime >= movementStepDuration,
           world.entities[index].destination != nil {
            world.entities[index].stateElapsedTime = 0
            var movingCustomer = world.entities[index]
            let arrived = MovementSystem.advance(entity: &movingCustomer, world: world)
            world.entities[index] = movingCustomer

            if arrived {
                handleArrival(world: &world, customerIndex: index)
            }

            return
        }

        let customer = world.entities[index]

        switch customer.customerState {
        case .seated where customer.stateElapsedTime >= Constants.seatedPauseDuration:
            world.entities[index].customerState = .ordering
            world.entities[index].stateElapsedTime = 0
            world.postEvent(L10n.format(L10n.Event.customerChoosingRecipe, customer.name))

        case .ordering where customer.stateElapsedTime >= Constants.orderingDuration:
            createOrderIfNeeded(world: &world, customerIndex: index)

        case .waitingForFood where customer.stateElapsedTime >= world.waitTimeout:
            sendCustomerAwayHungry(world: &world, customerIndex: index)

        case .eating where customer.stateElapsedTime >= Constants.eatingDuration:
            sendCustomerHome(world: &world, customerIndex: index)

        case .leaving where customer.destination == nil:
            finishVisit(world: &world, customerIndex: index)

        default:
            break
        }
    }

    private static func handleArrival(world: inout BistroWorld, customerIndex: Int) {
        switch world.entities[customerIndex].customerState {
        case .entering:
            world.entities[customerIndex].customerState = .seated
            world.entities[customerIndex].stateElapsedTime = 0

            if let chairIndex = world.furniture.firstIndex(where: {
                $0.kind == .chair && $0.position == world.entities[customerIndex].position
            }) {
                world.furniture[chairIndex].occupiedBy = world.entities[customerIndex].id
            }

            world.postEvent(L10n.format(L10n.Event.customerSatDown, world.entities[customerIndex].name))

        case .leaving:
            finishVisit(world: &world, customerIndex: customerIndex)

        default:
            break
        }
    }

    private static func createOrderIfNeeded(world: inout BistroWorld, customerIndex: Int) {
        let customer = world.entities[customerIndex]
        guard world.activeOrder(for: customer.id) == nil else {
            return
        }

        let order = Order(customerID: customer.id, recipe: .houseSoup)
        world.orders.append(order)
        world.entities[customerIndex].customerState = .waitingForFood
        world.entities[customerIndex].stateElapsedTime = 0
        world.postEvent(L10n.format(L10n.Event.customerOrdered, customer.name, order.recipe.name))
    }

    private static func sendCustomerHome(world: inout BistroWorld, customerIndex: Int) {
        guard let entrance = world.firstFurniture(of: .entrance) else {
            return
        }

        let customerID = world.entities[customerIndex].id
        world.entities[customerIndex].customerState = .leaving
        world.entities[customerIndex].destination = entrance.position
        world.entities[customerIndex].stateElapsedTime = 0

        if let chairIndex = world.firstFurnitureIndex(occupiedBy: customerID) {
            world.furniture[chairIndex].occupiedBy = nil
        }

        world.postEvent(L10n.format(L10n.Event.guestLeavingHappy, world.entities[customerIndex].name))
    }

    private static func sendCustomerAwayHungry(world: inout BistroWorld, customerIndex: Int) {
        guard let entrance = world.firstFurniture(of: .entrance) else {
            return
        }

        let customer = world.entities[customerIndex]
        let abandonedOrderIDs = Set(world.orders.filter { $0.customerID == customer.id }.map(\.id))

        world.entities[customerIndex].customerState = .leaving
        world.entities[customerIndex].destination = entrance.position
        world.entities[customerIndex].stateElapsedTime = 0
        world.orders.removeAll { $0.customerID == customer.id }
        world.lostCustomers += 1

        if let chairIndex = world.firstFurnitureIndex(occupiedBy: customer.id) {
            world.furniture[chairIndex].occupiedBy = nil
        }

        if let staffIndex = world.firstEntityIndex(role: .staff),
           staffStateReferencesAbandonedOrder(world.entities[staffIndex].staffState, abandonedOrderIDs: abandonedOrderIDs) {
            world.entities[staffIndex].staffState = .idle
        }

        world.postEvent(L10n.format(L10n.Event.guestLeftUnhappy, customer.name))
    }

    private static func finishVisit(world: inout BistroWorld, customerIndex: Int) {
        let name = world.entities[customerIndex].name
        let customerID = world.entities[customerIndex].id
        let completedMeal = world.orders.contains { $0.customerID == customerID && $0.status == .delivered }

        world.entities.remove(at: customerIndex)
        world.orders.removeAll { $0.customerID == customerID || $0.status == .completed }

        guard completedMeal else {
            return
        }

        world.servedCustomers += 1

        if world.servedCustomers >= world.targetServed {
            world.sessionState = .success
            world.postEvent(L10n.format(L10n.Event.goalReached, world.servedCustomers))
        } else {
            world.postEvent(L10n.format(L10n.Event.guestLeft, name, world.servedCustomers))
        }
    }

    private static func staffStateReferencesAbandonedOrder(_ staffState: StaffState?, abandonedOrderIDs: Set<Order.ID>) -> Bool {
        switch staffState {
        case .cooking(let orderID), .carryingDish(let orderID):
            return abandonedOrderIDs.contains(orderID)
        case .delivering(let orderID, _):
            return abandonedOrderIDs.contains(orderID)
        case .idle, .moving, nil:
            return false
        }
    }
}
