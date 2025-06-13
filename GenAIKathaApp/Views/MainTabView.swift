import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: CommuteViewModel

    var body: some View {
        TabView {
            RouteSuggestionView()
                .tabItem {
                    Label("Routes", systemImage: "map")
                }
            
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            SustainabilityTrackerView()
                .tabItem {
                    Label("Impact", systemImage: "leaf")
                }
            
            CompletedRoutesView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    MainTabView().environmentObject(CommuteViewModel())
} 
