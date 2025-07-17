//
//  SteadyPathApp.swift
//  SteadyPath
//
//  Created by Jeremy Nagel on 16/7/2025.
//

import SwiftUI

@main
struct SteadyPathApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                PillView()
                    .tabItem {
                        Label("Pill", systemImage: "pill")
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
}

extension Notification.Name {
    static let navigateToPill = Notification.Name("navigateToPill")
}
