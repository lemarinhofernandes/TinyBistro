import Combine
import Foundation

enum GamePhase: Equatable, Sendable {
    case mainMenu
    case playing
    case paused
}

struct GameSessionMeta: Equatable, Sendable {
    var startedAt: Date
    var servedCustomers: Int
    var lostCustomers: Int
}

@MainActor
final class GameStateController: ObservableObject {
    @Published var phase: GamePhase = .mainMenu
    @Published var sessionMeta: GameSessionMeta?
    @Published var game: BistroGame?
    @Published private(set) var canContinue = false

    init() {
        canContinue = load() != nil
    }

    func startNewGame() {
        let newGame = BistroGame(world: .firstRoom)
        newGame.isPaused = false
        game = newGame
        sessionMeta = GameSessionMeta(startedAt: Date(), servedCustomers: 0, lostCustomers: 0)
        phase = .playing
    }

    func continueGame() {
        guard let savedWorld = load() else {
            canContinue = false
            return
        }

        let loadedGame = BistroGame(world: savedWorld)
        loadedGame.isPaused = false
        game = loadedGame
        sessionMeta = GameSessionMeta(
            startedAt: Date(),
            servedCustomers: savedWorld.servedCustomers,
            lostCustomers: savedWorld.lostCustomers
        )
        phase = .playing
    }

    func pause() {
        guard phase == .playing else {
            return
        }

        game?.isPaused = true
        phase = .paused
        save()
    }

    func resume() {
        guard phase == .paused else {
            return
        }

        game?.isPaused = false
        phase = .playing
    }

    func quitToMainMenu() {
        game?.isPaused = true
        save()
        game = nil
        phase = .mainMenu
    }

    func save() {
        guard let world = game?.world else {
            return
        }

        sessionMeta = GameSessionMeta(
            startedAt: sessionMeta?.startedAt ?? Date(),
            servedCustomers: world.servedCustomers,
            lostCustomers: world.lostCustomers
        )
        canContinue = load() != nil
    }

    func load() -> BistroWorld? {
        nil
    }
}
