import SwiftUI
import UniformTypeIdentifiers

struct HomeDashboardView: View {
    @EnvironmentObject private var store: ClipboardStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroSection
                    statsSection
                    quickPasteSection
                    pinnedSection
                    recentSection
                }
                .padding()
            }
            .background(ClipShelfTheme.appBackground.ignoresSafeArea())
            .navigationTitle("ClipShelf")
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your clipboard, curated.")
                .font(.largeTitle.weight(.bold))

            Text("A polished shelf for recent text, images, and the snippets you never want to lose.")
                .font(.body)
                .foregroundStyle(.secondary)

            if let message = nonEmptyMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(ClipShelfTheme.secondaryAccent)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(
                colors: [ClipShelfTheme.accent, ClipShelfTheme.secondaryAccent, ClipShelfTheme.warmHighlight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .foregroundStyle(.white)
        .accessibilityElement(children: .combine)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatPill(title: "Total", value: "\(store.totalItemCount)", tint: ClipShelfTheme.accent)
            StatPill(title: "Text", value: "\(store.textItemCount)", tint: ClipShelfTheme.secondaryAccent)
            StatPill(title: "Images", value: "\(store.imageItemCount)", tint: ClipShelfTheme.rose)
        }
    }

    private var quickPasteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Capture")
                .font(.title3.weight(.semibold))

            Text("Import with the native iOS paste control to keep the experience fast, familiar, and review-safe.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PasteButton(supportedContentTypes: [.plainText, .image]) { providers in
                store.importItemProviders(providers)
            }
            .labelStyle(.titleAndIcon)
            .buttonBorderShape(.capsule)
            .tint(ClipShelfTheme.accent)

            if let lastImported = store.lastImportedItem {
                NavigationLink {
                    ClipDetailView(item: lastImported)
                } label: {
                    Label("Open latest imported clip", systemImage: "arrow.up.right.circle.fill")
                        .font(.subheadline.weight(.medium))
                }
            }
        }
        .clipShelfCard()
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Pinned Essentials")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(store.pinnedItems.count)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if store.pinnedItems.isEmpty {
                Text("Pin useful clips to keep them at the top of your shelf.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(store.pinnedItems.prefix(3))) { item in
                    NavigationLink {
                        ClipDetailView(item: item)
                    } label: {
                        ClipboardRowCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Activity")
                    .font(.title3.weight(.semibold))
                Spacer()
                NavigationLink("See All") {
                    ClipboardLibraryView()
                }
                .font(.subheadline.weight(.medium))
            }

            if store.recentItems.isEmpty {
                ContentUnavailableView(
                    "No clips yet",
                    systemImage: "square.and.arrow.down.on.square",
                    description: Text("Copy something in another app, then use the Paste control to bring it into ClipShelf.")
                )
                .frame(maxWidth: .infinity)
                .clipShelfCard()
            } else {
                ForEach(store.recentItems.prefix(4)) { item in
                    NavigationLink {
                        ClipDetailView(item: item)
                    } label: {
                        ClipboardRowCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var nonEmptyMessage: String? {
        store.lastCopiedMessage.isEmpty ? nil : store.lastCopiedMessage
    }
}
