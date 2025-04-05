//
//  ContentViewRowsViewModel.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 01/04/25.
//

import CoreData
import Foundation

/// An extension of `ContentViewRows` containing its ViewModel.
///
/// The `ViewModel` provides issue-related computed properties and accessibility support,
/// ensuring a dynamic and user-friendly UI experience.
extension ContentViewRows {
    
    /// A `ViewModel` for `ContentViewRows`, responsible for handling issue-related data and UI interactions.
    ///
    /// - Features:
    ///   - **Read-only computed properties**
    ///   for issue details such as
    ///   **priority, creation date, and accessibility labels**.
    ///   - **Accessibility support** for screen readers to enhance usability.
    ///   - **Priority-based UI adjustments** to visually distinguish high-priority issues.
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        
        /// The issue associated with this `ViewModel`.
        ///
        /// - Used to extract details such as **priority, title, and creation date**.
        let issue: Issue
        
        /// Initializes the `ViewModel` with a given issue.
        ///
        /// - Parameter issue: The `Issue` object representing a single issue instance.
        init(issue: Issue) {
            self.issue = issue
        }
        
        /// Provides direct access to `Issue` properties using **key paths**.
        ///
        /// This enables convenient property forwarding from `Issue` to `ViewModel`.
        ///
        /// - Parameter keyPath: A `KeyPath` to a property in `Issue`.
        /// - Returns: The corresponding property value from `Issue`.
        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
        
        /// Determines the opacity of the priority icon based on issue priority.
        ///
        /// - Returns:
        ///   - `1.0` if the issue has a **high priority** (`priority == 2`).
        ///   - `0.0` otherwise (icon remains hidden).
        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }
        
        /// Generates a unique accessibility identifier for high-priority issues.
        ///
        /// - Returns:
        ///   - A string in the format: `"<Issue Title> High Priority"` if the issue is high priority.
        ///   - An **empty string** if the issue is not high priority.
        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
        }
        
        /// Provides an accessibility hint describing the issue's priority level.
        ///
        /// - Returns:
        ///   - `"High priority"` if the issue has a **priority of 2**.
        ///   - An **empty string** otherwise.
        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }
        
        /// Formats the issue’s creation date for accessibility purposes.
        ///
        /// - Returns:
        ///   - A **human-readable date format**: `"Mar 31, 2025"`.
        var accessibilityCreationDate: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }
        
        /// Converts the issue's creation date into a **short numeric format**.
        ///
        /// - Returns:
        ///   - A date string in the format: `"3/31/25"`.
        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }
    }
}
