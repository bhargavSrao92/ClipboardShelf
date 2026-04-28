import SwiftUI
import UIKit

struct ClipboardRowCard: View {
    @EnvironmentObject private var store: ClipboardStore
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                if item.kind == .image {
                    imagePreview
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(item.kind == .image ? "Image clip" : "Text clip", systemImage: item.kind == .image ? "photo.fill.on.rectangle.fill" : "text.alignleft")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(item.kind == .image ? ClipShelfTheme.rose : ClipShelfTheme.accent)

                        Spacer()

                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(ClipShelfTheme.warmHighlight)
                                .accessibilityHidden(true)
                        }
                    }

                    Text(item.preview)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(item.kind == .image ? 2 : 4)
                        .multilineTextAlignment(.leading)

                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button {
                    store.copy(item)
                } label: {
                    Label(item.kind == .image ? "Copy Image" : "Copy Text", systemImage: "doc.on.doc.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    store.togglePinned(for: item)
                } label: {
                    Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash.fill" : "pin.fill")
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .font(.subheadline.weight(.medium))
        }
        .clipShelfCard()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var imagePreview: some View {
        if
            let data = store.imageData(for: item),
            let image = UIImage(data: data)
        {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14))
                )
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.secondary.opacity(0.14))
                .frame(width: 82, height: 82)
                .overlay(Image(systemName: "photo.fill").foregroundStyle(.secondary))
                .accessibilityHidden(true)
        }
    }
}
