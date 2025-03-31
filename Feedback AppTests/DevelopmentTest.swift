//
//  DevelopmentTest.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import CoreData
import XCTest
@testable import Feedback_App

/// Unit tests for data-related functionality in the Feedback App.
class DevelopmentTest: BaseTestCase {
    
    override func tearDown() {
           super.tearDown()
           dataController.deleteAllData() // Clean up all test data
       }
    

    /// Tests whether sample data is created correctly.
    ///
    /// This method ensures that the `createSampleData()` function properly generates
    /// the expected number of `Tag` and `Issue` objects in Core Data.
    ///
    /// - Important: Assumes `createSampleData()` generates 5 tags and 50 issues.
    func testSampleDataCreationWorks() {
        dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 50 sample issues.")
    }

    /// Tests whether the `deleteAllData()` method properly clears all stored data.
    ///
    /// After calling `deleteAllData()`, the count of `Tag` and `Issue` objects
    /// should be reduced to zero.
    ///
    /// - Important: This test depends on `createSampleData()` being called first.
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAllData()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 issues.")
    }

    /// Ensures that the example `Tag` instance does not have any associated issues.
    ///
    /// - Precondition: `Tag.example` is expected to have an empty issues relationship.
    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }

    /// Ensures that the example `Issue` has a high priority.
    ///
    /// - Note: The expected priority level is `2` (high priority).
    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }
}
