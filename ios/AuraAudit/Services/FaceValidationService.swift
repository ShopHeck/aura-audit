import UIKit
import Vision

enum FaceValidationError: LocalizedError {
    case noFace
    case multipleFaces
    case unreadableImage

    var errorDescription: String? {
        switch self {
        case .noFace:
            return "Aura Audit needs one clear selfie. No face was found."
        case .multipleFaces:
            return "Group auras are too legally complicated. Please use one clear selfie."
        case .unreadableImage:
            return "This image could not be checked. Try another selfie."
        }
    }
}

struct FaceValidationService {
    func validateSingleFace(in image: UIImage) async throws {
        guard let cgImage = image.cgImage else {
            throw FaceValidationError.unreadableImage
        }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation), options: [:])

        try handler.perform([request])
        let count = request.results?.count ?? 0

        if count == 0 { throw FaceValidationError.noFace }
        if count > 1 { throw FaceValidationError.multipleFaces }
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
