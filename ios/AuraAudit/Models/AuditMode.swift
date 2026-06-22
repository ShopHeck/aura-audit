import Foundation

struct AuditMode: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let premium: Bool
    let description: String

    static let defaults: [AuditMode] = [
        .init(id: "classic", name: "Classic Aura Audit", premium: false, description: "The default fictional vibe tribunal."),
        .init(id: "dating", name: "Dating App Audit", premium: true, description: "Playful dating app energy."),
        .init(id: "linkedin", name: "LinkedIn Aura Audit", premium: true, description: "Corporate networking aura."),
        .init(id: "group_chat", name: "Group Chat Audit", premium: true, description: "Group chat survival odds."),
        .init(id: "villain", name: "Villain Origin Audit", premium: true, description: "Comedic villain arc energy."),
        .init(id: "main_character", name: "Main Character Audit", premium: true, description: "Main character energy."),
        .init(id: "red_flag", name: "Red Flag Audit", premium: true, description: "Absurd fictional red flags."),
        .init(id: "npc", name: "NPC Risk Assessment", premium: true, description: "Internet-native NPC risk comedy.")
    ]
}
