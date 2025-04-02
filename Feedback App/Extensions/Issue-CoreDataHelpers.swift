//
//  Issue-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

/// **Core Data Helper Extension for `Issue`**
///
/// This extension provides computed properties and helper methods to make working with
/// the `Issue` Core Data entity more convenient. It includes properties to access and modify issue
/// details like the title, content, creation date, modification date, tags, and completion status.
/// It also provides sorting support for issues and an example instance for testing purposes.
///
/// - SeeAlso: `Issue`, `Tag`
extension Issue {
    
    /// **Title of the issue**
    ///
    /// Retrieves or sets the title of the issue.
    /// If `title` is `nil`, it defaults to an empty string.
    ///
    /// - Returns: The issue's title as a `String`.
    var issueTitle: String {
        get {
            // Return title if available, otherwise return an empty string
            title ?? ""
        }
        set {
            // Update the issue's title with the new value
            title = newValue
        }
    }
    
    /// **Content/description of the issue**
    ///
    /// Retrieves or sets the content/description of the issue.
    /// If `content` is `nil`, it defaults to an empty string.
    ///
    /// - Returns: The issue's content as a `String`.
    var issueContent: String {
        get {
            // Return content if available, otherwise return an empty string
            content ?? ""
        }
        set {
            // Update the issue's content with the new value
            content = newValue
        }
    }
    
    /// **Issue creation date**
    ///
    /// Retrieves the date when the issue was created. If `creationDate` is `nil`, it defaults to the current date.
    ///
    /// - Returns: The issue's creation date as a `Date`.
    var issueCreationDate: Date {
        // Return creation date if available; otherwise, use current date
        creationDate ?? .now
    }
    
    /// **Issue last modification date**
    ///
    /// Retrieves the most recent modification date of the issue.
    /// Defaults to the current date if `modificationDate` is `nil`.
    ///
    /// - Returns: The issue's modification date as a `Date`.
    var issueModificationDate: Date {
        // Return modification date if available; otherwise, use current date
        modificationDate ?? .now
    }
    
    /// **List of associated tags, sorted alphabetically**
    ///
    /// Retrieves the list of tags associated with this issue. The list is sorted alphabetically by tag name.
    ///
    /// - Returns: An array of `Tag` objects associated with the issue.
    var issueTag: [Tag] {
        // Convert the tags NSSet to an array of Tag objects, defaulting to an empty array if nil
        let result = tags?.allObjects as? [Tag] ?? []
        // Return the sorted array of tags
        return result.sorted()
    }
    
    /// **Issue completion status**
    ///
    /// Retrieves the completion status of the issue.
    /// Returns `"Closed"` if the issue is completed, otherwise `"Open"`.
    /// Uses localized strings for internationalization support.
    ///
    /// - Returns: A `String` indicating the issue's status (either `"Closed"` or `"Open"`).
    var issueIsCompleted: String {
        // Use a ternary operator to return a localized string based on the isCompleted flag
        isCompleted
        ? NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        : NSLocalizedString("Open", comment: "This issue is currently unresolved.")
    }
    
    /// **Formatted list of associated tags**
    ///
    /// Retrieves a formatted list of tags associated with the issue.
    /// If no tags exist, it returns the localized string `"No tags"`.
    ///
    /// - Returns: A string containing the names of all associated tags or `"No tags"` if no tags exist.
    var issueTagList: String {
        // Define the default string for when there are no tags
        let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet")
        // Use optional binding to safely unwrap tags
        guard let tags else { return noTags }
        
        // If there are no tags, return the default string; otherwise, format and return the list of tag names
        if tags.count == 0 {
            return noTags
        } else {
            return issueTag.map(\.tagName).formatted()
        }
    }
    
    /// **Issue reminder time**
    ///
    /// Retrieves or sets the reminder time for the issue.
    /// Defaults to the current date if `reminderTime` is `nil`.
    var issueReminderTime: Date {
        get {
            // Return the reminder time if available; otherwise, use current date
            reminderTime ?? .now
        }
        set {
            // Update the reminder time with the new value
            reminderTime = newValue
        }
    }
    
    /// **Example `Issue` instance for previews and testing**
    ///
    /// Returns an example instance of `Issue` for use in SwiftUI previews and testing.
    /// This instance is created in an in-memory Core Data context with sample values for title, content,
    /// and creation date.
    ///
    /// - Returns: A sample `Issue` object.
    static var example: Issue {
        // Create a DataController with an in-memory store for testing
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create a new Issue instance and populate it with sample data
        let issue = Issue(context: context)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

/// **Sorting support for `Issue`**
///
/// This extension provides sorting support for `Issue` objects using the `<` operator.
/// Issues are sorted alphabetically by title (case-insensitive), and if two issues have the same title,
/// they are further sorted by creation date.
///
/// - SeeAlso: `Comparable`
extension Issue: Comparable {
    
    /// **Sorting logic for `Issue` objects**
    ///
    /// Compares two `Issue` objects to determine their relative order.
    /// Issues are first compared by their title (case-insensitive), and if the titles are the same,
    /// they are sorted by creation date.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `Issue` object to compare.
    ///   - rhs: The right-hand side `Issue` object to compare.
    ///
    /// - Returns: A Boolean value indicating whether the left-hand side `Issue` should be ordered before the right-hand side.
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        // Convert both titles to lowercase for case-insensitive comparison
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        // If the titles are identical, compare by creation date
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            // Otherwise, sort alphabetically by title
            return left < right
        }
    }
}
