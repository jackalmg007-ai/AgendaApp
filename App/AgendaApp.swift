import SwiftUI
import SwiftData

@main
struct AgendaApp: App {
    @State private var state = AgendaState()

    var body: some Scene {
        WindowGroup {
            AgendaShellView()
                .environment(state)
        }
        .modelContainer(for: TodoItem.self)
    }
}
