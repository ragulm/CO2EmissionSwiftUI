//
//  ContentView.swift
//  GenAIKathaApp
//
//  Created by M L Ragul on 12/06/25.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @StateObject private var viewModel = CommuteViewModel()
    
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

    var body: some View {
        
//        WindowGroup {
//            TabView {
//                RouteSuggestionView()
//                    .tabItem {
//                        Label("Routes", systemImage: "map")
//                    }
//                
//                UserProfileView()
//                    .tabItem {
//                        Label("Profile", systemImage: "person")
//                    }
//                
//                SustainabilityTrackerView()
//                    .tabItem {
//                        Label("Impact", systemImage: "leaf")
//                    }
//            }
        
        MainTabView()
            .environmentObject(viewModel)
            .onAppear {
                if let user = viewModel.currentUser {
                    NotificationManager.shared.scheduleCommuteReminder(for: user)
                    prefetchRoutesIfNeeded(for: user)
                }
            }
            .onChange(of: viewModel.currentUser) { user in
                if let user = user {
                    NotificationManager.shared.scheduleCommuteReminder(for: user)
                    prefetchRoutesIfNeeded(for: user)
                }
            }
        .modelContainer(sharedModelContainer)
    }

private func prefetchRoutesIfNeeded(for user: User) {
    guard let start = user.preferredCommuteStartTime, let end = user.preferredCommuteEndTime else { return }
    let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
    let nowMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
    let startMinutes = (start.hour ?? 0) * 60 + (start.minute ?? 0)
    let endMinutes = (end.hour ?? 0) * 60 + (end.minute ?? 0)
    if nowMinutes >= startMinutes && nowMinutes <= endMinutes {
        // Pre-fetch routes for the user's preferred window (mock locations)
        let mockStart = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mockEnd = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
        viewModel.fetchRouteSuggestions(
            from: mockStart,
            to: mockEnd,
            startName: "Current Location",
            endName: "Destination"
        )
    }
}

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
