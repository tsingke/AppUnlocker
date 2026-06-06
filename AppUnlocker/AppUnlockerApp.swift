import SwiftUI

@main
struct AppUnlockerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 540, maxWidth: 540,
                       minHeight: 420, maxHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }   // hide "New Window"
        }
    }
}
