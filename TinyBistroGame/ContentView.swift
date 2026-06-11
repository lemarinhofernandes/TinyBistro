//
//  ContentView.swift
//  TinyBistroGame
//
//  Created by Luís Eduardo Marinho Fernandes on 09/06/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stateController = GameStateController()

    var body: some View {
        ZStack {
            switch stateController.phase {
            case .mainMenu:
                MainMenuView(stateController: stateController)

            case .playing, .paused:
                if let game = stateController.game {
                    GameScreen(
                        game: game,
                        isInputEnabled: stateController.phase == .playing,
                        onPause: stateController.pause
                    )

                    if stateController.phase == .paused {
                        InGameMenuView(
                            onResume: stateController.resume,
                            onNewGame: stateController.startNewGame,
                            onQuitToMenu: stateController.quitToMainMenu
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                } else {
                    MainMenuView(stateController: stateController)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: stateController.phase)
    }
}

#Preview {
    ContentView()
}
