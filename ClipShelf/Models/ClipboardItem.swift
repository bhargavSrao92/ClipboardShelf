import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case text
        case image
    }

    let id: UUID
    let kind: Kind
    let textContent: String?
    let imageFileName: String?
    let imageSignature: String?
    let createdAt: Date
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        textContent: String? = nil,
        imageFileName: String? = nil,
        imageSignature: String? = nil,
        createdAt: Date = .now,
        isPinned: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.textContent = textContent
        self.imageFileName = imageFileName
        self.imageSignature = imageSignature
        self.createdAt = createdAt
        self.isPinned = isPinned
    }

    var preview: String {
        switch kind {
        case .text:
            let trimmed = (textContent ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Empty clipboard text" : trimmed
        case .image:
            return "Clipboard image"
        }
    }

    var searchableText: String {
        switch kind {
        case .text:
            return textContent ?? ""
        case .image:
            return "image photo screenshot picture"
        }
    }
}
