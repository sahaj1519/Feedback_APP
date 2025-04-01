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
        get { title ?? "" }
        set { title = newValue }
    }
    
    /// **Content/description of the issue**
    ///
    /// Retrieves or sets the content/description of the issue.
    /// If `content` is `nil`, it defaults to an empty string.
    ///
    /// - Returns: The issue's content as a `String`.
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    /// **Issue creation date**
    ///
    /// Retrieves the date when the issue was created. If `creationDate` is `nil`, it defaults to the current date.
    ///
    /// - Returns: The issue's creation date as a `Date`.
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    
    /// **Issue last modification date**
    ///
    /// Retrieves the most recent modification date of the issue.
    /// Defaults to the current date if `modificationDate` is `nil`.
    ///
    /// - Returns: The issue's modification date as a `Date`.
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    /// **List of associated tags, sorted alphabetically**
    ///
    /// Retrieves the list of tags associated with this issue. The list is sorted alphabetically by tag name.
    ///
    /// - Returns: An array of `Tag` objects associated with the issue.
    var issueTag: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
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
        let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet")
        guard let tags else { return noTags }
        
        if tags.count == 0 {
            return noTags
        } else {
            return issueTag.map(\.tagName).formatted()
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
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
