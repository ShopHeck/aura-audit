import SwiftUI

struct ResultsView: View {
    let result: AuditResult
    @EnvironmentObject private var appState: AppState
    @State private var shareImage: UIImage?
    @State private var showShare = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreHero
                stats
                verdict
                roasts

                if !appState.isPremium {
                    AdPlaceholderView()
                }

                Button {
                    let renderer = ShareCardRenderer()
                    shareImage = renderer.render(result: result)
                    showShare = shareImage != nil
                } label: {
                    Text("Share My Audit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .background(AuraBackground())
        .navigationTitle("Your Audit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShare) {
            if let shareImage {
                ShareSheet(items: [shareImage, result.shareCaption])
            }
        }
    }

    private var scoreHero: some View {
        VStack(spacing: 10) {
            Text("Aura Score")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(result.auraScore)")
                .font(.system(size: 92, weight: .black, design: .rounded))
            Text(result.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var stats: some View {
        VStack(spacing: 12) {
            StatBar(title: "Main Character Energy", value: result.mainCharacterEnergy)
            StatBar(title: "Chaos Index", value: result.chaosIndex)
            StatBar(title: "NPC Risk", value: result.npcRisk)
            StatBar(title: "Group Chat Survival", value: result.groupChatSurvival)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var verdict: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Verdict")
                .font(.headline)
            Text("\"\(result.verdict)\"")
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var roasts: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tribunal Notes")
                .font(.headline)
            ForEach(result.roasts, id: \.self) { roast in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                    Text(roast)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct StatBar: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(value)")
                    .font(.subheadline.weight(.bold))
            }
            GeometryReader { proxy in
                Capsule()
                    .fill(.quaternary)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.primary)
                            .frame(width: proxy.size.width * CGFloat(value) / 100)
                    }
            }
            .frame(height: 8)
        }
    }
}
