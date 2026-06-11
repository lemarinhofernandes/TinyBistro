import Foundation

enum CustomerSystem {
    private struct Constants {
        static let customerSpeed = 1.35
        static let seatedPauseDuration: TimeInterval = 0.75
        static let orderingDuration: TimeInterval = 1.0
        static let eatingDuration: TimeInterval = 2.0
    }

    static func spawnCustomer(in world: inout BistroWorld) {
        guard world.sessionState == .inProgress,
              world.activeCustomer == nil,
              let entrance = world.entranceFurniture(),
              let chair = world.firstFreeChair()
        else {
            return
        }

        let customer = Entity(
            name: "Guest \(world.nextCustomerNumber)",
            role: .customer,
            position: entrance.position,
            speed: Constants.customerSpeed,
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

        if world.entities[index].destination != nil {
            var movingCustomer = world.entities[index]
            let arrived = MovementSystem.advance(
                entity: &movingCustomer,
                world: world,
                deltaTime: deltaTime
            )
            world.entities[index] = movingCustomer

            if arrived {
                handleArrival(world: &world, customerIndex: index)
            }

            return
        }

        world.entities[index].stateElapsedTime += deltaTime

        let customer = world.entities[index]

        switch customer.customerState {
        case .seated where customer.stateElapsedTime >= Constants.seatedPauseDuration:
            world.entities[index].customerState = .ordering
            world.entities[index].stateElapsedTime = 0
            world.postEvent(L10n.format(L10n.Event.customerChoosingRecipe, customer.name))

        case .ordering where customer.stateElapsedTime >= Constants.orderingDuration:
            createOrderIfNeeded(world: &world, customerIndex: index)

        case .entering where customer.destination == nil && customer.stateElapsedTime >= world.waitTimeout:
            sendCustomerAwayHungry(world: &world, customerIndex: index)

        case .waitingForSeat where customer.stateElapsedTime >= world.waitTimeout:
            sendCustomerAwayHungry(world: &world, customerIndex: index)

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
        case .entering, .waitingForSeat:
            let customer = world.entities[customerIndex]
            guard let chairIndex = world.firstFurnitureIndex(
                of: .chair,
                where: { $0.position == customer.position }
            ) else {
                return
            }

            world.furniture[chairIndex].occupiedBy = customer.id

            if let table = world.nearestTable(to: world.furniture[chairIndex]),
               let tableIndex = world.firstFurnitureIndex(of: .table, where: { $0.id == table.id }) {
                world.furniture[tableIndex].occupiedBy = customer.id
            }

            world.entities[customerIndex].customerState = .seated
            world.entities[customerIndex].stateElapsedTime = 0

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
        guard let entrance = world.entranceFurniture() else {
            return
        }

        let customerID = world.entities[customerIndex].id
        world.entities[customerIndex].customerState = .leaving
        world.entities[customerIndex].destination = entrance.position
        world.entities[customerIndex].path.removeAll()
        world.entities[customerIndex].stateElapsedTime = 0

        releaseDiningResources(world: &world, customerID: customerID)

        world.postEvent(L10n.format(L10n.Event.guestLeavingHappy, world.entities[customerIndex].name))
    }

    private static func sendCustomerAwayHungry(world: inout BistroWorld, customerIndex: Int) {
        guard let entrance = world.entranceFurniture() else {
            return
        }

        let customer = world.entities[customerIndex]
        let abandonedOrderIDs = Set(world.orders.filter { $0.customerID == customer.id }.map(\.id))

        world.entities[customerIndex].customerState = .leaving
        world.entities[customerIndex].destination = entrance.position
        world.entities[customerIndex].path.removeAll()
        world.entities[customerIndex].stateElapsedTime = 0
        world.orders.removeAll { $0.customerID == customer.id }
        world.lostCustomers += 1

        releaseDiningResources(world: &world, customerID: customer.id)

        clearAbandonedStaffTasks(world: &world, abandonedOrderIDs: abandonedOrderIDs)

        world.postEvent(L10n.format(L10n.Event.guestLeftUnhappy, customer.name))
    }

    private static func finishVisit(world: inout BistroWorld, customerIndex: Int) {
        let name = world.entities[customerIndex].name
        let customerID = world.entities[customerIndex].id
        let completedMeal = world.orders.contains { $0.customerID == customerID && $0.status == .delivered }

        if completedMeal {
            for orderIndex in world.orders.indices where world.orders[orderIndex].customerID == customerID {
                world.orders[orderIndex].status = .completed
            }
        }

        world.entities.remove(at: customerIndex)
        releaseDiningResources(world: &world, customerID: customerID)
        world.orders.removeAll { $0.customerID == customerID }

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

    private static func releaseDiningResources(world: inout BistroWorld, customerID: Entity.ID) {
        if let chairIndex = world.firstFurnitureIndex(of: .chair, where: { $0.occupiedBy == customerID }) {
            world.furniture[chairIndex].occupiedBy = nil
        }

        if let tableIndex = world.firstFurnitureIndex(of: .table, where: { $0.occupiedBy == customerID }) {
            world.furniture[tableIndex].occupiedBy = nil
        }
    }

    private static func clearAbandonedStaffTasks(world: inout BistroWorld, abandonedOrderIDs: Set<Order.ID>) {
        for index in world.entities.indices where world.entities[index].role.isStaff {
            guard staffTaskReferencesAbandonedOrder(world.entities[index].taskKind, abandonedOrderIDs: abandonedOrderIDs) ||
                  staffStateReferencesAbandonedOrder(world.entities[index].staffState, abandonedOrderIDs: abandonedOrderIDs)
            else {
                continue
            }

            world.entities[index].taskKind = nil
            world.entities[index].taskRemaining = nil
            world.entities[index].taskDuration = nil
            world.entities[index].destination = nil
            world.entities[index].path.removeAll()
            world.entities[index].staffState = .idle
        }
    }

    private static func staffTaskReferencesAbandonedOrder(_ taskKind: StaffTaskKind?, abandonedOrderIDs: Set<Order.ID>) -> Bool {
        switch taskKind {
        case .cooking(let orderID), .pickingUpDish(let orderID, _), .delivering(let orderID, _):
            return abandonedOrderIDs.contains(orderID)
        case nil:
            return false
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
