import SwiftUI

struct AdPlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.thinMaterial)
            .frame(height: 72)
            .overlay {
                Text("Ad placement for free users")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .accessibilityHidden(true)
    }
}
