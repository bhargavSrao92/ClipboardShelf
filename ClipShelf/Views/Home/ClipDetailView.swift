import SwiftUI
import UIKit

struct ClipDetailView: View {
    @EnvironmentObject private var store: ClipboardStore
    let item: ClipboardItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                previewSection
                metadataSection
                actionSection
            }
            .padding()
        }
        .background(ClipShelfTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Clip Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(item.kind == .image ? "Image Preview" : "Text Preview", systemImage: item.kind == .image ? "photo.fill" : "text.quote")
                .font(.headline)

            if item.kind == .image, let data = store.imageData(for: item), let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .accessibilityLabel("Saved clipboard image")
            } else {
                Text(item.preview)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .clipShelfCard()
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clip Metadata")
                .font(.headline)

            LabeledContent("Type", value: item.kind == .image ? "Image" : "Text")
            LabeledContent("Created", value: item.createdAt.formatted(date: .complete, time: .shortened))
            LabeledContent("Pinned", value: item.isPinned ? "Yes" : "No")
        }
        .font(.subheadline)
        .clipShelfCard()
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Actions")
                .font(.headline)

            Button {
                store.copy(item)
            } label: {
                Label(item.kind == .image ? "Copy Image Again" : "Copy Text Again", systemImage: "doc.on.doc.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(ClipShelfTheme.accent)

            Button {
                store.togglePinned(for: item)
            } label: {
                Label(item.isPinned ? "Remove Pin" : "Pin to Top", systemImage: item.isPinned ? "pin.slash.fill" : "pin.fill")
            }
            .buttonStyle(.bordered)
        }
        .clipShelfCard()
    }
}
