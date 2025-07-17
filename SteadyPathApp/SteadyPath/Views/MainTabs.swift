import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
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
                    Label("Check-In", systemImage: "checkmark.circle.fill")
                }
            
            PillView()
                .tabItem {
                    Label("Medication", systemImage: "pill")
                }
                .onOpenURL { url in
                    // Handle the URL from widget
                    if url.scheme == "steadypath" && url.host == "pill" {
                        // Since we're already on PillView, we could refresh or do nothing
                        print("Widget tapped - already on PillView")
                    }
                }
        }
    }
}

