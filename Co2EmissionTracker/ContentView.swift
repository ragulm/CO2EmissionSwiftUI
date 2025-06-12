//
//  Co2EmissionTrackerApp.swift
//  Co2EmissionTracker
//
//  Created by M L Ragul on 12/06/25.
//

import SwiftUI
import SwiftData

@main
struct Co2EmissionTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                RouteSuggestionView()
                    .tabItem {
                        Label("Routes", systemImage: "map.fill")
                    }
                
                SustainabilityTrackerView()
                    .tabItem {
                        Label("Sustainability", systemImage: "leaf.fill")
                    }
                
                UserProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
