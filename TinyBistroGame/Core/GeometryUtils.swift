import CoreGraphics

enum GeometryUtils {
    static func clamp<T: Comparable>(_ value: T, min lowerBound: T, max upperBound: T) -> T {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }

    static func lerp(_ start: CGFloat, _ end: CGFloat, progress: CGFloat) -> CGFloat {
        start + (end - start) * progress
    }

    static func lerp(_ start: Double, _ end: Double, progress: Double) -> Double {
        start + (end - start) * progress
    }

    static func radians(fromDegrees degrees: Double) -> CGFloat {
        CGFloat(degrees * .pi / 180)
    }

    static func degrees(fromRadians radians: CGFloat) -> Double {
        Double(radians) * 180 / .pi
    }
}
