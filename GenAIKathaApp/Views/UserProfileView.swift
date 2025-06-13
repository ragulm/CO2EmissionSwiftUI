import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: CommuteViewModel
    @State private var name = ""
    @State private var selectedCommuteMethod = CommutePreference.walking
    @State private var selectedEcoPreferences: Set<User.EcoPreference> = []
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var preferredStartTime = DateComponents(hour: 8, minute: 0)
    @State private var preferredEndTime = DateComponents(hour: 9, minute: 0)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Commute Preferences")) {
                    Picker("Preferred Commute Method", selection: $selectedCommuteMethod) {
                        ForEach(CommutePreference.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
                
                Section(header: Text("Preferred Commute Time Range")) {
                    HStack {
                        DatePicker("Start", selection: Binding(
                            get: { dateFromComponents(preferredStartTime) },
                            set: { preferredStartTime = componentsFromDate($0) }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        Text("to")
                        DatePicker("End", selection: Binding(
                            get: { dateFromComponents(preferredEndTime) },
                            set: { preferredEndTime = componentsFromDate($0) }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                    if let start = formattedTime(preferredStartTime), let end = formattedTime(preferredEndTime) {
                        Text("Preferred time: \(start) - \(end)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Eco-Friendly Preferences")) {
                    ForEach(User.EcoPreference.allCases, id: \.self) { preference in
                        Toggle(preference.rawValue, isOn: Binding(
                            get: { selectedEcoPreferences.contains(preference) },
                            set: { isSelected in
                                if isSelected {
                                    selectedEcoPreferences.insert(preference)
                                } else {
                                    selectedEcoPreferences.remove(preference)
                                }
                            }
                        ))
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Profile Setup")
            .onAppear {
                if let user = viewModel.currentUser {
                    name = user.name
                    selectedCommuteMethod = user.preferredCommuteMethod
                    selectedEcoPreferences = Set(user.ecoPreferences)
                    if let start = user.preferredCommuteStartTime {
                        preferredStartTime = start
                    }
                    if let end = user.preferredCommuteEndTime {
                        preferredEndTime = end
                    }
                }
            }
            .alert("Profile Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been saved successfully!")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveProfile() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your name"
            showingErrorAlert = true
            return
        }
        
        viewModel.createUserProfile(
            name: name,
            preferredCommuteMethod: selectedCommuteMethod,
            ecoPreferences: Array(selectedEcoPreferences)
        )
        // Save preferred time range
        if var user = viewModel.currentUser {
            user.preferredCommuteStartTime = preferredStartTime
            user.preferredCommuteEndTime = preferredEndTime
            viewModel.currentUser = user
        }
        showingSaveAlert = true
        scheduleTestNotification()
    }
    
    private func dateFromComponents(_ components: DateComponents) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
    private func componentsFromDate(_ date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.hour, .minute], from: date)
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
    
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test: Green Commute Reminder"
        content.body = "This is a test notification to confirm your settings."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_commute_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

#Preview {
    UserProfileView().environmentObject(CommuteViewModel())
}
