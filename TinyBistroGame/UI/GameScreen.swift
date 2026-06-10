import SwiftUI

struct GameScreen: View {
    @StateObject private var game = BistroGame()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            ZStack {
                BistroSceneView(world: game.world) { target in
                    game.handleTap(target)
                }
                .ignoresSafeArea()

                GameHUD(
                    world: game.world,
                    selectedBlueprint: game.placementBlueprint,
                    onStartCooking: game.startCooking,
                    onDeliver: game.deliverOrder,
                    onOpenShop: game.openShop,
                    onSelectBlueprint: game.selectBlueprint,
                    onAction: { action in
                        game.showComingSoon(action.rawValue)
                    }
                )
            }
            .task(id: timeline.date) {
                game.tick(now: timeline.date)
            }
        }
    }
}
