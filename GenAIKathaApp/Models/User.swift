import Foundation

enum CommutePreference: String, CaseIterable, Codable, Equatable {
    case walking = "Walking"
    case cycling = "Cycling"
    case publicTransport = "Public Transport"
    case carpooling = "Carpooling"
    case driving = "Driving"
}

struct User: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var preferredCommuteMethod: CommutePreference
    var ecoPreferences: [EcoPreference]
    var totalGreenKilometers: Double = 0
    var totalCO2Saved: Double = 0
    var preferredCommuteStartTime: DateComponents? = nil
    var preferredCommuteEndTime: DateComponents? = nil
    // ... existing code ...
    enum EcoPreference: String, Codable, CaseIterable, Equatable {
        case preferCarpooling = "I prefer carpooling"
        case prioritizeBiking = "I prioritize biking"
        case preferPublicTransport = "I prefer public transport"
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.preferredCommuteMethod == rhs.preferredCommuteMethod &&
        lhs.ecoPreferences == rhs.ecoPreferences &&
        lhs.totalGreenKilometers == rhs.totalGreenKilometers &&
        lhs.totalCO2Saved == rhs.totalCO2Saved &&
        lhs.preferredCommuteStartTime == rhs.preferredCommuteStartTime &&
        lhs.preferredCommuteEndTime == rhs.preferredCommuteEndTime
    }
}
