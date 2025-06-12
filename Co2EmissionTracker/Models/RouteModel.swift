import Foundation
import CoreLocation

struct Route: Identifiable {
    let id = UUID()
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D
    let commuteMethod: CommuteMethod
    let distance: Double // in kilometers
    let duration: TimeInterval
    let co2Savings: Double // in kg
    let weatherCondition: WeatherCondition
    let isEcoFriendly: Bool
    let alternativeRoutes: [Route]?
}

struct WeatherCondition: Codable {
    let temperature: Double
    let condition: WeatherType
    let windSpeed: Double
    let precipitation: Double
    
    enum WeatherType: String, Codable {
        case sunny
        case cloudy
        case rainy
        case snowy
        case stormy
    }
}

struct RouteSuggestion {
    let routes: [Route]
    let bestRoute: Route
    let weatherAlerts: [WeatherAlert]
    
    struct WeatherAlert {
        let type: AlertType
        let message: String
        let severity: Severity
        
        enum AlertType {
            case rain
            case storm
            case heat
            case cold
        }
        
        enum Severity {
            case low
            case medium
            case high
        }
    }
}

// CO2 emission constants (in kg per km)
enum CO2Emission {
    static let car = 0.404
    static let bus = 0.101
    static let train = 0.041
    static let walking = 0.0
    static let cycling = 0.0
    static let carpooling = 0.202 // Assuming 2 people sharing
} 