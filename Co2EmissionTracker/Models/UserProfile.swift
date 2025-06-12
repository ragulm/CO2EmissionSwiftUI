import Foundation

enum CommuteMethod: String, CaseIterable, Identifiable, Codable {
    case walking = "Walking"
    case cycling = "Cycling"
    case publicTransport = "Public Transport"
    case carpooling = "Carpooling"
    case driving = "Driving"
    
    var id: String { self.rawValue }
}

struct UserProfile: Codable {
    var name: String
    var preferredCommuteMethod: CommuteMethod
    var ecoPreferences: EcoPreferences
    var totalGreenKilometers: Double
    var totalCO2Saved: Double
    
    struct EcoPreferences: Codable {
        var preferCarpooling: Bool
        var prioritizeBiking: Bool
        var avoidHighways: Bool
        var preferShadedRoutes: Bool
    }
    
    static var `default`: UserProfile {
        UserProfile(
            name: "",
            preferredCommuteMethod: .walking,
            ecoPreferences: EcoPreferences(
                preferCarpooling: false,
                prioritizeBiking: false,
                avoidHighways: false,
                preferShadedRoutes: false
            ),
            totalGreenKilometers: 0.0,
            totalCO2Saved: 0.0
        )
    }
} 