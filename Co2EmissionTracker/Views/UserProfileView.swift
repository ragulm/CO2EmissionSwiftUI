import SwiftUI

struct UserProfileView: View {
    @State private var userProfile = UserProfile.default
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $userProfile.name)
                }
                
                Section(header: Text("Preferred Commute Method")) {
                    Picker("Commute Method", selection: $userProfile.preferredCommuteMethod) {
                        ForEach(CommuteMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
                
                Section(header: Text("Eco-Friendly Preferences")) {
                    Toggle("Prefer Carpooling", isOn: $userProfile.ecoPreferences.preferCarpooling)
                    Toggle("Prioritize Biking", isOn: $userProfile.ecoPreferences.prioritizeBiking)
                    Toggle("Avoid Highways", isOn: $userProfile.ecoPreferences.avoidHighways)
                    Toggle("Prefer Shaded Routes", isOn: $userProfile.ecoPreferences.preferShadedRoutes)
                }
                
                Section(header: Text("Sustainability Stats")) {
                    HStack {
                        Text("Total Green Kilometers")
                        Spacer()
                        Text(String(format: "%.1f km", userProfile.totalGreenKilometers))
                    }
                    HStack {
                        Text("Total CO2 Saved")
                        Spacer()
                        Text(String(format: "%.1f kg", userProfile.totalCO2Saved))
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                Button("Save") {
                    saveProfile()
                }
            }
            .alert("Profile Saved", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func saveProfile() {
        // TODO: Implement profile saving logic
        showingAlert = true
    }
}

#Preview {
    UserProfileView()
} 