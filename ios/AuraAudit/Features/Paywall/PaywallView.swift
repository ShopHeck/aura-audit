import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var entitlements = EntitlementService()
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Unlock the Full Vibe Tribunal")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 14) {
                PaywallBullet(text: "Remove ads")
                PaywallBullet(text: "Unlock all premium audit modes")
                PaywallBullet(text: "Premium share-card styles")
                PaywallBullet(text: "More chaotic tribunal energy")
            }
            .padding(24)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await purchase() }
            } label: {
                HStack {
                    if isPurchasing { ProgressView() }
                    Text(isPurchasing ? "Unlocking..." : "Unlock Premium")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)

            Button("Restore Purchases") {
                Task { await restore() }
            }
            .font(.footnote.weight(.semibold))

            Spacer()

            Button("Not now") { dismiss() }
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(AuraBackground())
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            try await entitlements.purchasePremium()
            await entitlements.refreshEntitlements()
            appState.setPremium(entitlements.isPremium)
            if entitlements.isPremium { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() async {
        await entitlements.refreshEntitlements()
        appState.setPremium(entitlements.isPremium)
        if entitlements.isPremium { dismiss() }
    }
}

private struct PaywallBullet: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
            Text(text)
                .font(.headline)
        }
    }
}
