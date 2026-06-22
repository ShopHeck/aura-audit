import SwiftUI
import UIKit

@MainActor
struct ShareCardRenderer {
    func render(result: AuditResult) -> UIImage? {
        let card = ShareCardView(result: result)
            .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1
        return renderer.uiImage
    }
}
