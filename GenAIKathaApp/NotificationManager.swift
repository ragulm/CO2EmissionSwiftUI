import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() { super.init(); UNUserNotificationCenter.current().delegate = self }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleCommuteReminder(for user: User) {
        guard let startTime = user.preferredCommuteStartTime else { return }
        var dateComponents = DateComponents()
        // Subtract 5 minutes for the reminder
        let hour = startTime.hour ?? 8
        let minute = startTime.minute ?? 0
        let totalMinutes = hour * 60 + minute
        let reminderMinutes = max(totalMinutes - 5, 0)
        dateComponents.hour = reminderMinutes / 60
        dateComponents.minute = reminderMinutes % 60
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your green commute!"
        content.body = "Check for eco-friendly routes and make a positive impact today."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "commute_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["commute_reminder"])
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}
