import Foundation

enum L10n {
    static func string(_ resource: LocalizedStringResource) -> String {
        String(localized: resource)
    }

    static func format(_ resource: LocalizedStringResource, _ arguments: CVarArg...) -> String {
        String(format: String(localized: resource), locale: .current, arguments: arguments)
    }

    enum HUD {
        static let tinyBistro = LocalizedStringResource("hud.tinyBistro", defaultValue: "Tiny Bistro")
        static let closed = LocalizedStringResource("hud.closed", defaultValue: "Closed")
        static let open = LocalizedStringResource("hud.open", defaultValue: "Open")
        static let pause = LocalizedStringResource("hud.pause", defaultValue: "Pause")
        static let cook = LocalizedStringResource("hud.cook", defaultValue: "Cook")
        static let deliver = LocalizedStringResource("hud.deliver", defaultValue: "Deliver")
        static let buy = LocalizedStringResource("hud.buy", defaultValue: "Buy")
        static let staff = LocalizedStringResource("hud.staff", defaultValue: "Staff")
        static let items = LocalizedStringResource("hud.items", defaultValue: "Items")
        static let decor = LocalizedStringResource("hud.decor", defaultValue: "Decor")
        static let more = LocalizedStringResource("hud.more", defaultValue: "More")
        static let back = LocalizedStringResource("hud.back", defaultValue: "Back")
        static let score = LocalizedStringResource("hud.score", defaultValue: "Score")
        static let noActiveTicket = LocalizedStringResource("hud.noActiveTicket", defaultValue: "No active ticket")
        static let waitingForNextGuest = LocalizedStringResource("hud.waitingForNextGuest", defaultValue: "Waiting for the next guest")
        static let waitingForCustomer = LocalizedStringResource("hud.waitingForCustomer", defaultValue: "Waiting for a customer")
        static let ticketForGuest = LocalizedStringResource("hud.ticketForGuest", defaultValue: "Ticket for guest %@")
        static let waiting = LocalizedStringResource("hud.waiting", defaultValue: "Waiting")
        static let ready = LocalizedStringResource("hud.ready", defaultValue: "READY!")
        static let delivered = LocalizedStringResource("hud.delivered", defaultValue: "Delivered")
        static let done = LocalizedStringResource("hud.done", defaultValue: "Done")
        static let idle = LocalizedStringResource("hud.idle", defaultValue: "Idle")
        static let lost = LocalizedStringResource("hud.lost", defaultValue: "Lost")
        static let lostCount = LocalizedStringResource("hud.lostCount", defaultValue: "Lost %d")
        static let guestPrefix = LocalizedStringResource("hud.guestPrefix", defaultValue: "Guest %@")
        static let noTicketYet = LocalizedStringResource("hud.noTicketYet", defaultValue: "No ticket yet")
        static let waitingForNextOrder = LocalizedStringResource("hud.waitingForNextOrder", defaultValue: "Waiting for the next guest")
    }

    enum Menu {
        static let title = LocalizedStringResource("menu.title", defaultValue: "Tiny Bistro")
        static let subtitle = LocalizedStringResource("menu.subtitle", defaultValue: "Camp kitchen chaos")
        static let newGame = LocalizedStringResource("menu.newGame", defaultValue: "New Game")
        static let continueGame = LocalizedStringResource("menu.continue", defaultValue: "Continue")
        static let settings = LocalizedStringResource("menu.settings", defaultValue: "Settings")
        static let credits = LocalizedStringResource("menu.credits", defaultValue: "Credits")
        static let resume = LocalizedStringResource("menu.resume", defaultValue: "Resume")
        static let paused = LocalizedStringResource("menu.paused", defaultValue: "Paused")
        static let quitToMenu = LocalizedStringResource("menu.quitToMenu", defaultValue: "Quit to Main Menu")
        static let newGameConfirmTitle = LocalizedStringResource("menu.newGameConfirmTitle", defaultValue: "Start a new game?")
        static let newGameConfirmMessage = LocalizedStringResource("menu.newGameConfirmMessage", defaultValue: "Current unsaved progress will be discarded.")
        static let cancel = LocalizedStringResource("menu.cancel", defaultValue: "Cancel")
        static let ok = LocalizedStringResource("menu.ok", defaultValue: "OK")
        static let comingSoon = LocalizedStringResource("menu.comingSoon", defaultValue: "Coming soon")
        static let settingsStub = LocalizedStringResource("menu.settingsStub", defaultValue: "Settings will arrive in a future build.")
        static let creditsStub = LocalizedStringResource("menu.creditsStub", defaultValue: "Credits will arrive in a future build.")
    }

    enum Event {
        static let firstOrderPrompt = LocalizedStringResource("event.firstOrderPrompt", defaultValue: "Tap the stove when the first order appears.")
        static let shopOpened = LocalizedStringResource("event.shopOpened", defaultValue: "Shop open! First guest is on the way.")
        static let noWaitingOrder = LocalizedStringResource("event.noWaitingOrder", defaultValue: "No order is waiting yet.")
        static let noReadyDish = LocalizedStringResource("event.noReadyDish", defaultValue: "No ready dish to deliver.")
        static let noAvailableChef = LocalizedStringResource("event.noAvailableChef", defaultValue: "Chef is busy.")
        static let noAvailableWaiter = LocalizedStringResource("event.noAvailableWaiter", defaultValue: "Waiter is busy.")
        static let noAvailableManager = LocalizedStringResource("event.noAvailableManager", defaultValue: "Manager is busy.")
        static let tileBlocked = LocalizedStringResource("event.tileBlocked", defaultValue: "Tile blocked.")
        static let placementCancelled = LocalizedStringResource("event.placementCancelled", defaultValue: "Placement cancelled.")
        static let placementPrompt = LocalizedStringResource("event.placementPrompt", defaultValue: "Tap an empty tile to place %@.")
        static let pickEmptyFloorTile = LocalizedStringResource("event.pickEmptyFloorTile", defaultValue: "Pick an empty floor tile.")
        static let cannotPlace = LocalizedStringResource("event.cannotPlace", defaultValue: "Can't place %@ there.")
        static let goalReached = LocalizedStringResource("event.goalReached", defaultValue: "Goal reached! Served %d.")
        static let placedFurniture = LocalizedStringResource("event.placedFurniture", defaultValue: "Placed %@.")
        static let comingSoon = LocalizedStringResource("event.comingSoon", defaultValue: "Coming soon: %@.")
        static let selectedFurniture = LocalizedStringResource("event.selectedFurniture", defaultValue: "Selected %@.")
        static let staffState = LocalizedStringResource("event.staffState", defaultValue: "%@ is %@.")
        static let staffMoved = LocalizedStringResource("event.staffMoved", defaultValue: "%@ moved to tile %d, %d.")
        static let customerHeadingToTable = LocalizedStringResource("event.customerHeadingToTable", defaultValue: "%@ is heading to the table.")
        static let customerSatDown = LocalizedStringResource("event.customerSatDown", defaultValue: "%@ sat down.")
        static let customerChoosingRecipe = LocalizedStringResource("event.customerChoosingRecipe", defaultValue: "%@ is choosing a recipe.")
        static let customerOrdered = LocalizedStringResource("event.customerOrdered", defaultValue: "%@ ordered %@. Tap the stove.")
        static let chefHeadingToStove = LocalizedStringResource("event.chefHeadingToStove", defaultValue: "%@ is heading to the stove.")
        static let cooking = LocalizedStringResource("event.cooking", defaultValue: "Cooking %@...")
        static let dishReady = LocalizedStringResource("event.dishReady", defaultValue: "%@ is ready. Tap the customer.")
        static let staffHeadingToPickup = LocalizedStringResource("event.staffHeadingToPickup", defaultValue: "%@ is heading to pick up %@.")
        static let staffPickedUpDish = LocalizedStringResource("event.staffPickedUpDish", defaultValue: "%@ picked up %@.")
        static let waiterDelivering = LocalizedStringResource("event.waiterDelivering", defaultValue: "%@ is delivering %@.")
        static let managerActionCancelled = LocalizedStringResource("event.managerActionCancelled", defaultValue: "%@ cancelled the current action.")
        static let guestLeavingHappy = LocalizedStringResource("event.guestLeavingHappy", defaultValue: "%@ is leaving happy.")
        static let customerEating = LocalizedStringResource("event.customerEating", defaultValue: "%@ is eating %@.")
        static let guestLeftUnhappy = LocalizedStringResource("event.guestLeftUnhappy", defaultValue: "%@ left unhappy.")
        static let guestLeft = LocalizedStringResource("event.guestLeft", defaultValue: "%@ left. Served customers: %d.")
    }

    enum Furniture {
        static let table = LocalizedStringResource("furniture.table", defaultValue: "Table")
        static let chair = LocalizedStringResource("furniture.chair", defaultValue: "Chair")
        static let stove = LocalizedStringResource("furniture.stove", defaultValue: "Stove")
        static let counter = LocalizedStringResource("furniture.counter", defaultValue: "Counter")
        static let entrance = LocalizedStringResource("furniture.entrance", defaultValue: "Entrance")
    }

    enum OrderState {
        static let created = LocalizedStringResource("orderState.created", defaultValue: "Created")
        static let cooking = LocalizedStringResource("orderState.cooking", defaultValue: "Cooking")
        static let ready = LocalizedStringResource("orderState.ready", defaultValue: "Ready")
        static let delivered = LocalizedStringResource("orderState.delivered", defaultValue: "Delivered")
        static let completed = LocalizedStringResource("orderState.completed", defaultValue: "Completed")
    }

    enum StaffState {
        static let idle = LocalizedStringResource("staffState.idle", defaultValue: "Idle")
        static let moving = LocalizedStringResource("staffState.moving", defaultValue: "Moving")
        static let cooking = LocalizedStringResource("staffState.cooking", defaultValue: "Cooking")
        static let carryingDish = LocalizedStringResource("staffState.carryingDish", defaultValue: "Carrying dish")
        static let delivering = LocalizedStringResource("staffState.delivering", defaultValue: "Delivering")
    }
}
