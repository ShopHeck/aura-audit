import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            if appState.hasAcceptedConsent {
                HomeView()
            } else {
                ConsentView()
            }
        }
    }
}
