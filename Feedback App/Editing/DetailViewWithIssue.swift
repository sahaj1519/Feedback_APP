//
//  DetailViewWithIssue.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import CoreData
import SwiftUI

/// A detailed view for displaying and editing an issue's information.
///
/// This view provides a comprehensive interface for users to view and modify an issue's details,
/// including the title, description, priority, and tags.
/// In addition, it displays metadata such as the last modification date and
/// completion status, and it includes reminder functionality.
/// Toolbar actions are provided to facilitate additional issue-specific operations.
struct DetailViewWithIssue: View {
    
    /// The shared data controller responsible for managing app data.
    ///
    /// This environment object is used to save and track changes in
    /// Core Data as well as to manage notification reminders.
    @EnvironmentObject var dataController: DataController
    
    /// The environment's URL opener.
    ///
    /// This property allows the view to open external URLs, such as the system's notification settings.
    @Environment(\.openURL) var openURL
    
    /// The issue being displayed and edited.
    ///
    /// This observed object represents the issue model. Changes to this object automatically update the UI.
    @ObservedObject var issue: Issue
    
    /// A state variable indicating whether the notification error alert should be displayed.
    ///
    /// This is used to show an alert when there is a problem setting the notification.
    @State private var isShowingNotificationError = false
    
    /// Opens the app's notification settings.
    ///
    /// This function constructs the URL for the system's notification settings
    /// and uses the environment's URL opener to navigate there.
    #if os(iOS)
    func showAppSetting() {
        guard let settingUrl = URL(
            string: UIApplication.openNotificationSettingsURLString
        ) else {
            return
        }
        openURL(settingUrl)
    }
    #endif
    
    /// Updates the reminder notification for the issue.
    ///
    /// This function first removes any existing reminders for the issue.
    /// If reminders are enabled, it then attempts to add a new reminder via the data controller.
    /// In case of a failure (e.g., due to missing permissions),
    /// the reminder is disabled and an error alert is triggered.
    func updateReminder() {
        dataController.removeReminders(for: issue)
        
        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)
                
                if success == false {
                    issue.reminderEnabled = false
                    isShowingNotificationError = true
                }
            }
        }
    }
    
    /// The view's body.
    ///
    /// This computed property defines the user interface of the view using a Form containing several sections:
    /// - The main issue details section displays the title, last modification date, and completion status.
    /// - A priority selection picker enables users to choose a priority level.
    /// - A tag management view for handling issue tags.
    /// - An issue description section with a multi-line text field for editing the issue description.
    /// - A reminders section with a toggle to enable/disable reminders and a date picker to set the reminder time.
    ///
    /// Additional functionality:
    /// - Disables the form if the issue is deleted.
    /// - Automatically saves changes as the issue updates.
    /// - Provides a toolbar with additional issue-specific actions.
    /// - Displays an alert if there is a problem setting up the notification.
    var body: some View {
        Form {
            /// **Main issue details section**
            Section {
                VStack(alignment: .leading) {
                    /// Title input field.
                    ///
                    /// Allows users to edit the issue title with a large title font for emphasis.
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                        .labelsHidden()
                    
                    /// Displays the last modification date.
                    ///
                    /// Formats the date using a long style for the date and a shortened style for the time.
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    /// Displays the issue completion status.
                    ///
                    /// Indicates whether the issue is marked as completed.
                    Text("**Status:** \(issue.issueIsCompleted)")
                        .foregroundStyle(.secondary)
                }
                
                /// Priority selection.
                ///
                /// Provides a picker to allow users to choose a priority level:
                /// - Low (0)
                /// - Medium (1)
                /// - High (2)
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                /// Tag management view.
                ///
                /// Displays a menu for adding and managing tags associated with the issue.
                TagMenuView(issue: issue)
            }
            
            /// **Issue description section**
            Section {
                VStack(alignment: .leading) {
                    /// Basic Information header.
                    ///
                    /// Provides a styled header for the description section.
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    /// Multi-line description field.
                    ///
                    /// Allows users to enter a detailed description of the issue using multi-line text input.
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                    .labelsHidden()
                }
            }
            
            /// **Reminders section**
            ///
            /// Contains controls for managing reminder notifications.
            /// A toggle is provided to enable or disable reminders, and
            /// if enabled, a date picker allows the user to select a reminder time.
            Section("Reminders") {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())
                
                if issue.reminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $issue.issueReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .formStyle(.grouped)
        /// Disables the form if the issue is deleted.
        .disabled(issue.isDeleted)
        
        /// Auto-save on issue change.
        ///
        /// Observes changes to the issue and schedules a save operation using the data controller.
        .onReceive(issue.objectWillChange) { _ in
            dataController.saveChanges()
        }
        
        /// Saves changes when the form is submitted.
        ///
        /// Triggers the saveChanges method from the data controller when the user submits the form.
        .onSubmit(dataController.saveChanges)
        
        /// Toolbar with issue-specific actions.
        ///
        /// Provides a toolbar that contains additional actions relevant to the issue.
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        /// Alert for notification errors.
        ///
        /// Displays an alert when there is a problem setting the notification.
        /// Provides options to check the notification settings or cancel.
        .alert("Oops!", isPresented: $isShowingNotificationError) {
          #if os(macOS)
            SettingsLink {
                Text("Check Settings")
            }
          #elseif os(iOS)
            Button("Check Settings", action: showAppSetting)
          #endif
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        /// Updates the reminder when the reminder toggle changes.
        .onChange(of: issue.reminderEnabled) {
            updateReminder()
        }
        /// Updates the reminder when the reminder time changes.
        .onChange(of: issue.reminderTime) {
            updateReminder()
        }
    }
}

/// Previews `DetailViewWithIssue` with example data.
///
/// This preview provides a live view of the `DetailViewWithIssue`
/// using a sample issue and an in-memory data controller for testing.
#Preview {
    DetailViewWithIssue(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
