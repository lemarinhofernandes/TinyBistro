import Foundation

enum CustomerSystem {
    static let movementStepDuration: TimeInterval = 0.35

    static func spawnCustomer(in world: inout BistroWorld) {
        guard world.activeCustomer == nil,
              let entrance = world.furniture.first(where: { $0.kind == .entrance }),
              let chair = world.furniture.first(where: { $0.kind == .chair && $0.occupiedBy == nil })
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
        world.statusMessage = "\(customer.name) is heading to the table."
    }

    static func tick(world: inout BistroWorld, deltaTime: TimeInterval) {
        guard let index = world.entities.firstIndex(where: { $0.role == .customer }) else {
            spawnCustomer(in: &world)
            return
        }

        world.entities[index].stateElapsedTime += deltaTime

        if world.entities[index].stateElapsedTime >= movementStepDuration,
           world.entities[index].destination != nil {
            world.entities[index].stateElapsedTime = 0
            let arrived = MovementSystem.advance(entity: &world.entities[index])

            if arrived {
                handleArrival(world: &world, customerIndex: index)
            }

            return
        }

        let customer = world.entities[index]

        switch customer.customerState {
        case .seated where customer.stateElapsedTime >= 0.75:
            world.entities[index].customerState = .ordering
            world.entities[index].stateElapsedTime = 0
            world.statusMessage = "\(customer.name) is choosing a recipe."

        case .ordering where customer.stateElapsedTime >= 1.0:
            createOrderIfNeeded(world: &world, customerIndex: index)

        case .eating where customer.stateElapsedTime >= 2.0:
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

            if let chairIndex = world.furniture.firstIndex(where: { $0.kind == .chair }) {
                world.furniture[chairIndex].occupiedBy = world.entities[customerIndex].id
            }

            world.statusMessage = "\(world.entities[customerIndex].name) sat down."

        case .leaving:
            finishVisit(world: &world, customerIndex: customerIndex)

        default:
            break
        }
    }

    private static func createOrderIfNeeded(world: inout BistroWorld, customerIndex: Int) {
        let customer = world.entities[customerIndex]
        guard world.orders.allSatisfy({ $0.customerID != customer.id || $0.status == .completed }) else {
            return
        }

        let order = Order(customerID: customer.id, recipe: .houseSoup)
        world.orders.append(order)
        world.entities[customerIndex].customerState = .waitingForFood
        world.entities[customerIndex].stateElapsedTime = 0
        world.statusMessage = "\(customer.name) ordered \(order.recipe.name). Tap the stove."
    }

    private static func sendCustomerHome(world: inout BistroWorld, customerIndex: Int) {
        guard let entrance = world.furniture.first(where: { $0.kind == .entrance }) else {
            return
        }

        let customerID = world.entities[customerIndex].id
        world.entities[customerIndex].customerState = .leaving
        world.entities[customerIndex].destination = entrance.position
        world.entities[customerIndex].stateElapsedTime = 0

        if let chairIndex = world.furniture.firstIndex(where: { $0.occupiedBy == customerID }) {
            world.furniture[chairIndex].occupiedBy = nil
        }

        world.statusMessage = "\(world.entities[customerIndex].name) is leaving happy."
    }

    private static func finishVisit(world: inout BistroWorld, customerIndex: Int) {
        let name = world.entities[customerIndex].name
        world.entities.remove(at: customerIndex)
        world.orders.removeAll { $0.status == .completed || $0.status == .delivered }
        world.servedCustomers += 1
        world.statusMessage = "\(name) left. Served customers: \(world.servedCustomers)."
    }
}
