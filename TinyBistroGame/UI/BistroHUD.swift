import SwiftUI

enum BistroHUDAction: String {
    case buy = "Comprar"
    case staff = "Funcionarios"
    case ingredients = "Ingredientes"
    case furniture = "Moveis"
}

struct BistroHUD: View {
    let world: BistroWorld
    let selectedBlueprint: FurnitureBlueprint?
    var onStartCooking: () -> Void
    var onDeliver: () -> Void
    var onOpenShop: () -> Void
    var onSelectBlueprint: (FurnitureBlueprint?) -> Void
    var onAction: (BistroHUDAction) -> Void
    @State private var showsUtilityButtons = false

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Spacer(minLength: BistroCampTheme.Spacing.large)

            bottomBar
        }
        .padding(.horizontal, BistroCampTheme.Spacing.xSmall)
        .padding(.vertical, BistroCampTheme.Spacing.small)
        .animation(.easeInOut(duration: 0.22), value: world.lastEventID)
        .animation(.spring(response: 0.28, dampingFraction: 0.74), value: world.activeOrder?.status.rawValue ?? "none")
    }

    @ViewBuilder
    private var topBar: some View {
        if world.sessionState == .closed {
            closedTopBar
        } else {
            activeTopBar
        }
    }

    private var closedTopBar: some View {
        HStack(alignment: .top, spacing: BistroCampTheme.Spacing.medium) {
            CampPanel(tint: BistroCampTheme.Colors.varnishOrange) {
                HStack(spacing: BistroCampTheme.Spacing.medium) {
                    CampOutlinedText(
                        text: "Tiny Bistro",
                        font: BistroCampTheme.Fonts.camp(23),
                        fill: BistroCampTheme.Colors.cream,
                        outline: BistroCampTheme.Colors.tomato.opacity(0.82),
                        outlineWidth: 1.2
                    )

                    Text("Closed")
                        .font(BistroCampTheme.Fonts.rounded(13, weight: .heavy))
                        .foregroundStyle(BistroCampTheme.Colors.graphite)

                    Spacer(minLength: BistroCampTheme.Spacing.small)

                    BistroCampButton(title: "Open", systemImage: "storefront.fill", variant: .secondary, action: onOpenShop)
                }
            }
            .frame(maxWidth: 520)

            Spacer(minLength: 0)
        }
    }

    private var activeTopBar: some View {
        HStack(alignment: .top, spacing: 0) {
            CampTicketView(
                order: world.activeOrder,
                served: world.servedCustomers,
                target: world.targetServed,
                lost: world.lostCustomers
            )
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: BistroCampTheme.Spacing.small) {
            CampStatusBubble(text: world.statusMessage, eventID: world.lastEventID)
                .frame(maxWidth: .infinity, alignment: .leading)

            actionDock
                .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    private var actionDock: some View {
        CampPanel(tint: BistroCampTheme.Colors.graphite.opacity(0.92), cornerRadius: BistroCampTheme.Radius.large) {
            VStack(alignment: .leading, spacing: BistroCampTheme.Spacing.small) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BistroCampTheme.Spacing.small) {
                        contextualButtons
                        utilityToggleButtons
                    }
                    .padding(.horizontal, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if showsUtilityButtons {
                    ScrollView(.horizontal, showsIndicators: false) {
                        featureButtons
                            .padding(.horizontal, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: showsUtilityButtons)
        }
    }

    private var contextualButtons: some View {
        HStack(spacing: BistroCampTheme.Spacing.small) {
            BistroCampButton(
                title: "Cook",
                systemImage: "flame.fill",
                variant: .primary,
                isEnabled: world.activeOrder?.status == .created,
                action: onStartCooking
            )

            BistroCampButton(
                title: "Deliver",
                systemImage: "takeoutbag.and.cup.and.straw.fill",
                variant: .secondary,
                isEnabled: world.activeOrder?.status == .ready,
                action: onDeliver
            )
        }
    }

    private var featureButtons: some View {
        VStack(alignment: .trailing, spacing: BistroCampTheme.Spacing.small) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: BistroCampTheme.Spacing.small) {
                    managementButtons
                }

                VStack(alignment: .trailing, spacing: BistroCampTheme.Spacing.small) {
                    managementButtons
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: BistroCampTheme.Spacing.small) {
                    catalogButtons
                }

                VStack(alignment: .trailing, spacing: BistroCampTheme.Spacing.small) {
                    catalogButtons
                }
            }
        }
    }

    private var managementButtons: some View {
        Group {
            BistroCampButton(title: "Buy", systemImage: "cart.fill", variant: .primary) {
                onAction(.buy)
            }
            BistroCampButton(title: "Staff", systemImage: "person.2.fill", variant: .secondary) {
                onAction(.staff)
            }
            BistroCampButton(title: "Items", systemImage: "carrot.fill", variant: .neutral) {
                onAction(.ingredients)
            }
            BistroCampButton(title: "Decor", systemImage: "chair.lounge.fill", variant: .destructive) {
                onAction(.furniture)
            }
        }
    }

    private var catalogButtons: some View {
        ForEach(world.catalog) { blueprint in
            catalogButton(for: blueprint)
        }
    }

    private var utilityToggleButtons: some View {
        HStack(spacing: BistroCampTheme.Spacing.small) {
            BistroCampButton(
                title: showsUtilityButtons ? "Back" : "More",
                systemImage: showsUtilityButtons ? "arrow.uturn.left" : "square.grid.2x2.fill",
                variant: .neutral
            ) {
                showsUtilityButtons.toggle()
            }
        }
    }

    private func catalogButton(for blueprint: FurnitureBlueprint) -> some View {
        BistroCampButton(
            title: blueprint.displayName,
            systemImage: iconName(for: blueprint),
            variant: selectedBlueprint == blueprint ? .secondary : .primary
        ) {
            onSelectBlueprint(selectedBlueprint == blueprint ? nil : blueprint)
        }
    }

    private func iconName(for blueprint: FurnitureBlueprint) -> String {
        switch blueprint {
        case .table:
            return "table.furniture.fill"
        case .chair:
            return "chair.fill"
        case .stove:
            return "flame.fill"
        case .counter:
            return "cabinet.fill"
        case .entrance:
            return "door.left.hand.open"
        }
    }
}

private struct CampPanel<Content: View>: View {
    var tint: Color
    var cornerRadius: CGFloat = BistroCampTheme.Radius.large
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(BistroCampTheme.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BistroCampTheme.plasticGradient(tint))
            )
            .overlay(CampGlossOverlay(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1)
                    .padding(3)
            )
            .shadow(
                color: BistroCampTheme.Colors.deepShadow,
                radius: BistroCampTheme.Shadow.hardRadius,
                x: 0,
                y: BistroCampTheme.Shadow.hardY
            )
    }
}

private struct CampTicketView: View {
    let order: Order?
    let served: Int
    let target: Int
    let lost: Int

    var body: some View {
        CampPanel(tint: BistroCampTheme.Colors.varnishOrange) {
            VStack(alignment: .leading, spacing: BistroCampTheme.Spacing.small) {
                HStack(spacing: BistroCampTheme.Spacing.small) {
                    recipeIcon

                    VStack(alignment: .leading, spacing: BistroCampTheme.Spacing.xSmall) {
                        CampOutlinedText(
                            text: order?.recipe.name ?? "No ticket yet",
                            font: BistroCampTheme.Fonts.camp(18),
                            fill: BistroCampTheme.Colors.cream,
                            outline: BistroCampTheme.Colors.tomato.opacity(0.78),
                            outlineWidth: 1.1
                        )

                        Text(subtitle)
                            .font(BistroCampTheme.Fonts.rounded(12, weight: .semibold))
                            .foregroundStyle(BistroCampTheme.Colors.graphite.opacity(0.86))
                            .lineLimit(1)
                    }

                    Spacer(minLength: BistroCampTheme.Spacing.small)

                    VStack(alignment: .trailing, spacing: BistroCampTheme.Spacing.xSmall) {
                        CampStatusBadge(text: statusText, color: statusColor, icon: statusIcon)
                        CampScorePill(served: served, target: target, lost: lost)
                    }
                }

                Bistro3DProgressBar(
                    value: progress,
                    statusColor: statusColor,
                    label: progressLabel,
                    isPulsing: order?.status == .ready
                )
            }
        }
        .frame(maxWidth: 520)
    }

    private var recipeIcon: some View {
        ZStack {
            Circle()
                .fill(BistroCampTheme.plasticGradient(BistroCampTheme.Colors.cream))
            Circle()
                .stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 3)
            Circle()
                .stroke(BistroCampTheme.Colors.darkStroke, lineWidth: 1)
                .padding(3)
            Image(systemName: order == nil ? "takeoutbag.and.cup.and.straw.fill" : "fork.knife.circle.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(BistroCampTheme.Colors.tomato)
                .shadow(color: .white.opacity(0.9), radius: 0, x: 0, y: 1)
        }
        .frame(width: 46, height: 46)
        .shadow(color: .black.opacity(0.38), radius: 7, x: 0, y: 5)
    }

    private var subtitle: String {
        guard let order else {
            return "Waiting for the next guest"
        }

        return "Guest \(order.customerID.uuidString.prefix(4))"
    }

    private var statusText: String {
        order?.status.rawValue ?? "Idle"
    }

    private var statusIcon: String {
        switch order?.status {
        case .created:
            return "bell.fill"
        case .cooking:
            return "flame.fill"
        case .ready:
            return "sparkles"
        case .delivered:
            return "hand.thumbsup.fill"
        case .completed:
            return "star.fill"
        case nil:
            return "moon.zzz.fill"
        }
    }

    private var statusColor: Color {
        switch order?.status {
        case .created:
            return BistroCampTheme.Colors.cobalt
        case .cooking:
            return BistroCampTheme.Colors.hotYellow
        case .ready:
            return BistroCampTheme.Colors.neonGlass
        case .delivered, .completed:
            return BistroCampTheme.Colors.varnishOrange
        case nil:
            return BistroCampTheme.Colors.lead
        }
    }

    private var progress: Double {
        guard let order else {
            return 0
        }

        switch order.status {
        case .created:
            return 0.06
        case .cooking:
            guard order.recipe.duration > 0 else {
                return 1
            }

            return min(max(1 - order.remainingTime / order.recipe.duration, 0), 1)
        case .ready, .delivered, .completed:
            return 1
        }
    }

    private var progressLabel: String {
        guard let order else {
            return "--"
        }

        switch order.status {
        case .created:
            return "Waiting"
        case .cooking:
            return "\(Int(ceil(order.remainingTime)))s"
        case .ready:
            return "READY!"
        case .delivered:
            return "Delivered"
        case .completed:
            return "Done"
        }
    }
}

private struct CampStatusBadge: View {
    let text: String
    let color: Color
    let icon: String

    var body: some View {
        Label {
            CampOutlinedText(
                text: text,
                font: BistroCampTheme.Fonts.camp(11),
                fill: BistroCampTheme.Colors.cream,
                outline: .black.opacity(0.62),
                outlineWidth: 0.8
            )
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .black))
        }
        .foregroundStyle(BistroCampTheme.Colors.cream)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule(style: .continuous).fill(BistroCampTheme.plasticGradient(color)))
        .overlay(Capsule(style: .continuous).stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 2))
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

private struct CampScorePill: View {
    let served: Int
    let target: Int
    let lost: Int

    var body: some View {
        HStack(spacing: BistroCampTheme.Spacing.xSmall) {
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .black))

            Text("\(served)/\(target)")
                .font(BistroCampTheme.Fonts.score(13))
                .monospacedDigit()

            if lost > 0 {
                Text("Lost \(lost)")
                    .font(BistroCampTheme.Fonts.score(10))
                    .monospacedDigit()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule(style: .continuous).fill(BistroCampTheme.Colors.tomato.opacity(0.9)))
            }
        }
        .foregroundStyle(BistroCampTheme.Colors.cream)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule(style: .continuous).fill(BistroCampTheme.plasticGradient(BistroCampTheme.Colors.cobalt)))
        .overlay(Capsule(style: .continuous).stroke(BistroCampTheme.Colors.whiteStroke, lineWidth: 1.5))
        .shadow(color: .black.opacity(0.28), radius: 6, x: 0, y: 3)
    }
}

private struct CampScoreView: View {
    let served: Int
    let target: Int
    let lost: Int

    var body: some View {
        CampPanel(tint: BistroCampTheme.Colors.cobalt) {
            VStack(alignment: .leading, spacing: BistroCampTheme.Spacing.small) {
                CampOutlinedText(
                    text: "Score",
                    font: BistroCampTheme.Fonts.camp(13),
                    fill: BistroCampTheme.Colors.cream,
                    outline: .black.opacity(0.65),
                    outlineWidth: 1
                )

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(served)")
                        .font(BistroCampTheme.Fonts.score(27))
                    Text("/\(target)")
                        .font(BistroCampTheme.Fonts.score(15))
                }
                .foregroundStyle(BistroCampTheme.Colors.cream)
                .monospacedDigit()
                .shadow(color: .black.opacity(0.58), radius: 1, x: 0, y: 2)

                if lost > 0 {
                    CampStatusBadge(
                        text: "Lost \(lost)",
                        color: BistroCampTheme.Colors.tomato,
                        icon: "exclamationmark.triangle.fill"
                    )
                }
            }
        }
        .frame(width: 120, alignment: .leading)
    }
}

private struct CampStatusBubble: View {
    let text: String
    let eventID: Int

    var body: some View {
        CampPanel(tint: BistroCampTheme.Colors.cream, cornerRadius: BistroCampTheme.Radius.large) {
            HStack(spacing: BistroCampTheme.Spacing.medium) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(BistroCampTheme.Colors.tomato)

                Text(text)
                    .font(BistroCampTheme.Fonts.rounded(13, weight: .heavy))
                    .foregroundStyle(BistroCampTheme.Colors.graphite)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
        }
        .id(eventID)
        .transition(.asymmetric(insertion: .scale(scale: 0.94).combined(with: .opacity), removal: .opacity))
    }
}
