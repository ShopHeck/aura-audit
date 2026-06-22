import Foundation

@MainActor
final class AdService: ObservableObject {
    @Published var adsEnabled = true

    func configure(isPremium: Bool) {
        adsEnabled = !isPremium
    }
}
