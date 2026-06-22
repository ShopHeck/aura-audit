import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var hasAcceptedConsent: Bool
    @Published var isPremium: Bool
    @Published var availableModes: [AuditMode] = AuditMode.defaults

    let installId: String

    init() {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: "install_id") {
            self.installId = existing
        } else {
            let created = UUID().uuidString
            defaults.set(created, forKey: "install_id")
            self.installId = created
        }

        self.hasAcceptedConsent = defaults.bool(forKey: "has_accepted_consent")
        self.isPremium = defaults.bool(forKey: "is_premium")
    }

    func acceptConsent() {
        hasAcceptedConsent = true
        UserDefaults.standard.set(true, forKey: "has_accepted_consent")
    }

    func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.set(value, forKey: "is_premium")
    }
}
