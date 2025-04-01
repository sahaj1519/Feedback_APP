//
//  ContentViewRows.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import CoreData
import SwiftUI

/// A view representing a single row in the issue list, displaying issue details.
///
/// This row includes:
/// - An **icon indicator** for high-priority issues.
/// - The **issue title** and its **associated tags**.
/// - The **issue creation date** and completion status (`CLOSED` label).
struct ContentViewRows: View {
    
    /// The shared data controller that manages Core Data operations.
    @EnvironmentObject var dataController: DataController
    
    /// The ViewModel responsible for managing issue-related data.
    @StateObject private var viewModel: ViewModel
    
    /// Initializes the `ContentViewRows` with a specific issue.
    ///
    /// - Parameter issue: The `Issue` object representing a single issue.
    init(issue: Issue) {
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        /// A navigation link that allows users to select an issue and view its details.
        NavigationLink(value: viewModel.issue) {
            HStack {
                
                // Displays an exclamation mark if the issue has high priority (priority == 2).
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)

                VStack(alignment: .leading) {
                    // The issue title, limited to one line for layout consistency.
                    Text(viewModel.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // A secondary-colored text showing associated tags.
                    Text(viewModel.issueTagList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer() // Pushes elements to the edges of the row.
                
                VStack(alignment: .trailing) {
                    // Displays the issue's creation date in a formatted way.
                    Text(viewModel.creationDate)
                        .accessibilityLabel(viewModel.accessibilityCreationDate)
                        .font(.subheadline)
                    
                    // Displays "CLOSED" if the issue has been marked as completed.
                    if viewModel.isCompleted {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        // Adds an accessibility hint for screen readers about issue priority.
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityIdentifier(viewModel.issueTitle)
    }
}

#Preview {
    /// A preview of `ContentViewRows`, using a sample issue for testing.
    ContentViewRows(issue: .example)
}
