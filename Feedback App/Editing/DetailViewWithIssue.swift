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
/// - Features:
///   - Allows users to modify issue **title, description, priority, and tags**.
///   - Displays **modification date** and **completion status**.
///   - Provides a **responsive UI** that updates dynamically.
///   - Includes **toolbar actions** for issue-specific functionality.
struct DetailViewWithIssue: View {
    
    /// The shared data controller responsible for managing app data.
    ///
    /// - Used to **save** and **track changes** in Core Data.
    @EnvironmentObject var dataController: DataController
    
    /// The issue being displayed and edited.
    ///
    /// - The view observes changes to `issue` and updates accordingly.
    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            /// **Main issue details section**
            Section {
                VStack(alignment: .leading) {
                    /// **Title input field**
                    ///
                    /// - Users can edit the issue title.
                    /// - Uses a large title font for emphasis.
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    /// **Displays last modification date**
                    ///
                    /// - Uses a long date and short time format for clarity.
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    /// **Displays issue completion status**
                    ///
                    /// - Shows whether the issue is marked as completed.
                    Text("**Status:** \(issue.issueIsCompleted)")
                        .foregroundStyle(.secondary)
                }
                
                /// **Priority selection**
                ///
                /// - Allows users to choose a priority level:
                ///   - **Low (0)**
                ///   - **Medium (1)**
                ///   - **High (2)**
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                /// **Tag management view**
                ///
                /// - Displays a menu for adding and managing tags.
                TagMenuView(issue: issue)
            }
            
            /// **Issue description section**
            Section {
                VStack(alignment: .leading) {
                    /// **Basic Information header**
                    ///
                    /// - Styled as a section title with a secondary color.
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    /// **Multi-line description field**
                    ///
                    /// - Supports multi-line text input.
                    /// - Allows users to enter a detailed issue description.
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                }
            }
        }
        /// **Disables the form if the issue is deleted**
        .disabled(issue.isDeleted)
        
        /// **Auto-save on issue change**
        ///
        /// - Listens for changes and schedules a save operation.
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        
        /// **Saves changes when the form is submitted**
        .onSubmit(dataController.saveChanges)
        
        /// **Toolbar with issue-specific actions**
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
}

/// **Previews `DetailViewWithIssue` with example data**.
#Preview {
    DetailViewWithIssue(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
