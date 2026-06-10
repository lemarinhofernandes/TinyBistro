import SwiftUI

struct BistroPanel<Content: View>: View {
    enum Tone {
        case wood
        case cream
        case copper
        case glass
    }

    let tone: Tone
    var cornerRadius: CGFloat = BistroTheme.Radius.medium
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(BistroTheme.Spacing.medium)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(glossOverlay.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderGradient, lineWidth: 1.5)
            )
            .shadow(
                color: BistroTheme.Colors.shadow,
                radius: BistroTheme.Shadow.panelRadius,
                x: 0,
                y: BistroTheme.Shadow.panelY
            )
    }

    private var panelBackground: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if tone == .wood {
                woodGrain
                    .opacity(0.24)
                    .blendMode(.multiply)
            }
        }
    }

    private var backgroundColors: [Color] {
        switch tone {
        case .wood:
            return [BistroTheme.Colors.wood, BistroTheme.Colors.deepWood]
        case .cream:
            return [BistroTheme.Colors.offWhite, BistroTheme.Colors.cream]
        case .copper:
            return [BistroTheme.Colors.brass, BistroTheme.Colors.copper]
        case .glass:
            return [
                BistroTheme.Colors.glassGreen.opacity(0.82),
                BistroTheme.Colors.offWhite.opacity(0.62)
            ]
        }
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [BistroTheme.Colors.highlight, Color.black.opacity(0.18)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var glossOverlay: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [BistroTheme.Colors.highlight, Color.white.opacity(0.08), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 22)
            Spacer(minLength: 0)
        }
    }

    private var woodGrain: some View {
        Canvas { context, size in
            let stripeHeight: CGFloat = 6
            var y: CGFloat = 2
            var index = 0

            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                let opacity = index.isMultiple(of: 2) ? 0.26 : 0.12
                context.fill(Path(rect), with: .color(.black.opacity(opacity)))
                y += stripeHeight
                index += 1
            }
        }
    }
}

struct BistroBadge: View {
    let text: String
    let tint: Color
    var icon: String?

    var body: some View {
        Label {
            Text(text)
                .font(BistroTheme.Fonts.heading(11))
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        } icon: {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .black))
            }
        }
        .labelStyle(.titleAndIcon)
        .foregroundStyle(BistroTheme.Colors.offWhite)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(tint)
                .shadow(color: .white.opacity(0.35), radius: 0, x: 0, y: 1)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        )
    }
}

struct BistroButton: View {
    let title: String
    let systemImage: String
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(BistroTheme.Fonts.heading(15))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(minWidth: 116, minHeight: 44)
        }
        .buttonStyle(BistroButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct BistroButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? BistroTheme.Colors.offWhite : BistroTheme.Colors.graphite.opacity(0.52))
            .padding(.horizontal, BistroTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: BistroTheme.Radius.small, style: .continuous)
                    .fill(buttonGradient(isPressed: configuration.isPressed))
            )
            .overlay(
                RoundedRectangle(cornerRadius: BistroTheme.Radius.small, style: .continuous)
                    .stroke(.white.opacity(isEnabled ? 0.65 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: isEnabled ? BistroTheme.Colors.shadow : .clear,
                radius: BistroTheme.Shadow.controlRadius,
                x: 0,
                y: BistroTheme.Shadow.controlY
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(isEnabled ? 1 : 0.58)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }

    private func buttonGradient(isPressed: Bool) -> LinearGradient {
        let top = isEnabled ? BistroTheme.Colors.copper : BistroTheme.Colors.cream.opacity(0.7)
        let bottom = isEnabled ? BistroTheme.Colors.deepWood : BistroTheme.Colors.cream.opacity(0.45)

        return LinearGradient(
            colors: isPressed ? [bottom, top] : [top, bottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct BistroTicketView: View {
    let order: Order?

    var body: some View {
        BistroPanel(tone: .wood) {
            VStack(alignment: .leading, spacing: BistroTheme.Spacing.medium) {
                HStack(spacing: BistroTheme.Spacing.medium) {
                    recipeIcon

                    VStack(alignment: .leading, spacing: BistroTheme.Spacing.xSmall) {
                        Text(order?.recipe.name ?? L10n.string(L10n.HUD.noActiveTicket))
                            .font(BistroTheme.Fonts.title(18))
                            .foregroundStyle(BistroTheme.Colors.offWhite)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(orderSubtitle)
                            .font(BistroTheme.Fonts.body(12))
                            .foregroundStyle(BistroTheme.Colors.cream.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer(minLength: BistroTheme.Spacing.small)

                    BistroBadge(text: statusText, tint: statusColor, icon: statusIcon)
                }

                ProgressView(value: progress)
                    .tint(statusColor)
                    .progressViewStyle(.linear)

                HStack {
                    Image(systemName: "timer")
                    Text(timeText)
                        .font(BistroTheme.Fonts.score(15))
                        .monospacedDigit()
                    Spacer()
                }
                .foregroundStyle(BistroTheme.Colors.offWhite)
            }
        }
        .frame(maxWidth: 430)
        .scaleEffect(order == nil ? 0.99 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.76), value: order?.status.rawValue ?? "empty")
    }

    private var recipeIcon: some View {
        ZStack {
            Circle()
                .fill(BistroTheme.Colors.cream)
            Circle()
                .stroke(BistroTheme.Colors.highlight, lineWidth: 2)
            Image(systemName: iconName)
                .font(.system(size: 25, weight: .heavy))
                .foregroundStyle(BistroTheme.Colors.copper)
        }
        .frame(width: 54, height: 54)
        .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 3)
    }

    private var iconName: String {
        guard order != nil else {
            return "takeoutbag.and.cup.and.straw"
        }

        return "fork.knife.circle.fill"
    }

    private var orderSubtitle: String {
        guard let order else {
            return L10n.string(L10n.HUD.waitingForCustomer)
        }

        return L10n.format(L10n.HUD.ticketForGuest, String(order.customerID.uuidString.prefix(4)))
    }

    private var statusText: String {
        order?.status.displayName ?? L10n.string(L10n.HUD.idle)
    }

    private var statusIcon: String {
        switch order?.status {
        case .created:
            return "bell.fill"
        case .cooking:
            return "flame.fill"
        case .ready:
            return "checkmark.seal.fill"
        case .delivered:
            return "hand.raised.fill"
        case .completed:
            return "star.fill"
        case nil:
            return "moon.zzz.fill"
        }
    }

    private var statusColor: Color {
        switch order?.status {
        case .created:
            return BistroTheme.Colors.slate
        case .cooking:
            return BistroTheme.Colors.amber
        case .ready:
            return BistroTheme.Colors.glassGreen
        case .delivered, .completed:
            return BistroTheme.Colors.copper
        case nil:
            return BistroTheme.Colors.graphite.opacity(0.7)
        }
    }

    private var progress: Double {
        guard let order else {
            return 0
        }

        switch order.status {
        case .created:
            return 0.08
        case .cooking:
            guard order.recipe.duration > 0 else {
                return 1
            }

            return min(max(1 - order.remainingTime / order.recipe.duration, 0), 1)
        case .ready, .delivered, .completed:
            return 1
        }
    }

    private var timeText: String {
        guard let order else {
            return "--"
        }

        switch order.status {
        case .created:
            return L10n.string(L10n.HUD.waiting)
        case .cooking:
            return "\(Int(ceil(order.remainingTime)))s"
        case .ready:
            return L10n.string(L10n.HUD.ready)
        case .delivered:
            return L10n.string(L10n.HUD.delivered)
        case .completed:
            return L10n.string(L10n.HUD.done)
        }
    }
}

struct BistroScoreView: View {
    let served: Int
    let target: Int
    let lost: Int

    var body: some View {
        BistroPanel(tone: .copper) {
            VStack(alignment: .leading, spacing: BistroTheme.Spacing.medium) {
                Text(L10n.string(L10n.HUD.score))
                    .font(BistroTheme.Fonts.heading(13))
                    .foregroundStyle(BistroTheme.Colors.graphite.opacity(0.8))
                    .textCase(.uppercase)

                HStack(alignment: .firstTextBaseline, spacing: BistroTheme.Spacing.xSmall) {
                    Text("\(served)")
                        .font(BistroTheme.Fonts.score(34))
                    Text("/\(target)")
                        .font(BistroTheme.Fonts.score(19))
                }
                .foregroundStyle(BistroTheme.Colors.graphite)
                .monospacedDigit()

                if lost > 0 {
                    BistroBadge(text: L10n.format(L10n.HUD.lostCount, lost), tint: BistroTheme.Colors.tomato, icon: "exclamationmark.triangle.fill")
                }
            }
        }
        .frame(width: 148, alignment: .leading)
        .animation(.spring(response: 0.24, dampingFraction: 0.72), value: served)
        .animation(.easeOut(duration: 0.2), value: lost)
    }
}

struct BistroStatusBar: View {
    let text: String
    let eventID: Int

    var body: some View {
        BistroPanel(tone: .cream, cornerRadius: BistroTheme.Radius.large) {
            HStack(spacing: BistroTheme.Spacing.medium) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(BistroTheme.Colors.copper)

                Text(text)
                    .font(BistroTheme.Fonts.heading(15))
                    .foregroundStyle(BistroTheme.Colors.graphite)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
        }
        .id(eventID)
        .transition(.asymmetric(insertion: .scale(scale: 0.96).combined(with: .opacity), removal: .opacity))
    }
}
