//
//  TagTests.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import XCTest
import CoreData
@testable import Feedback_App

/// A test case class for verifying **Tag and Issue relationships** in Core Data.
///
/// This class ensures that tags and issues are correctly created, counted, and deleted
/// without affecting data integrity.
class TagTests: BaseTestCase {

    
    /// Tests that creating a specified number of **tags** and **issues** works correctly.
    ///
    /// - This test creates `count` tags.
    /// - Each tag contains `count` issues, resulting in `count * count` total issues.
    ///
    /// **Expected Behavior:**
    /// - The total number of tags in Core Data should match `count`.
    /// - The total number of issues in Core Data should match `count * count`.
    func testCreatingTagAndIssue() {
        /// The number of tags to create.
        let count = 10
        /// The total number of issues expected (count * count).
        let issueCount = count * count
        
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)
            
            for _ in 0..<count {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }
        
        XCTAssertEqual(
            dataController.count(for: Tag.fetchRequest()),
            count,
            "Expected \(count) tags."
        )
        
        XCTAssertEqual(
            dataController.count(for: Issue.fetchRequest()),
            issueCount,
            "Expected \(issueCount) issues."
        )
    }
    
    /// Tests that **deleting a tag does not delete its associated issues**.
    ///
    /// - Calls `createSampleData()` to prepopulate the Core Data stack with **5 tags and 50 issues**.
    /// - Deletes one tag and verifies that the remaining data is **4 tags and 50 issues**.
    ///
    /// **Expected Behavior:**
    /// - After deleting **one tag**, the total number of tags should be **4**.
    /// - The number of issues should remain **50**.
    ///
    /// - Throws: An error if fetching tags fails.
    func testDeletingTagDoesNotDeleteIssues() throws {
        /// Populate Core Data with **5 tags and 50 issues**.
        dataController.createSampleData()
        
        /// Fetch all tags from Core Data.
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)

        /// Delete the first tag.
        dataController.deleteObject(object: tags[0])
        
        XCTAssertEqual(
            dataController.count(for: Tag.fetchRequest()),
            4,
            "Expected 4 tags after deleting 1."
        )
        
        XCTAssertEqual(
            dataController.count(for: Issue.fetchRequest()),
            50,
            "Expected 50 issues after deleting a tag."
        )
    }
}
