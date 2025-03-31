//
//  DetailViewWithIssue.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import CoreData
import SwiftUI

/// A detailed view for displaying and editing an issue's information.
struct DetailViewWithIssue: View {
    
    /// The shared data controller responsible for managing app data.
    @EnvironmentObject var dataController: DataController
    
    /// The issue being displayed and edited.
    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            // Main issue details section
            Section {
                VStack(alignment: .leading) {
                    // Title text field for issue title input
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    // Display last modification date
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    // Display issue completion status
                    Text("**Status:** \(issue.issueIsCompleted)")
                        .foregroundStyle(.secondary)
                }
                
                // Priority selection
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                // Tag management
                TagMenuView(issue: issue)
            }
            
            // Issue description section
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    // Multi-line text field for issue description
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                }
            }
        }
        .disabled(issue.isDeleted) // Disable form if issue is deleted
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave() // Schedule a save when the issue changes
        }
        .onSubmit(dataController.saveChanges) // Save changes when form is submitted
        .toolbar {
            IssueViewToolbar(issue: issue) // Attach issue-specific toolbar actions
        }
    }
}

#Preview {
    DetailViewWithIssue(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
