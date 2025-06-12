import Foundation
import CoreLocation

class APIService {
    static let shared = APIService()
    private let weatherAPIKey = "YOUR_OPENWEATHERMAP_API_KEY" // Replace with actual API key
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    private init() {}
    
    // MARK: - Weather API
    
    func fetchWeather(for location: CLLocationCoordinate2D) async throws -> WeatherCondition {
        let urlString = "\(baseURL)/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(weatherAPIKey)&units=metric"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        
        return WeatherCondition(
            temperature: weatherResponse.main.temp,
            condition: mapWeatherCondition(weatherResponse.weather.first?.main ?? ""),
            windSpeed: weatherResponse.wind.speed,
            precipitation: weatherResponse.rain?.oneHour ?? 0
        )
    }
    
    // MARK: - Route API
    
    func fetchRoutes(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        commuteMethod: CommuteMethod
    ) async throws -> [Route] {
        // TODO: Implement actual route fetching using MapKit or a third-party API
        // For now, return mock data
        return mockRoutes
    }
    
    // MARK: - Helper Methods
    
    private func mapWeatherCondition(_ condition: String) -> WeatherCondition.WeatherType {
        switch condition.lowercased() {
        case "clear": return .sunny
        case "clouds": return .cloudy
        case "rain", "drizzle": return .rainy
        case "snow": return .snowy
        case "thunderstorm": return .stormy
        default: return .sunny
        }
    }
}

// MARK: - API Models

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let rain: Rain?
    
    struct Weather: Codable {
        let main: String
        let description: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Int
    }
    
    struct Wind: Codable {
        let speed: Double
    }
    
    struct Rain: Codable {
        let oneHour: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
} 