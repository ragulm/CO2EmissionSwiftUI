import SwiftUI
import Charts

struct SustainabilityTrackerView: View {
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingAchievements = false
    
    enum TimeFrame: String, CaseIterable {
        case day = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Eco-Friendly Stats")) {
                    StatRow(title: "Total Green Kilometers",
                           value: "12.5 km",
                           icon: "leaf.fill",
                           color: .green)
                    
                    StatRow(title: "CO₂ Saved",
                           value: "2.8 kg",
                           icon: "cloud.fill",
                           color: .blue)
                    
                    StatRow(title: "Eco-Friendly Trips",
                           value: "8",
                           icon: "figure.walk",
                           color: .orange)
                }
                
                Section(header: Text("Commute Distribution")) {
                    Chart {
                        ForEach(mockCommuteData) { data in
                            BarMark(
                                x: .value("Method", data.method.rawValue),
                                y: .value("Distance", data.distance)
                            )
                            .foregroundStyle(by: .value("Method", data.method.rawValue))
                        }
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                }
                
                Section(header: Text("Achievements")) {
                    ForEach(mockAchievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
            .navigationTitle("Sustainability")
            .toolbar {
                Button {
                    showingAchievements = true
                } label: {
                    Image(systemName: "trophy.fill")
                }
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isUnlocked: Bool
    let icon: String
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(mockAchievements) { achievement in
                AchievementRow(achievement: achievement)
            }
            .navigationTitle("Achievements")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// Mock data
struct CommuteData: Identifiable {
    let id = UUID()
    let method: CommuteMethod
    let distance: Double
}

let mockCommuteData: [CommuteData] = [
    CommuteData(method: .walking, distance: 5.2),
    CommuteData(method: .cycling, distance: 8.7),
    CommuteData(method: .publicTransport, distance: 12.3),
    CommuteData(method: .carpooling, distance: 3.1)
]

let mockAchievements: [Achievement] = [
    Achievement(
        title: "Green Commuter",
        description: "Complete 10 eco-friendly trips",
        isUnlocked: true,
        icon: "leaf.fill"
    ),
    Achievement(
        title: "Weather Warrior",
        description: "Commute in different weather conditions",
        isUnlocked: false,
        icon: "cloud.sun.fill"
    ),
    Achievement(
        title: "CO₂ Champion",
        description: "Save 10kg of CO₂ emissions",
        isUnlocked: false,
        icon: "cloud.fill"
    )
]

#Preview {
    SustainabilityTrackerView()
} 