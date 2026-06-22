import SwiftUI

struct ConsentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 12) {
                Text("Aura Audit")
                    .font(.system(size: 48, weight: .black, design: .rounded))

                Text("Your selfie has entered the vibe tribunal.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                ConsentBullet(icon: "person.crop.circle.badge.checkmark", text: "Upload only your own selfie or a photo you have permission to use.")
                ConsentBullet(icon: "sparkles", text: "Aura Audit is fictional entertainment, not a real evaluation.")
                ConsentBullet(icon: "shield.lefthalf.filled", text: "We do not evaluate attractiveness, identity, health, intelligence, or real personality.")
            }
            .padding(24)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

            Spacer()

            Button {
                appState.acceptConsent()
            } label: {
                Text("I Understand")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .background(AuraBackground())
    }
}

private struct ConsentBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
            Text(text)
                .font(.body.weight(.medium))
        }
    }
}
