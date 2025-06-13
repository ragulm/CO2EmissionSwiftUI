import SwiftUI
import MapKit

struct RouteSuggestionView: View {
    @EnvironmentObject var viewModel: CommuteViewModel
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingRouteDetails = false
    @State private var selectedRoute: Route?
    
    var body: some View {
        NavigationView {
            VStack {
                if isWithinPreferredCommuteWindow {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("It's your preferred commute time! Check for eco-friendly routes.")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                Map(coordinateRegion: $region)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()
                
                Form {
                    Section(header: Text("Route Details")) {
                        TextField("Start Location", text: $startLocation)
                        TextField("End Location", text: $endLocation)
                        
                        Button(action: findRoutes) {
                            Text("Find Routes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.blue)
                    }
                    
                    if viewModel.isLoading {
                        Section {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    
                    if !viewModel.suggestedRoutes.isEmpty {
                        Section(header: Text("Suggested Routes")) {
                            ForEach(viewModel.suggestedRoutes) { route in
                                RouteRowView(route: route)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedRoute = route
                                        showingRouteDetails = true
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Route Suggestions")
            .sheet(item: $selectedRoute) { route in
                RouteDetailView(route: route) {
                    viewModel.completeRoute(route)
                    selectedRoute = nil
                }
            }
            .alert(item: Binding(
                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Error"), message: Text(alertItem.message))
            }
        }
    }
    
    private func findRoutes() {
        // TODO: Implement actual geocoding and route finding
        // For now, using mock coordinates
        let mockStart = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mockEnd = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
        viewModel.fetchRouteSuggestions(
            from: mockStart,
            to: mockEnd,
            startName: startLocation.isEmpty ? "Current Location" : startLocation,
            endName: endLocation.isEmpty ? "Destination" : endLocation
        )
    }
    
    private var isWithinPreferredCommuteWindow: Bool {
        guard let user = viewModel.currentUser,
              let start = user.preferredCommuteStartTime,
              let end = user.preferredCommuteEndTime else { return false }
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let nowMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let startMinutes = (start.hour ?? 0) * 60 + (start.minute ?? 0)
        let endMinutes = (end.hour ?? 0) * 60 + (end.minute ?? 0)
        return nowMinutes >= startMinutes && nowMinutes <= endMinutes
    }
}

struct RouteDetailView: View {
    let route: Route
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Route Information")) {
                    InfoRow(title: "From", value: route.startLocationName)
                    InfoRow(title: "To", value: route.endLocationName)
                    InfoRow(title: "Method", value: route.commuteMethod.rawValue)
                    InfoRow(title: "Distance", value: String(format: "%.1f km", route.distance))
                    InfoRow(title: "Duration", value: formatDuration(route.duration))
                    InfoRow(title: "CO₂ Saved", value: String(format: "%.1f g", route.co2Saved))
                }
                
                Section(header: Text("Conditions")) {
                    InfoRow(title: "Weather", value: route.weatherCondition.rawValue.capitalized)
                    InfoRow(title: "Traffic", value: route.trafficCondition.rawValue.capitalized)
                }
                
                Section {
                    Button(action: onComplete) {
                        Text("Complete Route")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Route Details")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

struct RouteRowView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: commuteMethodIcon)
                    .foregroundColor(.blue)
                Text(route.commuteMethod.rawValue)
                    .font(.headline)
                Spacer()
                Text(formatDuration(route.duration))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text(String(format: "%.1f km", route.distance))
                Spacer()
                Text("Saves \(Int(route.co2Saved))g CO₂")
                    .foregroundColor(.green)
            }
            .font(.subheadline)
            
            HStack {
                Image(systemName: weatherIcon)
                    .foregroundColor(.orange)
                Text(route.weatherCondition.rawValue.capitalized)
                Spacer()
                Image(systemName: "car.fill")
                    .foregroundColor(trafficColor)
                Text(route.trafficCondition.rawValue.capitalized)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
    
    private var commuteMethodIcon: String {
        switch route.commuteMethod {
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .publicTransport: return "bus"
        case .carpooling: return "car.2"
        case .driving: return "car"
        }
    }
    
    private var weatherIcon: String {
        switch route.weatherCondition {
        case .sunny: return "sun.max"
        case .rainy: return "cloud.rain"
        case .cloudy: return "cloud"
        case .windy: return "wind"
        }
    }
    
    private var trafficColor: Color {
        switch route.trafficCondition {
        case .light: return .green
        case .moderate: return .yellow
        case .heavy: return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    RouteSuggestionView()
}
