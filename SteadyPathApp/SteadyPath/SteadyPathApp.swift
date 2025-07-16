import SwiftUI
import SwiftData

@main
struct SteadyPathApp: App {
    // MARK: - SwiftData container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("FirstStart", systemImage: "person.fill.turn.down")
                    }
                
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                ExploreView()
                    .tabItem {
                        Label("Motivation", systemImage: "person.crop.circle")
                    }

                CheckInView()
                    .tabItem {
                        Label("CheckIn", systemImage: "checkmark.circle.fill")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
