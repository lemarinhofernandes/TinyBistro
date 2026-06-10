import SwiftUI

struct Bistro3DProgressBar: View {
    var value: Double
    var statusColor: Color
    var label: String?
    var isPulsing: Bool = false

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = max(14, proxy.size.width * clampedValue)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                BistroCampTheme.Colors.graphite,
                                BistroCampTheme.Colors.lead,
                                Color.black.opacity(0.92)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(innerCavity)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: -1)

                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.85),
                                statusColor,
                                statusColor.opacity(0.82),
                                .black.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: fillWidth)
                    .overlay(fillGloss)
                    .overlay(animatedShine(width: fillWidth))
                    .clipShape(RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous))
                    .scaleEffect(isPulsing ? 1.025 : 1)
                    .animation(
                        isPulsing ? .easeInOut(duration: 0.55).repeatForever(autoreverses: true) : .default,
                        value: isPulsing
                    )

                if let label {
                    CampOutlinedText(
                        text: label,
                        font: BistroCampTheme.Fonts.score(12),
                        fill: BistroCampTheme.Colors.cream,
                        outline: .black.opacity(0.72),
                        outlineWidth: 0.8
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous)
                    .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous)
                    .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1)
                    .padding(2)
            )
            .shadow(color: BistroCampTheme.Colors.deepShadow, radius: 10, x: 0, y: 5)
            .animation(.easeInOut(duration: 0.22), value: clampedValue)
        }
        .frame(height: 22)
    }

    private var innerCavity: some View {
        RoundedRectangle(cornerRadius: BistroCampTheme.Radius.pill, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [.black.opacity(0.58), .white.opacity(0.26)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 4
            )
            .padding(2)
    }

    private var fillGloss: some View {
        VStack(spacing: 0) {
            Color.white.opacity(0.48)
                .frame(height: 8)
            Spacer(minLength: 0)
        }
    }

    private func animatedShine(width: CGFloat) -> some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.3) / 1.3
            let xOffset = (phase * width * 1.8) - width * 0.5

            LinearGradient(
                colors: [.clear, .white.opacity(0.55), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 42)
            .offset(x: xOffset)
            .blendMode(.screen)
        }
    }
}
