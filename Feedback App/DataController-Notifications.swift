//
//  DataController-Notifications.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 02/04/25.
//

import UserNotifications
import Foundation

/// Extension of `DataController` to handle user notifications for reminders.
extension DataController {
    
    /// Adds a reminder notification for a given issue.
    ///
    /// This function checks the user's notification settings and, if allowed, schedules a reminder for the issue.
    ///
    /// - Parameter issue: The `Issue` for which the reminder needs to be set.
    /// - Returns: A `Bool` indicating whether the reminder was successfully scheduled.
    ///
    /// - Note:
    ///   - If notification permissions are not determined, the function will request authorization.
    ///   - If authorization is granted, the reminder will be placed.
    ///   - If notifications are denied or an error occurs, the function returns `false`.
    @discardableResult
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let centre = UNUserNotificationCenter.current()
            let settings = await centre.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()
                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }
            case .authorized:
                try await placeReminders(for: issue)
            default:
                return false
            }
            return true
            
        } catch {
            return false
        }
    }

    /// Removes any pending reminders for a specific issue.
    ///
    /// - Parameter issue: The `Issue` whose reminders need to be removed.
    ///
    /// - Note:
    ///   - This function removes any pending notification requests that match the issue's unique identifier.
    func removeReminders(for issue: Issue) {
        let centre = UNUserNotificationCenter.current()
        let id = issue.objectID.uriRepresentation().absoluteString
        centre.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Requests notification permission from the user.
    ///
    /// - Returns: A `Bool` indicating whether the user granted notification permissions.
    /// - Throws: An error if the authorization request fails.
    ///
    /// - Note:
    ///   - This function requests authorization for alert and sound notifications.
    ///   - If granted, the app can schedule reminders for issues.
    private func requestNotifications() async throws -> Bool {
        let centre = UNUserNotificationCenter.current()
        return try await centre.requestAuthorization(options: [.alert, .sound])
    }

    /// Schedules a reminder notification for the given issue.
    ///
    /// - Parameter issue: The `Issue` for which the reminder should be scheduled.
    /// - Throws: An error if the notification request fails.
    ///
    /// - Note:
    ///   - The notification will include the issue title and (if available) issue content.
    ///   - The notification is currently set to trigger after 5 seconds for testing.
    ///   - In production, the commented-out `UNCalendarNotificationTrigger` can be used to schedule reminders based on a specific time.
    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.title = issue.issueTitle
        content.sound = .default
        
        if let issueContent = issue.content {
            content.subtitle = issueContent
        }
        
//        let component = Calendar.current.dateComponents( [.hour, .minute], from: issue.issueReminderTime)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        
        // Use a time-based trigger for testing purposes.
       let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Generate a unique identifier for the notification based on the issue's object ID.
        let id = issue.objectID.uriRepresentation().absoluteString
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        return try await UNUserNotificationCenter.current().add(request)
    }
}
