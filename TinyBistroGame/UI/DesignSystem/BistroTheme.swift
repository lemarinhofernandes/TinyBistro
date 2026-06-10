import SwiftUI

enum BistroTheme {
    static let hudScale: CGFloat = 0.85

    enum Colors {
        static let wood = Color(hex: 0x8C5A3C)
        static let deepWood = Color(hex: 0x5D3827)
        static let copper = Color(hex: 0xC47E3A)
        static let brass = Color(hex: 0xD6A14A)
        static let cream = Color(hex: 0xF3E7D0)
        static let glassGreen = Color(hex: 0x9EC6A6)
        static let tomato = Color(hex: 0xE24A3B)
        static let slate = Color(hex: 0x34495E)
        static let graphite = Color(hex: 0x2C2C2C)
        static let offWhite = Color(hex: 0xFBF7F1)
        static let amber = Color(hex: 0xF0B84D)
        static let shadow = Color.black.opacity(0.28)
        static let highlight = Color.white.opacity(0.42)
    }

    enum Fonts {
        static func title(_ size: CGFloat = 20) -> Font {
            .system(size: size, weight: .heavy, design: .rounded)
        }

        static func heading(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func body(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        static func score(_ size: CGFloat = 22) -> Font {
            .system(size: size, weight: .bold, design: .monospaced)
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
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let panelRadius: CGFloat = 12
        static let panelY: CGFloat = 7
        static let controlRadius: CGFloat = 7
        static let controlY: CGFloat = 3
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
