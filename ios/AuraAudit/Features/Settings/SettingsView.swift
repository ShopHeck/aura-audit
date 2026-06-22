import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Aura Audit") {
                Link("Privacy Policy", destination: URL(string: "https://auraaudit.app/privacy")!)
                Link("Terms of Use", destination: URL(string: "https://auraaudit.app/terms")!)
                Link("Support", destination: URL(string: "https://auraaudit.app/support")!)
            }
        }
        .navigationTitle("Settings")
    }
}
