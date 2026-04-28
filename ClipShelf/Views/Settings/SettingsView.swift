import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ClipboardStore
    @AppStorage("clipshelf.hasSeenOnboarding") private var hasSeenOnboarding = true

    var body: some View {
        NavigationStack {
            List {
                Section("Experience") {
                    Label("Native light and dark mode", systemImage: "circle.lefthalf.filled")
                    Label("Dynamic Type ready", systemImage: "textformat.size")
                    Label("VoiceOver-friendly labels", systemImage: "figure.wave")
                }

                Section("Library Health") {
                    LabeledContent("Saved clips", value: "\(store.totalItemCount)")
                    LabeledContent("Pinned clips", value: "\(store.pinnedItems.count)")
                    LabeledContent("Image clips", value: "\(store.imageItemCount)")
                }

                Section("Privacy") {
                    Text("ClipShelf stores imported clips locally on the device. It does not require account creation or cloud sync in this version.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Support") {
                    Button("Replay Onboarding") {
                        hasSeenOnboarding = false
                    }

                    Button(role: .destructive) {
                        store.clearUnpinned()
                    } label: {
                        Text("Clear Unpinned Clips")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
