import SwiftUI
import SwiftData

@main
struct SteadyPathApp: App {
    @State private var showLaunch = true
    @State private var launchOpacity = 1.0
    @State private var mainOpacity = 0.0
    @State private var transitioning = false
    
    init() {
        let appearance = UITabBarAppearance()
           appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white  // 👈 Change to any UIColor
           
           UITabBar.appearance().standardAppearance = appearance
           if #available(iOS 15.0, *) {
               UITabBar.appearance().scrollEdgeAppearance = appearance
           }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // ContentView (Welcome screen)
                if showLaunch {
                    ContentView(onNext: {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            transitioning = true
                        }
                        
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                showLaunch = false
                                transitioning = false
                            }
                        }
                    })
                    .opacity(transitioning ? 0 : 1)
                    .zIndex(1)
                }
                
                // MainTabView (Main app UI)
                if !showLaunch {
                    MainTabView()
                        .transition(.opacity)
                        .zIndex(2)
                        .opacity(transitioning ? 0 : 1)
                }
            }
            .animation(.easeInOut(duration: 1.0), value: showLaunch)
        }
        .modelContainer(sharedModelContainer)
    }
}

@Observable
class DataModel {
    var userName: String = ""
}

var dataModel = DataModel()


extension Notification.Name {
    static let navigateToPill = Notification.Name("navigateToPill")
}
