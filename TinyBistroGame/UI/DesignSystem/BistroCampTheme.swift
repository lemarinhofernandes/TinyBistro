import SwiftUI

enum BistroCampTheme {
    static let hudScale: CGFloat = 0.80

    enum Colors {
        static let varnishOrange = Color(hex: 0xF59E42)
        static let tomato = Color(hex: 0xE24A3B)
        static let neonGlass = Color(hex: 0x7FE9A8)
        static let cobalt = Color(hex: 0x2E86DE)
        static let cream = Color(hex: 0xFFF3D9)
        static let graphite = Color(hex: 0x1E1E1E)
        static let lead = Color(hex: 0x5C6A72)
        static let polishedSteel = Color(hex: 0xB6C2CC)
        static let whiteStroke = Color.white.opacity(0.86)
        static let darkStroke = Color.black.opacity(0.48)
        static let gloss = Color.white.opacity(0.72)
        static let deepShadow = Color.black.opacity(0.38)
        static let hotYellow = Color(hex: 0xFFE66D)
    }

    enum Fonts {
        static func camp(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
            .custom("MarkerFelt-Wide", size: size, relativeTo: .headline)
                .weight(weight)
        }

        static func rounded(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static func score(_ size: CGFloat) -> Font {
            .system(size: size, weight: .black, design: .monospaced)
        }
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let hardRadius: CGFloat = 18
        static let hardY: CGFloat = 8
        static let controlRadius: CGFloat = 12
        static let controlY: CGFloat = 6
    }

    static func plasticGradient(_ base: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.78),
                base.opacity(0.95),
                base,
                Color.black.opacity(0.28)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CampOutlinedText: View {
    let text: String
    var font: Font
    var fill: Color = BistroCampTheme.Colors.cream
    var outline: Color = BistroCampTheme.Colors.darkStroke
    var outlineWidth: CGFloat = 1

    var body: some View {
        ZStack {
            Text(text)
                .font(font)
                .foregroundStyle(outline)
                .offset(x: -outlineWidth, y: 0)
            Text(text)
                .font(font)
                .foregroundStyle(outline)
                .offset(x: outlineWidth, y: 0)
            Text(text)
                .font(font)
                .foregroundStyle(outline)
                .offset(x: 0, y: -outlineWidth)
            Text(text)
                .font(font)
                .foregroundStyle(outline)
                .offset(x: 0, y: outlineWidth)
            Text(text)
                .font(font)
                .foregroundStyle(fill)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
}

struct CampGlossOverlay: View {
    var cornerRadius: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    BistroCampTheme.Colors.gloss,
                    Color.white.opacity(0.34),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)

            Spacer(minLength: 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
