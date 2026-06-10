import Foundation

enum EntityRole: Sendable {
    case staff
    case customer
}

/// State machine for the player/staff avatar.
///
/// Valid milestone transitions:
/// - `idle -> moving -> idle` when the player taps a walkable tile.
/// - `idle -> cooking(orderID:)` when `startCooking` is called for an `Order.created`.
/// - `cooking(orderID:) -> carryingDish(orderID:)` after `order.recipe.duration`.
/// - `carryingDish(orderID:) -> delivering(orderID:customerID:)` when delivery starts.
/// - `delivering(orderID:customerID:) -> idle` after the matching order is delivered.
///
/// Invariants:
/// - Staff carries at most one dish because `carryingDish` stores one `orderID`.
/// - A carried dish must reference an existing `Order.ready`.
/// - Delivery is valid only when the carried `orderID` matches the delivered order.
enum StaffState: Hashable, Sendable {
    case idle
    case moving
    case cooking(orderID: Order.ID)
    case carryingDish(orderID: Order.ID)
    case delivering(orderID: Order.ID, customerID: Entity.ID)

    var displayName: String {
        switch self {
        case .idle:
            return L10n.string(L10n.StaffState.idle)
        case .moving:
            return L10n.string(L10n.StaffState.moving)
        case .cooking:
            return L10n.string(L10n.StaffState.cooking)
        case .carryingDish:
            return L10n.string(L10n.StaffState.carryingDish)
        case .delivering:
            return L10n.string(L10n.StaffState.delivering)
        }
    }
}

/// State machine for a customer visit.
///
/// Valid milestone transitions:
/// - `spawning -> entering` once a customer entity is inserted into the world.
/// - `entering -> waitingForSeat` when the customer reaches the host/seat decision point.
/// - `waitingForSeat -> seated` when an unoccupied chair/table is assigned.
/// - `waitingForSeat -> leaving` when `seatingTimeout` expires, for example after 10s.
/// - `seated -> ordering` after the customer settles at the chair.
/// - `ordering -> waitingForFood` after creating exactly one `Order.created`.
/// - `waitingForFood -> eating` only when the matching order is delivered.
/// - `eating -> leaving` after `eatDuration`, for example 6s.
/// - `leaving -> finished` when the customer reaches the exit and cleanup has run.
///
/// Invariants:
/// - A customer owns at most one active order (`created`, `cooking`, `ready`, or `delivered`).
/// - A customer in `seated`, `ordering`, `waitingForFood`, or `eating` must occupy one chair.
/// - `finished` customers should not remain in `BistroWorld.entities`.
enum CustomerState: String, Sendable {
    case spawning = "Spawning"
    case entering = "Entering"
    case waitingForSeat = "Waiting for seat"
    case seated = "Seated"
    case ordering = "Ordering"
    case waitingForFood = "Waiting"
    case eating = "Eating"
    case leaving = "Leaving"
    case finished = "Finished"
}

struct Entity: Identifiable, Hashable, Sendable {
    let id: EntityID
    var name: String
    var role: EntityRole
    var position: GridPosition
    var destination: GridPosition?
    var staffState: StaffState?
    var customerState: CustomerState?
    var stateElapsedTime: TimeInterval

    init(
        id: EntityID = UUID(),
        name: String,
        role: EntityRole,
        position: GridPosition,
        destination: GridPosition? = nil,
        staffState: StaffState? = nil,
        customerState: CustomerState? = nil,
        stateElapsedTime: TimeInterval = 0
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.position = position
        self.destination = destination
        self.staffState = staffState
        self.customerState = customerState
        self.stateElapsedTime = stateElapsedTime
    }
}
