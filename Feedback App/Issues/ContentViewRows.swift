//
//  ContentViewRows.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import CoreData
import SwiftUI

/// A view representing a single row in the issue list, displaying issue details.
struct ContentViewRows: View {
    
    /// The shared data controller for managing Core Data operations.
    @EnvironmentObject var dataController: DataController
    
    /// The issue object being displayed.
    @ObservedObject var issue: Issue
    
    var body: some View {
        /// A navigation link that allows users to select an issue and view its details.
        NavigationLink(value: issue) {
            HStack {
                
                // High-priority indicator: Displays an exclamation mark
                // if the issue is of high priority (priority == 2).
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                
                VStack(alignment: .leading) {
                    // The issue title, limited to one line to maintain layout consistency.
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // Displays a list of tags associated with the issue, shown in secondary color.
                    Text(issue.issueTagList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer() // Pushes elements to the edges of the row.
                
                VStack(alignment: .trailing) {
                    // The issue creation date, formatted and accessible for screen readers.
                    Text(issue.issueFormattedCreationDate)
                        .accessibilityLabel(issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                    
                    // Displays "CLOSED" if the issue has been marked as completed.
                    if issue.isCompleted {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        // Adds an accessibility hint for high-priority issues.
        .accessibilityHint(issue.priority == 2 ? "High Priority" : "")
    }
}

#Preview {
    /// A preview of `ContentViewRows`, using a sample issue for testing.
    ContentViewRows(issue: .example)
}
