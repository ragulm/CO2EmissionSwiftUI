import SwiftUI
import MapKit

struct RouteSuggestionView: View {
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var selectedCommuteMethod: CommuteMethod = .walking
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingRouteDetails = false
    @State private var selectedRoute: Route?
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()
                
                Form {
                    Section(header: Text("Route Details")) {
                        TextField("Start Location", text: $startLocation)
                        TextField("End Location", text: $endLocation)
                        
                        Picker("Commute Method", selection: $selectedCommuteMethod) {
                            ForEach(CommuteMethod.allCases) { method in
                                Text(method.rawValue).tag(method)
                            }
                        }
                    }
                    
                    Section(header: Text("Suggested Routes")) {
                        ForEach(mockRoutes) { route in
                            RouteRow(route: route)
                                .onTapGesture {
                                    selectedRoute = route
                                    showingRouteDetails = true
                                }
                        }
                    }
                }
            }
            .navigationTitle("Route Suggestions")
            .sheet(isPresented: $showingRouteDetails) {
                if let route = selectedRoute {
                    RouteDetailView(route: route)
                }
            }
        }
    }
}

struct RouteRow: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: commuteMethodIcon)
                    .foregroundColor(.green)
                Text(route.commuteMethod.rawValue)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f km", route.distance))
            }
            
            HStack {
                Text(String(format: "%.0f min", route.duration / 60))
                Spacer()
                Text(String(format: "CO₂ saved: %.1f kg", route.co2Savings))
                    .foregroundColor(.green)
            }
            .font(.subheadline)
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
}

struct RouteDetailView: View {
    let route: Route
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Route Information")) {
                    LabeledContent("Distance", value: String(format: "%.1f km", route.distance))
                    LabeledContent("Duration", value: String(format: "%.0f min", route.duration / 60))
                    LabeledContent("CO₂ Savings", value: String(format: "%.1f kg", route.co2Savings))
                }
                
                Section(header: Text("Weather")) {
                    LabeledContent("Condition", value: route.weatherCondition.condition.rawValue)
                    LabeledContent("Temperature", value: String(format: "%.1f°C", route.weatherCondition.temperature))
                }
                
                if let alternatives = route.alternativeRoutes {
                    Section(header: Text("Alternative Routes")) {
                        ForEach(alternatives) { route in
                            RouteRow(route: route)
                        }
                    }
                }
            }
            .navigationTitle("Route Details")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// Mock data for preview
let mockRoutes: [Route] = [
    Route(
        startLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        endLocation: CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167),
        commuteMethod: .cycling,
        distance: 2.5,
        duration: 900,
        co2Savings: 1.01,
        weatherCondition: WeatherCondition(temperature: 22, condition: .sunny, windSpeed: 5, precipitation: 0),
        isEcoFriendly: true,
        alternativeRoutes: nil
    )
]

#Preview {
    RouteSuggestionView()
} 
