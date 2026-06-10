import SwiftUI

struct GameHUD: View {
    let world: BistroWorld
    var onStartCooking: () -> Void
    var onDeliver: () -> Void
    var onAction: (BistroHUDAction) -> Void

    var body: some View {
        BistroHUD(
            world: world,
            onStartCooking: onStartCooking,
            onDeliver: onDeliver,
            onAction: onAction
        )
    }
}
