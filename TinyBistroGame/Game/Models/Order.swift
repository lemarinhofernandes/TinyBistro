import Foundation

/// State machine for a customer's food order.
///
/// Valid milestone transitions:
/// - `created -> cooking` when staff starts the recipe.
/// - `cooking -> ready` after `recipe.duration` has elapsed.
/// - `ready -> delivered` only when staff is carrying the same `orderID` and the
///   owning customer is `seated` or `waitingForFood`.
/// - `delivered -> completed` after the customer finishes eating and leaves.
///
/// Invariants:
/// - `customerID` must reference the customer who created the order.
/// - `recipe` is captured at creation time so cooking duration is deterministic.
/// - `remainingTime` only counts down while status is `cooking`; it is initialized
///   from `recipe.duration`.
enum OrderStatus: String, Sendable {
    case created = "Created"
    case cooking = "Cooking"
    case ready = "Ready"
    case delivered = "Delivered"
    case completed = "Completed"
}

struct Order: Identifiable, Hashable, Sendable {
    let id: UUID
    var customerID: Entity.ID
    var recipe: Recipe
    var status: OrderStatus
    var remainingTime: TimeInterval

    init(
        id: UUID = UUID(),
        customerID: Entity.ID,
        recipe: Recipe,
        status: OrderStatus = .created,
        remainingTime: TimeInterval? = nil
    ) {
        self.id = id
        self.customerID = customerID
        self.recipe = recipe
        self.status = status
        self.remainingTime = remainingTime ?? recipe.duration
    }
}
