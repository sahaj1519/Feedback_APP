//
//  Tag-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

/// **Core Data Helper Extension for `Tag`**
///
/// This extension provides computed properties and utility functions for the `Tag` Core Data entity.
/// The methods in this extension allow you to easily retrieve and update the tag's identifier, name, associated issues,
/// and other properties related to tags. This also includes an example `Tag` instance for use in SwiftUI previews
/// and a sorting function to compare and order tags.
///
/// - SeeAlso: `Tag`, `Issue`
extension Tag {
    
    /// **Tag Identifier**
    ///
    /// Retrieves the unique identifier of the tag. If `id` is nil, a new `UUID` is generated and returned.
    ///
    /// - Returns: The tag's unique identifier (`UUID`).
    var tagId: UUID {
        id ?? UUID()
    }
    
    /// **Tag Name**
    ///
    /// Retrieves or sets the name of the tag. If `name` is nil, it defaults to an empty string.
    ///
    /// - Returns: The tag's name as a `String`.
    var tagName: String {
        name ?? ""
    }
    
    /// **Incomplete Issues Associated with the Tag**
    ///
    /// Retrieves an array of issues associated with this tag, excluding completed issues.
    ///
    /// - Returns: An array of `Issue` objects that are incomplete and associated with this tag.
    var tagIssue: [Issue] {
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { !$0.isCompleted }
    }
    
    /// **Example `Tag` instance for SwiftUI previews**
    ///
    /// This method creates a sample `Tag` object that is stored in an in-memory Core Data context.
    ///
    /// - Returns: A sample `Tag` object for use in previews and testing.
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = "Example Tag"
        return tag
    }
}

/// **Sorting Support for `Tag`**
///
/// This extension makes `Tag` conform to `Comparable`, allowing tags to be compared and sorted using Swift's `<` operator.
extension Tag: Comparable {
    
    /// **Sorting Logic for `Tag` Objects**
    ///
    /// Tags are sorted alphabetically by their name (case-insensitive). If two tags have the same name,
    /// they are sorted by their unique identifier (`UUID`) to ensure a stable order.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `Tag` object to compare.
    ///   - rhs: The right-hand side `Tag` object to compare.
    /// - Returns: A Boolean value indicating whether the left tag should be ordered before the right tag.
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        
        if left == right {
            return lhs.tagId.uuidString < rhs.tagId.uuidString
        } else {
            return left < right
        }
    }
}
