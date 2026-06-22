# Aura Audit iOS Starter

This folder contains SwiftUI source files for the Aura Audit iOS app. To create the actual Xcode project:

1. Open Xcode.
2. Create a new iOS App project named `AuraAudit`.
3. Set interface to SwiftUI and language to Swift.
4. Set minimum deployment target to iOS 17.0 for the first build.
5. Drag the `AuraAudit` source folder into the Xcode project.
6. Add these capabilities/frameworks as needed:
   - StoreKit for in-app purchases.
   - PhotosUI for photo picking.
   - Vision for on-device face validation.
   - Google Mobile Ads SDK when replacing `AdPlaceholderView`.
7. Replace API constants in `Services/APIClient.swift`.
8. Add privacy strings to Info.plist:
   - `NSCameraUsageDescription`: Aura Audit uses the camera so you can take a selfie for a fictional vibe report.
   - `NSPhotoLibraryUsageDescription`: Aura Audit lets you choose a selfie for a fictional vibe report.

The current ad integration is a placeholder so the project remains easy to compile before adding AdMob.
