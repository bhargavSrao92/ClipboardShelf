import CryptoKit
import Foundation
import UIKit

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published var searchText = ""
    @Published var lastCopiedMessage = ""

    var filteredItems: [ClipboardItem] {
        let sorted = sortedItems

        guard !searchText.isEmpty else {
            return sorted
        }

        return sorted.filter { $0.searchableText.localizedCaseInsensitiveContains(searchText) }
    }

    var pinnedItems: [ClipboardItem] {
        sortedItems.filter(\.isPinned)
    }

    var recentItems: [ClipboardItem] {
        Array(sortedItems.prefix(12))
    }

    var totalItemCount: Int {
        items.count
    }

    var textItemCount: Int {
        items.filter { $0.kind == .text }.count
    }

    var imageItemCount: Int {
        items.filter { $0.kind == .image }.count
    }

    var lastImportedItem: ClipboardItem? {
        sortedItems.first
    }

    private var sortedItems: [ClipboardItem] {
        items.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned && !rhs.isPinned
            }

            return lhs.createdAt > rhs.createdAt
        }
    }

    private let monitor: ClipboardMonitoring
    private let defaults: UserDefaults
    private let itemsKey = "clipshelf.items"
    private var imagesDirectoryURL: URL?

    init(
        monitor: ClipboardMonitoring,
        defaults: UserDefaults = .standard
    ) {
        self.monitor = monitor
        self.defaults = defaults
        self.items = Self.loadItems(from: defaults, key: itemsKey)
        self.imagesDirectoryURL = Self.makeImagesDirectory()
    }

    func importItemProviders(_ providers: [NSItemProvider]) {
        guard !providers.isEmpty else {
            lastCopiedMessage = "Nothing supported found on the clipboard."
            return
        }

        for provider in providers {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                    guard let image = object as? UIImage else {
                        return
                    }

                    Task { @MainActor in
                        self?.importImage(image)
                    }
                }
                return
            }

            if provider.canLoadObject(ofClass: NSString.self) {
                provider.loadObject(ofClass: NSString.self) { [weak self] object, _ in
                    guard let text = object as? String else {
                        return
                    }

                    Task { @MainActor in
                        self?.importText(text)
                    }
                }
                return
            }
        }

        lastCopiedMessage = "This clipboard item is not supported yet."
    }

    func copy(_ item: ClipboardItem) {
        monitor.copyToClipboard(item, imageData: imageData(for: item))
        lastCopiedMessage = item.kind == .image ? "Image copied back to your clipboard." : "Text copied back to your clipboard."
    }

    func delete(at offsets: IndexSet, from source: [ClipboardItem]) {
        let itemsToDelete = offsets.map { source[$0] }
        itemsToDelete.forEach(delete)
    }

    func delete(_ item: ClipboardItem) {
        removeStoredImageIfNeeded(for: item)
        items.removeAll { $0.id == item.id }
        persistItems()
    }

    func clearUnpinned() {
        let removedItems = items.filter { !$0.isPinned }
        removedItems.forEach(removeStoredImageIfNeeded)
        items.removeAll { !$0.isPinned }
        persistItems()
        lastCopiedMessage = "Unpinned items cleared."
    }

    func togglePinned(for item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index].isPinned.toggle()
        persistItems()
    }

    func imageData(for item: ClipboardItem) -> Data? {
        guard
            item.kind == .image,
            let fileName = item.imageFileName,
            let directoryURL = imagesDirectoryURL
        else {
            return nil
        }

        return try? Data(contentsOf: directoryURL.appendingPathComponent(fileName))
    }

    private func importText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastCopiedMessage = "Clipboard text is empty."
            return
        }

        if let existingIndex = items.firstIndex(where: { $0.kind == .text && $0.textContent == trimmed }) {
            var existing = items.remove(at: existingIndex)
            existing = ClipboardItem(
                id: existing.id,
                kind: .text,
                textContent: trimmed,
                createdAt: .now,
                isPinned: existing.isPinned
            )
            items.insert(existing, at: 0)
        } else {
            items.insert(
                ClipboardItem(
                    kind: .text,
                    textContent: trimmed
                ),
                at: 0
            )
        }

        trimHistoryIfNeeded()
        persistItems()
        lastCopiedMessage = "Text imported successfully."
    }

    private func importImage(_ image: UIImage) {
        guard
            let imageData = image.pngData() ?? image.jpegData(compressionQuality: 0.95),
            let directoryURL = imagesDirectoryURL
        else {
            lastCopiedMessage = "Could not save that image."
            return
        }

        let signature = Self.signature(for: imageData)

        if let existingIndex = items.firstIndex(where: { $0.kind == .image && $0.imageSignature == signature }) {
            var existing = items.remove(at: existingIndex)
            existing = ClipboardItem(
                id: existing.id,
                kind: .image,
                imageFileName: existing.imageFileName,
                imageSignature: existing.imageSignature,
                createdAt: .now,
                isPinned: existing.isPinned
            )
            items.insert(existing, at: 0)
            persistItems()
            lastCopiedMessage = "Image imported successfully."
            return
        }

        let fileName = "\(UUID().uuidString).png"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL, options: .atomic)
        } catch {
            lastCopiedMessage = "Could not save that image."
            return
        }

        items.insert(
            ClipboardItem(
                kind: .image,
                imageFileName: fileName,
                imageSignature: signature
            ),
            at: 0
        )

        trimHistoryIfNeeded()
        persistItems()
        lastCopiedMessage = "Image imported successfully."
    }

    private func trimHistoryIfNeeded() {
        guard items.count > 100 else {
            return
        }

        let removedItems = Array(items.dropFirst(100))
        removedItems.forEach(removeStoredImageIfNeeded)
        items = Array(items.prefix(100))
    }

    private func removeStoredImageIfNeeded(for item: ClipboardItem) {
        guard
            item.kind == .image,
            let fileName = item.imageFileName,
            let directoryURL = imagesDirectoryURL
        else {
            return
        }

        try? FileManager.default.removeItem(at: directoryURL.appendingPathComponent(fileName))
    }

    private func persistItems() {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: itemsKey)
        }
    }

    private static func signature(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func loadItems(from defaults: UserDefaults, key: String) -> [ClipboardItem] {
        guard
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data)
        else {
            return []
        }

        return decoded
    }

    private static func makeImagesDirectory() -> URL? {
        guard let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let directoryURL = baseURL.appendingPathComponent("ClipboardImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }
}
