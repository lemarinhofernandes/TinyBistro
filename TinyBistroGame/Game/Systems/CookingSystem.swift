import Foundation

enum CookingSystem {
    private struct Constants {
        static let deliveryHandoffDuration: TimeInterval = 0.45
    }

    static func tick(world: inout BistroWorld, deltaTime: TimeInterval) {
        assignAutomaticTasks(world: &world)
        advanceStaffTasks(world: &world, deltaTime: deltaTime)
        advanceUnassignedCookingOrders(world: &world, deltaTime: deltaTime)
    }

    static func startCooking(world: inout BistroWorld) {
        guard let managerIndex = world.firstAvailableManagerIndex() else {
            world.postEvent(L10n.string(L10n.Event.noAvailableManager))
            return
        }

        startCooking(world: &world, staffIndex: managerIndex, shouldPostFailure: true)
    }

    static func deliverReadyOrder(world: inout BistroWorld, customerID: Entity.ID? = nil) {
        guard let managerIndex = world.firstAvailableManagerIndex() else {
            world.postEvent(L10n.string(L10n.Event.noAvailableManager))
            return
        }

        startDelivery(world: &world, staffIndex: managerIndex, customerID: customerID, shouldPostFailure: true)
    }

    static func cancelManagerTask(world: inout BistroWorld) {
        guard let managerIndex = world.firstEntityIndex(where: { $0.role.isManager }),
              let taskKind = world.entities[managerIndex].taskKind
        else {
            return
        }

        switch taskKind {
        case .cooking(let orderID):
            if let orderIndex = world.orders.firstIndex(where: { $0.id == orderID && $0.status == .cooking }) {
                world.orders[orderIndex].status = .created
                world.orders[orderIndex].remainingTime = world.orders[orderIndex].recipe.duration
            }

        case .pickingUpDish, .delivering:
            break
        }

        clearTask(world: &world, staffIndex: managerIndex)
        world.postEvent(L10n.format(L10n.Event.managerActionCancelled, world.entities[managerIndex].name))
    }

    private static func assignAutomaticTasks(world: inout BistroWorld) {
        if let chefIndex = world.firstAvailableChefIndex(), world.canAutoStartCooking() {
            startCooking(world: &world, staffIndex: chefIndex, shouldPostFailure: false)
        }

        if let waiterIndex = world.firstAvailableWaiterIndex(), world.canAutoDeliverReadyOrder() {
            startDelivery(world: &world, staffIndex: waiterIndex, customerID: nil, shouldPostFailure: false)
        }
    }

    private static func startCooking(
        world: inout BistroWorld,
        staffIndex: Int,
        shouldPostFailure: Bool
    ) {
        guard let orderIndex = world.orders.firstIndex(where: { $0.status == .created }) else {
            if shouldPostFailure {
                world.postEvent(L10n.string(L10n.Event.noWaitingOrder))
            }
            return
        }

        guard let stove = world.firstFurniture(of: .stove) else {
            return
        }

        let orderID = world.orders[orderIndex].id
        let recipe = world.orders[orderIndex].recipe
        let staff = world.entities[staffIndex]
        let actionPosition = world.actionPosition(near: stove, from: staff.position, ignoring: staff.id)
        let destination = actionPosition == staff.position ? nil : actionPosition

        world.orders[orderIndex].status = .cooking
        world.orders[orderIndex].remainingTime = recipe.duration
        world.entities[staffIndex].taskKind = .cooking(orderID: orderID)
        world.entities[staffIndex].taskRemaining = recipe.duration
        world.entities[staffIndex].taskDuration = recipe.duration
        world.entities[staffIndex].destination = destination
        world.entities[staffIndex].path.removeAll()
        world.entities[staffIndex].staffState = destination == nil ? .cooking(orderID: orderID) : .moving

        if destination == nil {
            world.postEvent(L10n.format(L10n.Event.cooking, recipe.name))
        } else {
            world.postEvent(L10n.format(L10n.Event.chefHeadingToStove, staff.name))
        }
    }

    private static func startDelivery(
        world: inout BistroWorld,
        staffIndex: Int,
        customerID: Entity.ID?,
        shouldPostFailure: Bool
    ) {
        guard let orderIndex = world.orders.firstIndex(where: { order in
            order.status == .ready &&
            !world.orderIsAssignedToStaff(order.id) &&
            (customerID == nil || order.customerID == customerID)
        }) else {
            if shouldPostFailure {
                world.postEvent(L10n.string(L10n.Event.noReadyDish))
            }
            return
        }

        let order = world.orders[orderIndex]
        guard let customer = world.entities.first(where: { $0.id == order.customerID }),
              customer.customerState == .seated || customer.customerState == .waitingForFood
        else {
            return
        }

        guard let pickupFurniture = world.deliveryPickupFurniture() else {
            return
        }

        let staff = world.entities[staffIndex]
        let actionPosition = world.actionPosition(near: pickupFurniture, from: staff.position, ignoring: staff.id)
        let destination = actionPosition == staff.position ? nil : actionPosition

        world.entities[staffIndex].destination = destination
        world.entities[staffIndex].path.removeAll()
        world.entities[staffIndex].staffState = .moving
        world.entities[staffIndex].taskKind = .pickingUpDish(orderID: order.id, customerID: customer.id)
        world.entities[staffIndex].taskRemaining = nil
        world.entities[staffIndex].taskDuration = nil

        if destination == nil {
            beginDeliveryTravel(world: &world, staffIndex: staffIndex, orderID: order.id, customerID: customer.id)
        } else {
            world.postEvent(L10n.format(L10n.Event.staffHeadingToPickup, staff.name, order.recipe.name))
        }
    }

    private static func advanceStaffTasks(world: inout BistroWorld, deltaTime: TimeInterval) {
        for index in world.entities.indices where world.entities[index].role.isStaff {
            guard let taskKind = world.entities[index].taskKind else {
                continue
            }

            if world.entities[index].destination != nil {
                var staff = world.entities[index]
                let arrived = MovementSystem.advance(entity: &staff, world: world, deltaTime: deltaTime)
                world.entities[index] = staff

                if arrived {
                    handleStaffArrival(world: &world, staffIndex: index, taskKind: taskKind)
                }

                continue
            }

            switch taskKind {
            case .cooking:
                tickCookingTask(world: &world, staffIndex: index, deltaTime: deltaTime)

            case .pickingUpDish(let orderID, let customerID):
                beginDeliveryTravel(world: &world, staffIndex: index, orderID: orderID, customerID: customerID)

            case .delivering:
                tickStaffTimer(world: &world, staffIndex: index, deltaTime: deltaTime)
                if (world.entities[index].taskRemaining ?? 0) <= 0 {
                    completeDelivery(world: &world, staffIndex: index)
                }
            }
        }
    }

    private static func handleStaffArrival(world: inout BistroWorld, staffIndex: Int, taskKind: StaffTaskKind) {
        switch taskKind {
        case .cooking(let orderID):
            world.entities[staffIndex].staffState = .cooking(orderID: orderID)
            if let order = world.order(id: orderID) {
                world.postEvent(L10n.format(L10n.Event.cooking, order.recipe.name))
            }

        case .pickingUpDish(let orderID, let customerID):
            beginDeliveryTravel(world: &world, staffIndex: staffIndex, orderID: orderID, customerID: customerID)

        case .delivering(let orderID, let customerID):
            beginDeliveryHandoff(world: &world, staffIndex: staffIndex, orderID: orderID, customerID: customerID)
        }
    }

    private static func beginDeliveryTravel(
        world: inout BistroWorld,
        staffIndex: Int,
        orderID: Order.ID,
        customerID: Entity.ID
    ) {
        guard let orderIndex = world.orders.firstIndex(where: { $0.id == orderID && $0.status == .ready }),
              let customer = world.entities.first(where: { $0.id == customerID })
        else {
            clearTask(world: &world, staffIndex: staffIndex)
            return
        }

        let staff = world.entities[staffIndex]
        let actionPosition = world.actionPosition(for: customer, ignoring: staff.id)
        let destination = actionPosition == staff.position ? nil : actionPosition

        world.entities[staffIndex].staffState = .carryingDish(orderID: orderID)
        world.entities[staffIndex].taskKind = .delivering(orderID: orderID, customerID: customerID)
        world.entities[staffIndex].destination = destination
        world.entities[staffIndex].path.removeAll()
        world.entities[staffIndex].taskRemaining = nil
        world.entities[staffIndex].taskDuration = nil
        world.postEvent(L10n.format(L10n.Event.staffPickedUpDish, staff.name, world.orders[orderIndex].recipe.name))

        if destination == nil {
            beginDeliveryHandoff(world: &world, staffIndex: staffIndex, orderID: orderID, customerID: customerID)
        }
    }

    private static func beginDeliveryHandoff(
        world: inout BistroWorld,
        staffIndex: Int,
        orderID: Order.ID,
        customerID: Entity.ID
    ) {
        guard let order = world.order(id: orderID),
              world.entities.contains(where: { $0.id == customerID })
        else {
            clearTask(world: &world, staffIndex: staffIndex)
            return
        }

        world.entities[staffIndex].staffState = .delivering(orderID: orderID, customerID: customerID)
        world.entities[staffIndex].taskRemaining = Constants.deliveryHandoffDuration
        world.entities[staffIndex].taskDuration = Constants.deliveryHandoffDuration
        world.postEvent(L10n.format(L10n.Event.waiterDelivering, world.entities[staffIndex].name, order.recipe.name))
    }

    private static func tickCookingTask(world: inout BistroWorld, staffIndex: Int, deltaTime: TimeInterval) {
        guard case .cooking(let orderID) = world.entities[staffIndex].taskKind,
              let orderIndex = world.orders.firstIndex(where: { $0.id == orderID && $0.status == .cooking })
        else {
            clearTask(world: &world, staffIndex: staffIndex)
            return
        }

        tickStaffTimer(world: &world, staffIndex: staffIndex, deltaTime: deltaTime)
        world.orders[orderIndex].remainingTime = max(0, world.entities[staffIndex].taskRemaining ?? 0)

        if world.orders[orderIndex].remainingTime == 0 {
            world.orders[orderIndex].status = .ready
            clearTask(world: &world, staffIndex: staffIndex)
            world.postEvent(L10n.format(L10n.Event.dishReady, world.orders[orderIndex].recipe.name))
        }
    }

    private static func advanceUnassignedCookingOrders(world: inout BistroWorld, deltaTime: TimeInterval) {
        let assignedCookingOrderIDs = Set(world.entities.compactMap { entity -> Order.ID? in
            guard case .cooking(let orderID) = entity.taskKind else {
                return nil
            }
            return orderID
        })

        for orderIndex in world.orders.indices
        where world.orders[orderIndex].status == .cooking && !assignedCookingOrderIDs.contains(world.orders[orderIndex].id) {
            world.orders[orderIndex].remainingTime = max(0, world.orders[orderIndex].remainingTime - deltaTime)

            if world.orders[orderIndex].remainingTime == 0 {
                world.orders[orderIndex].status = .ready
                world.postEvent(L10n.format(L10n.Event.dishReady, world.orders[orderIndex].recipe.name))
            }
        }
    }

    private static func completeDelivery(world: inout BistroWorld, staffIndex: Int) {
        guard case .delivering(let orderID, let customerID) = world.entities[staffIndex].taskKind,
              let orderIndex = world.orders.firstIndex(where: { $0.id == orderID && $0.status == .ready }),
              let customerIndex = world.entities.firstIndex(where: { $0.id == customerID })
        else {
            clearTask(world: &world, staffIndex: staffIndex)
            return
        }

        let order = world.orders[orderIndex]
        guard let customerState = world.entities[customerIndex].customerState,
              customerState == .seated || customerState == .waitingForFood
        else {
            clearTask(world: &world, staffIndex: staffIndex)
            return
        }

        if let tableIndex = world.firstFurnitureIndex(of: .table, where: { $0.occupiedBy == order.customerID }) {
            world.furniture[tableIndex].occupiedBy = order.customerID
        } else if let customer = world.entities.first(where: { $0.id == order.customerID }),
                  let chair = world.firstFurniture(of: .chair, where: { $0.position == customer.position }),
                  let table = world.nearestTable(to: chair),
                  let tableIndex = world.firstFurnitureIndex(of: .table, where: { $0.id == table.id }) {
            world.furniture[tableIndex].occupiedBy = order.customerID
        }

        world.orders[orderIndex].status = .delivered
        world.entities[customerIndex].customerState = .eating
        world.entities[customerIndex].stateElapsedTime = 0
        clearTask(world: &world, staffIndex: staffIndex)
        world.postEvent(L10n.format(L10n.Event.customerEating, world.entities[customerIndex].name, order.recipe.name))
    }

    private static func tickStaffTimer(world: inout BistroWorld, staffIndex: Int, deltaTime: TimeInterval) {
        guard let taskRemaining = world.entities[staffIndex].taskRemaining else {
            return
        }

        world.entities[staffIndex].taskRemaining = max(0, taskRemaining - deltaTime)
    }

    private static func clearTask(world: inout BistroWorld, staffIndex: Int) {
        world.entities[staffIndex].taskKind = nil
        world.entities[staffIndex].taskRemaining = nil
        world.entities[staffIndex].taskDuration = nil
        world.entities[staffIndex].destination = nil
        world.entities[staffIndex].path.removeAll()
        world.entities[staffIndex].staffState = .idle
    }
}
