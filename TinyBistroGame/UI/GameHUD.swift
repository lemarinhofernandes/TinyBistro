import SwiftUI

struct GameHUD: View {
    let world: BistroWorld
    let selectedBlueprint: FurnitureBlueprint?
    var onStartCooking: () -> Void
    var onDeliver: () -> Void
    var onOpenShop: () -> Void
    var onSelectBlueprint: (FurnitureBlueprint?) -> Void
    var onAction: (BistroHUDAction) -> Void

    var body: some View {
        BistroHUD(
            world: world,
            selectedBlueprint: selectedBlueprint,
            onStartCooking: onStartCooking,
            onDeliver: onDeliver,
            onOpenShop: onOpenShop,
            onSelectBlueprint: onSelectBlueprint,
            onAction: onAction
        )
    }
}
