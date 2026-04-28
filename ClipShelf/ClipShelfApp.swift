import SwiftUI

@main
struct ClipShelfApp: App {
    @StateObject private var store = ClipboardStore(
        monitor: ClipboardMonitorService()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(store)
        }
    }
}
