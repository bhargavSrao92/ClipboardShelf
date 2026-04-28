import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ClipboardLibraryView()
                .tabItem {
                    Label("Library", systemImage: "square.stack.3d.up.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(ClipShelfTheme.accent)
    }
}
