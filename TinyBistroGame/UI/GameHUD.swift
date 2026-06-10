import SwiftUI

struct GameHUD: View {
    let world: BistroWorld
    var onStartCooking: () -> Void
    var onDeliver: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                statusPanel
                Spacer()
                orderPanel
            }

            Spacer()

            HStack {
                Button(action: onStartCooking) {
                    Label("Cook", systemImage: "flame.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(world.activeOrder?.status != .created)

                Button(action: onDeliver) {
                    Label("Deliver", systemImage: "takeoutbag.and.cup.and.straw.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(world.activeOrder?.status != .ready)

                Spacer()
            }
        }
        .padding(16)
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tiny Bistro")
                .font(.headline)
            Text(world.statusMessage)
                .font(.subheadline)
                .lineLimit(3)
            Text("Served: \(world.servedCustomers)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: 280, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var orderPanel: some View {
        if let order = world.activeOrder {
            VStack(alignment: .leading, spacing: 8) {
                Text(order.recipe.name)
                    .font(.headline)
                Text(order.status.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(order.status == .ready ? .green : .primary)

                ProgressView(value: progress(for: order))
                    .progressViewStyle(.linear)

                Text(timeText(for: order))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(width: 210, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func progress(for order: Order) -> Double {
        guard order.status == .cooking || order.status == .ready else {
            return 0
        }

        if order.status == .ready {
            return 1
        }

        return 1 - (order.remainingTime / order.recipe.duration)
    }

    private func timeText(for order: Order) -> String {
        switch order.status {
        case .created:
            return "Waiting"
        case .cooking:
            return "\(Int(ceil(order.remainingTime)))s"
        case .ready:
            return "Ready"
        case .delivered:
            return "Delivered"
        case .completed:
            return "Done"
        }
    }
}
