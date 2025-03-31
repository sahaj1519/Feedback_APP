//
//  Tag-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

/// Extension to provide computed properties and utility functions for the `Tag` entity in Core Data.
extension Tag {
    
    /// Returns the unique identifier (`UUID`) of the tag.
    /// If `id` is nil, it generates a new `UUID`.
    var tagId: UUID {
        id ?? UUID()
    }
    
    /// Returns the name of the tag.
    /// If `name` is nil, it returns an empty string.
    var tagName: String {
        name ?? ""
    }
    
    /// Returns an array of incomplete issues associated with this tag.
    /// Filters out completed issues.
    var tagIssue: [Issue] {
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { !$0.isCompleted }
    }
    
    /// Creates an example `Tag` instance for SwiftUI previews and testing.
    /// - Returns: A sample `Tag` object stored in an in-memory Core Data context.
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = "Example Tag"
        return tag
    }
}

/// Extension to make `Tag` conform to `Comparable`, enabling sorting.
extension Tag: Comparable {
    
    /// Compares two tags for sorting.
    /// - Tags are sorted alphabetically (case-insensitive).
    /// - If two tags have the same name, they are sorted by their `UUID` to ensure a stable order.
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
