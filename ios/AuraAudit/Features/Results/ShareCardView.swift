import SwiftUI

struct ShareCardView: View {
    let result: AuditResult

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .black, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 46) {
                VStack(spacing: 8) {
                    Text("AURA AUDIT")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .tracking(3)
                    Text("Your selfie has entered the vibe tribunal")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .opacity(0.82)
                }

                VStack(spacing: 14) {
                    Text("\(result.auraScore)")
                        .font(.system(size: 240, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.7)
                    Text(result.title)
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 44)
                }

                VStack(spacing: 22) {
                    ShareStat(title: "Main Character", value: result.mainCharacterEnergy)
                    ShareStat(title: "Chaos Index", value: result.chaosIndex)
                    ShareStat(title: "NPC Risk", value: result.npcRisk)
                    ShareStat(title: "Group Chat Survival", value: result.groupChatSurvival)
                }
                .padding(38)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 42, style: .continuous))

                Text("\"\(result.verdict)\"")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 56)

                Spacer()

                Text("Get yours: AuraAudit.app")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(1)
                    .padding(.bottom, 52)
            }
            .foregroundStyle(.white)
            .padding(.top, 90)
        }
    }
}

private struct ShareStat: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
                Text("\(value)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            }
            GeometryReader { proxy in
                Capsule()
                    .fill(.white.opacity(0.18))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white)
                            .frame(width: proxy.size.width * CGFloat(value) / 100)
                    }
            }
            .frame(height: 14)
        }
    }
}
