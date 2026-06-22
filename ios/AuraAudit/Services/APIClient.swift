import Foundation
import UIKit

enum APIError: LocalizedError {
    case invalidImage
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image could not be prepared."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .server(let message):
            return message
        }
    }
}

struct APIClient {
    var baseURL = URL(string: "https://api.auraaudit.app")!
    var appSharedSecret = "REPLACE_WITH_NON_SENSITIVE_APP_SHARED_SECRET"

    func fetchModes() async throws -> [AuditMode] {
        let url = baseURL.appending(path: "/v1/modes")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder().decode(ModesResponse.self, from: data).modes
    }

    func createAudit(installId: String, mode: AuditMode, image: UIImage) async throws -> AuditResultEnvelope {
        guard let jpeg = image.jpegData(compressionQuality: 0.72) else {
            throw APIError.invalidImage
        }

        let payload = AuditRequest(
            installId: installId,
            mode: mode.id,
            imageBase64: jpeg.base64EncodedString(),
            imageMimeType: "image/jpeg"
        )

        var request = URLRequest(url: baseURL.appending(path: "/v1/audits"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appSharedSecret, forHTTPHeaderField: "X-Aura-App-Secret")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        return try JSONDecoder().decode(AuditResultEnvelope.self, from: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.server(apiError.error)
            }
            throw APIError.server("Server error: \(http.statusCode)")
        }
    }
}

private struct ModesResponse: Codable {
    let modes: [AuditMode]
}

private struct AuditRequest: Codable {
    let installId: String
    let mode: String
    let imageBase64: String
    let imageMimeType: String
}

private struct APIErrorResponse: Codable {
    let error: String
}
