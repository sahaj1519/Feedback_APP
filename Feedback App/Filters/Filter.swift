//
//  Filter.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import Foundation

/// A model representing a filter used to categorize issues.
///
/// Filters can be used to segment issues based on certain criteria such as recency or tags.
struct Filter: Identifiable, Hashable {
    
    /// A unique identifier for the filter.
    var id: UUID
    
    /// The name of the filter.
    var name: String
    
    /// The system icon name representing the filter.
    var icon: String
    
    /// The minimum modification date for issues to be included in this filter.
    /// Defaults to `.distantPast`, meaning no restriction on date.
    var minModificationDate = Date.distantPast
    
    /// The associated tag used to filter issues.
    var tag: Tag?
    
    /// The count of active issues related to the filter's tag.
    var activeIssueCount: Int {
        tag?.tagIssue.count ?? 0
    }
    
    /// A predefined filter representing all issues.
    static var all = Filter(
        id: UUID(),
        name: "All Issues",
        icon: "tray"
    )
    
    /// A predefined filter for recently modified issues (within the last 7 days).
    static var recent = Filter(
        id: UUID(),
        name: "Recent Issues",
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(86400 * -7)
    )
    
    /// Hashes the filter using its unique identifier.
    /// - Parameter hasher: The hasher to use for hashing the identifier.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
     
    /// Compares two `Filter` instances for equality.
    /// - Parameters:
    ///   - lhs: The left-hand side `Filter` instance.
    ///   - rhs: The right-hand side `Filter` instance.
    /// - Returns: `true` if both filters have the same identifier, otherwise `false`.
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
