import PhotosUI
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var auditService = AuditService()

    @State private var selectedMode = AuditMode.defaults[0]
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var result: AuditResult?
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                modePicker
                uploadCard
                demoButton

                if !appState.isPremium {
                    AdPlaceholderView()
                }
            }
            .padding(20)
        }
        .background(AuraBackground())
        .navigationDestination(item: $result) { result in
            ResultsView(result: result)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .task(id: selectedPhoto) {
            await loadSelectedPhoto()
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("Aura Audit")
                .font(.system(size: 46, weight: .black, design: .rounded))
            Text("Upload a selfie. Get your vibe professionally judged by extremely unqualified AI.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose audit mode")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(appState.availableModes) { mode in
                    Button {
                        if mode.premium && !appState.isPremium {
                            showPaywall = true
                        } else {
                            selectedMode = mode
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(mode.name)
                                    .font(.subheadline.weight(.bold))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if mode.premium && !appState.isPremium {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                }
                            }
                            Text(mode.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(selectedMode.id == mode.id ? .ultraThinMaterial : .thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var uploadCard: some View {
        VStack(spacing: 16) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.thinMaterial)
                    .frame(height: 300)
                    .overlay {
                        VStack(spacing: 14) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 54, weight: .bold))
                            Text("One clear selfie. No group auras.")
                                .font(.headline)
                        }
                        .foregroundStyle(.secondary)
                    }
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text(selectedImage == nil ? "Choose Selfie" : "Choose Different Selfie")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)

            Button {
                Task { await runAudit() }
            } label: {
                HStack {
                    if auditService.isLoading {
                        ProgressView()
                    }
                    Text(auditService.isLoading ? "Consulting the Tribunal..." : "Audit My Aura")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedImage == nil || auditService.isLoading)

            if let error = auditService.errorMessage {
                Text(error)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var demoButton: some View {
        Button("Use Demo Result for App Review") {
            result = .demo
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
    }

    private func loadSelectedPhoto() async {
        guard let selectedPhoto else { return }
        if let data = try? await selectedPhoto.loadTransferable(type: Data.self), let image = UIImage(data: data) {
            selectedImage = image
        }
    }

    private func runAudit() async {
        guard let selectedImage else { return }
        if let audit = await auditService.audit(installId: appState.installId, mode: selectedMode, image: selectedImage) {
            result = audit
        }
    }
}
