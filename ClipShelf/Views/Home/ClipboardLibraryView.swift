import SwiftUI

struct ClipboardLibraryView: View {
    @EnvironmentObject private var store: ClipboardStore

    var body: some View {
        NavigationStack {
            List {
                if store.filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No matching clips",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search or import a fresh clip.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(store.filteredItems) { item in
                        NavigationLink {
                            ClipDetailView(item: item)
                        } label: {
                            ClipboardRowCard(item: item)
                                .environmentObject(store)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets, from: store.filteredItems)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(ClipShelfTheme.appBackground.ignoresSafeArea())
            .navigationTitle("Library")
            .searchable(text: $store.searchText, prompt: "Search text and images")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        store.clearUnpinned()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Clear unpinned clips")
                }
            }
        }
    }
}
