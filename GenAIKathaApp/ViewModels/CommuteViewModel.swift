import Foundation
import CoreLocation
import Combine

class CommuteViewModel: ObservableObject {
    @Published var currentUser: User? {
        didSet {
            if let user = currentUser {
                saveUser(user)
            }
        }
    }
    @Published var suggestedRoutes: [Route] = []
    @Published var selectedRoute: Route?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var completedRoutes: [Route] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUser()
        loadCompletedRoutes()
        // Calculate initial sustainability metrics from completed routes
        if let user = currentUser {
            updateSustainabilityMetricsFromCompletedRoutes(for: user)
        }
    }
    
    // MARK: - User Profile Management
    func createUserProfile(name: String, preferredCommuteMethod: CommutePreference, ecoPreferences: [User.EcoPreference]) {
        currentUser = User(
            name: name,
            preferredCommuteMethod: preferredCommuteMethod,
            ecoPreferences: ecoPreferences
        )
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
    }
    
    private func loadUser() {
        if let savedUser = UserDefaults.standard.data(forKey: "savedUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            currentUser = decodedUser
        }
    }
    
    // MARK: - Route Management
    func fetchRouteSuggestions(from startLocation: CLLocationCoordinate2D, to endLocation: CLLocationCoordinate2D, startName: String, endName: String) {
        isLoading = true
        
        // TODO: Implement actual API calls to:
        // 1. Google Maps API for route data
        // 2. OpenWeatherMap API for weather data
        // 3. Traffic data API
        
        // For now, using mock data with more route options
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.suggestedRoutes = [
                Route(
                    startLocation: startLocation,
                    endLocation: endLocation,
                    commuteMethod: .cycling,
                    distance: 5.2,
                    duration: 1800,
                    weatherCondition: .sunny,
                    trafficCondition: .light,
                    co2Saved: 1200,
                    startLocationName: startName,
                    endLocationName: endName
                ),
                Route(
                    startLocation: startLocation,
                    endLocation: endLocation,
                    commuteMethod: .publicTransport,
                    distance: 6.0,
                    duration: 2400,
                    weatherCondition: .sunny,
                    trafficCondition: .moderate,
                    co2Saved: 800,
                    startLocationName: startName,
                    endLocationName: endName
                ),
                Route(
                    startLocation: startLocation,
                    endLocation: endLocation,
                    commuteMethod: .walking,
                    distance: 4.8,
                    duration: 3600,
                    weatherCondition: .sunny,
                    trafficCondition: .light,
                    co2Saved: 1500,
                    startLocationName: startName,
                    endLocationName: endName
                ),
                Route(
                    startLocation: startLocation,
                    endLocation: endLocation,
                    commuteMethod: .carpooling,
                    distance: 5.5,
                    duration: 2100,
                    weatherCondition: .sunny,
                    trafficCondition: .moderate,
                    co2Saved: 600,
                    startLocationName: startName,
                    endLocationName: endName
                )
            ]
            self?.isLoading = false
        }
    }
    
    func completeRoute(_ route: Route) {
        var completedRoute = route
        completedRoute.isCompleted = true
        completedRoute.completedAt = Date()
        
        completedRoutes.append(completedRoute)
        saveCompletedRoutes()
        
        // Update user's sustainability metrics
        updateSustainabilityMetrics(for: completedRoute)
        
        // Remove from suggested routes
        suggestedRoutes.removeAll { $0.id == route.id }
        
        // Force UI update
        objectWillChange.send()
    }
    
    private func saveCompletedRoutes() {
        if let encoded = try? JSONEncoder().encode(completedRoutes) {
            UserDefaults.standard.set(encoded, forKey: "completedRoutes")
        }
    }
    
    private func loadCompletedRoutes() {
        if let savedRoutes = UserDefaults.standard.data(forKey: "completedRoutes"),
           let decodedRoutes = try? JSONDecoder().decode([Route].self, from: savedRoutes) {
            completedRoutes = decodedRoutes
        }
    }
    
    // MARK: - Sustainability Tracking
    func updateSustainabilityMetrics(for route: Route) {
        guard var user = currentUser else { return }
        
        // Update metrics
        user.totalGreenKilometers += route.distance
        user.totalCO2Saved += route.co2Saved
        
        // Save updated user
        currentUser = user
        saveUser(user)
        
        // Force UI update
        objectWillChange.send()
    }
    
    private func updateSustainabilityMetricsFromCompletedRoutes(for user: User) {
        var updatedUser = user
        var totalDistance: Double = 0
        var totalCO2Saved: Double = 0
        
        for route in completedRoutes {
            totalDistance += route.distance
            totalCO2Saved += route.co2Saved
        }
        
        updatedUser.totalGreenKilometers = totalDistance
        updatedUser.totalCO2Saved = totalCO2Saved
        
        currentUser = updatedUser
        saveUser(updatedUser)
    }
    
    // MARK: - Notifications
    func checkForAlerts(route: Route) {
        // Check weather conditions
        if route.weatherCondition == .rainy && route.commuteMethod == .cycling {
            // Send notification about rain warning for cyclists
            NotificationCenter.default.post(
                name: NSNotification.Name("WeatherAlert"),
                object: nil,
                userInfo: ["message": "Rain expected during your cycling route"]
            )
        }
        
        // Check traffic conditions
        if route.trafficCondition == .heavy {
            // Send notification about heavy traffic
            NotificationCenter.default.post(
                name: NSNotification.Name("TrafficAlert"),
                object: nil,
                userInfo: ["message": "Heavy traffic detected on your route"]
            )
        }
    }
}
