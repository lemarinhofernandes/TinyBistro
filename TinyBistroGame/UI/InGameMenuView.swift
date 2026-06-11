import SwiftUI

struct InGameMenuView: View {
    var onResume: () -> Void
    var onNewGame: () -> Void
    var onQuitToMenu: () -> Void
    @State private var showsNewGameConfirmation = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            VStack(spacing: BistroCampTheme.Spacing.large) {
                CampOutlinedText(
                    text: L10n.string(L10n.Menu.paused),
                    font: BistroCampTheme.Fonts.camp(38),
                    fill: BistroCampTheme.Colors.cream,
                    outline: BistroCampTheme.Colors.cobalt,
                    outlineWidth: 1.7
                )

                VStack(spacing: BistroCampTheme.Spacing.medium) {
                    PauseMenuButton(
                        title: L10n.string(L10n.Menu.resume),
                        systemImage: "play.fill",
                        tint: BistroCampTheme.Colors.neonGlass,
                        action: onResume
                    )

                    PauseMenuButton(
                        title: L10n.string(L10n.Menu.newGame),
                        systemImage: "sparkles",
                        tint: BistroCampTheme.Colors.varnishOrange
                    ) {
                        showsNewGameConfirmation = true
                    }

                    PauseMenuButton(
                        title: L10n.string(L10n.Menu.quitToMenu),
                        systemImage: "house.fill",
                        tint: BistroCampTheme.Colors.tomato,
                        action: onQuitToMenu
                    )
                }
            }
            .padding(BistroCampTheme.Spacing.xLarge)
            .frame(maxWidth: 390)
            .background(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.large, style: .continuous)
                    .fill(BistroCampTheme.plasticGradient(BistroCampTheme.Colors.varnishOrange))
            )
            .overlay(CampGlossOverlay(cornerRadius: BistroCampTheme.Radius.large))
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.large, style: .continuous)
                    .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.large, style: .continuous)
                    .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1.5)
                    .padding(4)
            )
            .shadow(color: .black.opacity(0.46), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 24)
        }
        .confirmationDialog(
            L10n.string(L10n.Menu.newGameConfirmTitle),
            isPresented: $showsNewGameConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.string(L10n.Menu.newGame), role: .destructive, action: onNewGame)
            Button(L10n.string(L10n.Menu.cancel), role: .cancel) {}
        } message: {
            Text(L10n.string(L10n.Menu.newGameConfirmMessage))
        }
    }
}

private struct PauseMenuButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BistroCampTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                    .frame(width: 30)

                CampOutlinedText(
                    text: title,
                    font: BistroCampTheme.Fonts.camp(17),
                    fill: BistroCampTheme.Colors.cream,
                    outline: .black.opacity(0.65),
                    outlineWidth: 0.9
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, BistroCampTheme.Spacing.large)
            .frame(maxWidth: .infinity, minHeight: 58)
        }
        .buttonStyle(PauseMenuButtonStyle(tint: tint))
    }
}

private struct PauseMenuButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(BistroCampTheme.Colors.cream)
            .background(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .fill(BistroCampTheme.plasticGradient(tint))
            )
            .overlay(CampGlossOverlay(cornerRadius: BistroCampTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1)
                    .padding(3)
            )
            .shadow(color: .black.opacity(0.34), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
