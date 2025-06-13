import Foundation
import CoreLocation


struct Route: Identifiable, Codable {
    var id: UUID = UUID()
    var startLocation: CLLocationCoordinate2D
    var endLocation: CLLocationCoordinate2D
    var commuteMethod: CommutePreference
    var distance: Double // in kilometers
    var duration: TimeInterval // in seconds
    var weatherCondition: WeatherCondition
    var trafficCondition: TrafficCondition
    var co2Saved: Double // in grams
    var isCompleted: Bool = false
    var completedAt: Date?
    var startLocationName: String
    var endLocationName: String
    
    enum WeatherCondition: String, Codable {
        case sunny
        case rainy
        case cloudy
        case windy
    }
    
    enum TrafficCondition: String, Codable {
        case light
        case moderate
        case heavy
    }
}

// Extension to make CLLocationCoordinate2D codable
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
