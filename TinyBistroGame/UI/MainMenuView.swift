import SwiftUI

struct MainMenuView: View {
    @ObservedObject var stateController: GameStateController
    @State private var stubMessage: String?

    var body: some View {
        ZStack {
            menuBackground

            VStack(spacing: BistroCampTheme.Spacing.xLarge) {
                titleBlock

                VStack(spacing: BistroCampTheme.Spacing.medium) {
                    CampMenuButton(
                        title: L10n.string(L10n.Menu.newGame),
                        systemImage: "sparkles",
                        tint: BistroCampTheme.Colors.varnishOrange,
                        action: stateController.startNewGame
                    )

                    CampMenuButton(
                        title: L10n.string(L10n.Menu.continueGame),
                        systemImage: "arrow.clockwise.circle.fill",
                        tint: BistroCampTheme.Colors.cobalt,
                        isEnabled: stateController.canContinue,
                        action: stateController.continueGame
                    )

                    CampMenuButton(
                        title: L10n.string(L10n.Menu.settings),
                        systemImage: "gearshape.fill",
                        tint: BistroCampTheme.Colors.lead
                    ) {
                        stubMessage = L10n.string(L10n.Menu.settingsStub)
                    }

                    CampMenuButton(
                        title: L10n.string(L10n.Menu.credits),
                        systemImage: "star.circle.fill",
                        tint: BistroCampTheme.Colors.tomato
                    ) {
                        stubMessage = L10n.string(L10n.Menu.creditsStub)
                    }
                }
                .frame(maxWidth: 360)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 34)
        }
        .alert(L10n.string(L10n.Menu.comingSoon), isPresented: stubAlertBinding) {
            Button(L10n.string(L10n.Menu.ok), role: .cancel) {
                stubMessage = nil
            }
        } message: {
            Text(stubMessage ?? "")
        }
    }

    private var titleBlock: some View {
        VStack(spacing: BistroCampTheme.Spacing.small) {
            CampOutlinedText(
                text: L10n.string(L10n.Menu.title),
                font: BistroCampTheme.Fonts.camp(44),
                fill: BistroCampTheme.Colors.cream,
                outline: BistroCampTheme.Colors.tomato,
                outlineWidth: 1.8
            )
            .shadow(color: .black.opacity(0.42), radius: 8, x: 0, y: 6)

            Text(L10n.string(L10n.Menu.subtitle))
                .font(BistroCampTheme.Fonts.rounded(15, weight: .heavy))
                .foregroundStyle(BistroCampTheme.Colors.graphite)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(BistroCampTheme.Colors.cream.opacity(0.86))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2)
                )
        }
    }

    private var menuBackground: some View {
        ZStack {
            BistroCampTheme.Colors.graphite
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    BistroCampTheme.Colors.varnishOrange.opacity(0.96),
                    BistroCampTheme.Colors.cream.opacity(0.90),
                    BistroCampTheme.Colors.cobalt.opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { column in
                            Rectangle()
                                .fill((row + column).isMultiple(of: 2) ? Color.white.opacity(0.12) : Color.black.opacity(0.05))
                                .frame(width: 58, height: 58)
                        }
                    }
                }
            }
            .rotationEffect(.degrees(45))
            .opacity(0.32)
            .offset(y: 90)
        }
    }

    private var stubAlertBinding: Binding<Bool> {
        Binding(
            get: { stubMessage != nil },
            set: { isPresented in
                if !isPresented {
                    stubMessage = nil
                }
            }
        )
    }
}

private struct CampMenuButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    var isEnabled = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BistroCampTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .black))
                    .frame(width: 34)

                CampOutlinedText(
                    text: title,
                    font: BistroCampTheme.Fonts.camp(20),
                    fill: BistroCampTheme.Colors.cream,
                    outline: .black.opacity(0.66),
                    outlineWidth: 1
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, BistroCampTheme.Spacing.large)
            .frame(maxWidth: .infinity, minHeight: 66)
        }
        .buttonStyle(CampMenuButtonStyle(tint: tint, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct CampMenuButtonStyle: ButtonStyle {
    let tint: Color
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(BistroCampTheme.Colors.cream)
            .background(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.large, style: .continuous)
                    .fill(BistroCampTheme.plasticGradient(isEnabled ? tint : BistroCampTheme.Colors.lead.opacity(0.72)))
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
            .shadow(color: BistroCampTheme.Colors.deepShadow, radius: 18, x: 0, y: 9)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(isEnabled ? 1 : 0.52)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
