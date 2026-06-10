import Foundation

enum TimeUtils {
    static let defaultTickClamp: TimeInterval = 0.25

    static func clampedDeltaTime(
        since lastDate: Date?,
        now: Date = Date(),
        max maxDelta: TimeInterval = defaultTickClamp
    ) -> TimeInterval {
        guard let lastDate else {
            return 0
        }

        let delta = now.timeIntervalSince(lastDate)
        return min(max(delta, 0), maxDelta)
    }

    static func formattedCountdown(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded(.up)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
