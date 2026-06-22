import UIKit

@MainActor
final class AuditService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIClient()
    private let faceValidator = FaceValidationService()

    func audit(installId: String, mode: AuditMode, image: UIImage) async -> AuditResult? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await faceValidator.validateSingleFace(in: image)
            let envelope = try await api.createAudit(installId: installId, mode: mode, image: image)
            return envelope.result
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
