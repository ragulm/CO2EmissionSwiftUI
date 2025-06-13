import SwiftUI

struct CompletedRouteRowView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: commuteMethodIcon)
                    .foregroundColor(.green)
                Text(route.commuteMethod.rawValue)
                    .font(.headline)
                Spacer()
                if let completedAt = route.completedAt {
                    Text(formatDate(completedAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text("\(route.startLocationName) → \(route.endLocationName)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text(String(format: "%.1f km", route.distance))
                Spacer()
                Text("Saved \(Int(route.co2Saved))g CO₂")
                    .foregroundColor(.green)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CompletedRouteRowView(route: Route(
        startLocation: .init(latitude: 0, longitude: 0),
        endLocation: .init(latitude: 0, longitude: 0),
        commuteMethod: .walking,
        distance: 5.0,
        duration: 1800,
        weatherCondition: .sunny,
        trafficCondition: .light,
        co2Saved: 100,
        isCompleted: true,
        completedAt: Date(),
        startLocationName: "Home",
        endLocationName: "Work"
    ))
} 
