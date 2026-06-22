import Foundation

struct AuditResultEnvelope: Codable {
    let auditId: String
    let result: AuditResult
}

struct AuditResult: Codable, Hashable {
    let mode: String
    let auraScore: Int
    let mainCharacterEnergy: Int
    let chaosIndex: Int
    let npcRisk: Int
    let groupChatSurvival: Int
    let title: String
    let verdict: String
    let roasts: [String]
    let warnings: [String]
    let shareCaption: String

    static let demo = AuditResult(
        mode: "classic",
        auraScore: 87,
        mainCharacterEnergy: 91,
        chaosIndex: 64,
        npcRisk: 12,
        groupChatSurvival: 43,
        title: "Dangerously Unavailable Energy",
        verdict: "You look like you say 'I'm chill' and then send a 900-word clarification text.",
        roasts: [
            "Your aura has push notifications turned off.",
            "Main character energy, but the plot is buffering.",
            "You look like brunch could become a brand strategy meeting."
        ],
        warnings: [
            "May overthink a thumbs-up reaction.",
            "Could accidentally soft-launch a situationship."
        ],
        shareCaption: "My Aura Audit score was 87 and I feel personally audited."
    )
}
