import SwiftUI
import Charts

struct SustainabilityTrackerView: View {
    @EnvironmentObject var viewModel: CommuteViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            List {
                if let user = viewModel.currentUser {
                    Section(header: Text("Today's Impact")) {
                        VStack(spacing: 20) {
                            HStack {
                                ImpactCard(
                                    title: "Green Kilometers",
                                    value: String(format: "%.1f", user.totalGreenKilometers),
                                    icon: "leaf.fill",
                                    color: .green
                                )
                                
                                ImpactCard(
                                    title: "CO₂ Saved",
                                    value: String(format: "%.1f kg", user.totalCO2Saved / 1000),
                                    icon: "cloud.fill",
                                    color: .blue
                                )
                            }
                            
                            let ecoFriendlyPercentage = calculateEcoFriendlyPercentage(user)
                            Chart {
                                SectorMark(
                                    angle: .value("Eco-Friendly", ecoFriendlyPercentage),
                                    innerRadius: .ratio(0.618),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(.green)
                                
                                SectorMark(
                                    angle: .value("Other", 100 - ecoFriendlyPercentage),
                                    innerRadius: .ratio(0.618),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(.gray.opacity(0.3))
                            }
                            .frame(height: 200)
                            .padding()
                            
                            Text("\(Int(ecoFriendlyPercentage))% of your commute was eco-friendly today!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("Preferred Time Window Stats")) {
                        if let start = user.preferredCommuteStartTime, let end = user.preferredCommuteEndTime {
                            let count = preferredTimeCommuteCount(user: user)
                            let startStr = formattedTime(start) ?? "--"
                            let endStr = formattedTime(end) ?? "--"
                            Text("You completed \(count) commutes during your preferred window (\(startStr) - \(endStr)) this week.")
                                .font(.subheadline)
                        } else {
                            Text("Set your preferred commute time in your profile to see stats here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Recent Activity")) {
                        if !viewModel.completedRoutes.isEmpty {
                            ForEach(viewModel.completedRoutes.suffix(3)) { route in
                                CompletedRouteRowView(route: route)
                            }
                        } else {
                            Text("No completed routes yet")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Achievements")) {
                        AchievementRow(
                            title: "Green Commuter",
                            description: "Completed 5 eco-friendly commutes",
                            progress: min(user.totalGreenKilometers / 25.0, 1.0),
                            icon: "leaf.fill"
                        )
                        
                        AchievementRow(
                            title: "CO₂ Champion",
                            description: "Saved 1kg of CO₂ emissions",
                            progress: min(user.totalCO2Saved / 1000.0, 1.0),
                            icon: "cloud.fill"
                        )
                    }
                } else {
                    Section {
                        VStack(spacing: 16) {
                            Text("Complete your profile to start tracking your eco-friendly impact!")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: UserProfileView()) {
                                Text("Set Up Profile")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Sustainability Tracker")
            .refreshable {
                isRefreshing = true
                // Simulate refresh delay
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isRefreshing = false
            }
        }
    }
    
    private func calculateEcoFriendlyPercentage(_ user: User) -> Double {
        // Calculate based on actual user data
        let totalDistance = user.totalGreenKilometers
        let ecoFriendlyDistance = user.totalGreenKilometers // This would be more complex in a real app
        return totalDistance > 0 ? (ecoFriendlyDistance / totalDistance) * 100 : 0
    }
    
    private func preferredTimeCommuteCount(user: User) -> Int {
        guard let start = user.preferredCommuteStartTime, let end = user.preferredCommuteEndTime else { return 0 }
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return viewModel.completedRoutes.filter { route in
            guard let completedAt = route.completedAt else { return false }
            guard completedAt >= weekAgo else { return false }
            let components = calendar.dateComponents([.hour, .minute], from: completedAt)
            let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            let startMinutes = (start.hour ?? 0) * 60 + (start.minute ?? 0)
            let endMinutes = (end.hour ?? 0) * 60 + (end.minute ?? 0)
            return minutes >= startMinutes && minutes <= endMinutes
        }.count
    }
    
    private func formattedTime(_ components: DateComponents) -> String? {
        guard let hour = components.hour, let minute = components.minute else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        return nil
    }
}

struct ImpactCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementRow: View {
    let title: String
    let description: String
    let progress: Double
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ProgressView(value: progress)
                    .tint(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SustainabilityTrackerView()
}
