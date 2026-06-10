import SwiftUI

struct BistroHUD: View {
    let world: BistroWorld
    var onStartCooking: () -> Void
    var onDeliver: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Spacer(minLength: BistroTheme.Spacing.large)

            bottomBar
        }
        .padding(.horizontal, BistroTheme.Spacing.large)
        .padding(.vertical, BistroTheme.Spacing.medium)
        .animation(.easeInOut(duration: 0.22), value: world.lastEventID)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: world.activeOrder?.status.rawValue ?? "none")
    }

    private var topBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: BistroTheme.Spacing.medium) {
                BistroTicketView(order: world.activeOrder)
                    .layoutPriority(1)

                Spacer(minLength: BistroTheme.Spacing.medium)

                scoreView
            }

            VStack(alignment: .trailing, spacing: BistroTheme.Spacing.small) {
                BistroTicketView(order: world.activeOrder)
                scoreView
            }
        }
    }

    private var bottomBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom, spacing: BistroTheme.Spacing.medium) {
                statusBar
                    .frame(maxWidth: 520)

                Spacer(minLength: BistroTheme.Spacing.small)

                commandButtons
            }

            VStack(alignment: .leading, spacing: BistroTheme.Spacing.small) {
                statusBar
                commandButtons
            }
        }
    }

    private var scoreView: some View {
        BistroScoreView(
            served: world.servedCustomers,
            target: world.targetServed,
            lost: world.lostCustomers
        )
    }

    private var statusBar: some View {
        BistroStatusBar(text: world.statusMessage, eventID: world.lastEventID)
    }

    private var commandButtons: some View {
        HStack(spacing: BistroTheme.Spacing.small) {
            BistroButton(
                title: "Cook",
                systemImage: "flame.fill",
                isEnabled: world.activeOrder?.status == .created,
                action: onStartCooking
            )

            BistroButton(
                title: "Deliver",
                systemImage: "takeoutbag.and.cup.and.straw.fill",
                isEnabled: world.activeOrder?.status == .ready,
                action: onDeliver
            )
        }
    }
}
