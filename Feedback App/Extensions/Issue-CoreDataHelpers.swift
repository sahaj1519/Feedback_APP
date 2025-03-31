//
//  Issue-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

/// Extension to provide computed properties and helper functions for the `Issue` entity in Core Data.
extension Issue {
    
    /// The title of the issue. If `title` is `nil`, it returns an empty string.
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    /// The content/description of the issue. If `content` is `nil`, it returns an empty string.
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    /// The date when the issue was created.
    /// Defaults to the current date if `creationDate` is `nil`.
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    
    /// The last modification date of the issue.
    /// Defaults to the current date if `modificationDate` is `nil`.
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    /// A list of tags associated with this issue, sorted alphabetically.
    var issueTag: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    /// Returns the issue's status as a string.
    /// - `"Closed"` if the issue is completed.
    /// - `"Open"` if the issue is still active.
    var issueIsCompleted: String {
        isCompleted ? "Closed" : "Open"
    }
    
    /// Provides a formatted list of tags for display.
    /// - Returns: A string containing the names of all associated tags, or `"No tags"` if none exist.
    var issueTagList: String {
        guard let tags else { return "No tags" }
        
        if tags.count == 0 {
            return "No tags"
        } else {
            return issueTag.map(\.tagName).formatted()
        }
    }
    
    /// Formats the issue's creation date into a short numeric date format (e.g., `3/31/25`).
    var issueFormattedCreationDate: String {
        issueCreationDate.formatted(date: .numeric, time: .omitted)
    }
    
    /// Provides an example `Issue` instance for previews and testing.
    /// - Returns: A sample `Issue` object stored in an in-memory Core Data context.
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        let issue = Issue(context: context)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

/// Extension to make `Issue` conform to `Comparable`, enabling sorting.
extension Issue: Comparable {
    
    /// Compares two issues for sorting.
    /// - Issues are sorted alphabetically by title (case-insensitive).
    /// - If two issues have the same title, they are sorted by creation date.
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
