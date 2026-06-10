import SwiftUI

struct BistroCampButton: View {
    enum Variant {
        case primary
        case secondary
        case destructive
        case neutral

        var color: Color {
            switch self {
            case .primary:
                return BistroCampTheme.Colors.varnishOrange
            case .secondary:
                return BistroCampTheme.Colors.cobalt
            case .destructive:
                return BistroCampTheme.Colors.tomato
            case .neutral:
                return BistroCampTheme.Colors.lead
            }
        }
    }

    let title: String
    let systemImage: String
    var variant: Variant = .primary
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .symbolRenderingMode(.hierarchical)
                    .shadow(color: .white.opacity(0.9), radius: 0, x: 0, y: 1)

                CampOutlinedText(
                    text: title,
                    font: BistroCampTheme.Fonts.camp(11),
                    fill: BistroCampTheme.Colors.cream,
                    outline: .black.opacity(0.62),
                    outlineWidth: 0.8
                )
            }
            .frame(minWidth: 70, minHeight: 50)
            .padding(.horizontal, 5)
        }
        .buttonStyle(CampButtonStyle(color: variant.color, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct CampButtonStyle: ButtonStyle {
    let color: Color
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(BistroCampTheme.Colors.cream)
            .background(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .fill(BistroCampTheme.plasticGradient(isEnabled ? color : BistroCampTheme.Colors.lead.opacity(0.72)))
            )
            .overlay(CampGlossOverlay(cornerRadius: BistroCampTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.medium, style: .continuous)
                    .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1)
                    .padding(2)
            )
            .shadow(
                color: isEnabled ? BistroCampTheme.Colors.deepShadow : .clear,
                radius: BistroCampTheme.Shadow.controlRadius,
                x: 0,
                y: BistroCampTheme.Shadow.controlY
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(isEnabled ? 1 : 0.58)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)
    }
}
