//
//  ExtensionTest.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import CoreData
import XCTest
@testable import Feedback_App

/// Unit tests for verifying data model extensions in the Feedback App.
class ExtensionTest: BaseTestCase {
    
    override func setUp() {
            super.setUp()
            // Ensuring a clean in-memory Core Data context before each test
            managedObjectContext.reset()
    }

    override func tearDown() {
            // Clean up Core Data objects after each test
            managedObjectContext.rollback()
            super.tearDown()
    }
    
    /// Tests if changing `title` updates `issueTitle` and vice versa.
    func test_issueTitle_updatesWithTitleChange() {
        // GIVEN: A new issue with a title
        let issue = Issue(context: managedObjectContext)
        issue.title = "Example issue"

        // WHEN: We read `issueTitle`
        // THEN: It should match the original title
        XCTAssertEqual(issue.issueTitle, "Example issue", "Setting `title` should update `issueTitle`.")

        // WHEN: We update `issueTitle`
        issue.issueTitle = "Updated issue"

        // THEN: `title` should also be updated
        XCTAssertEqual(issue.title, "Updated issue", "Setting `issueTitle` should update `title`.")
    }
    
    /// Tests if changing `content` updates `issueContent` and vice versa.
    func test_issueContent_updatesWithContentChange() {
        // GIVEN: A new issue with content
        let issue = Issue(context: managedObjectContext)
        issue.content = "Example content"

        // WHEN: We read `issueContent`
        // THEN: It should match the original content
        XCTAssertEqual(issue.issueContent, "Example content", "Setting `content` should update `issueContent`.")

        // WHEN: We update `issueContent`
        issue.issueContent = "Updated content"

        // THEN: `content` should also be updated
        XCTAssertEqual(issue.content, "Updated content", "Setting `issueContent` should update `content`.")
    }

    /// Tests if setting `creationDate` updates `issueCreationDate`.
    func test_issueCreationDate_matchesCreationDate() {
        // GIVEN: A new issue with a creation date
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now
        issue.creationDate = testDate

        // WHEN: We read `issueCreationDate`
        // THEN: It should match `creationDate`
        XCTAssertEqual(issue.issueCreationDate, testDate, "Setting `creationDate` should update `issueCreationDate`.")
    }
    
    /// Tests if an issue starts with no tags and updates when tags are added.
    func test_issueTags_updatesWhenTagAdded() {
        // GIVEN: A new issue and a new tag
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        // THEN: The issue should have no tags initially
        XCTAssertEqual(issue.issueTag.count, 0, "A new issue should have no tags.")

        // WHEN: A tag is added to the issue
        issue.addToTags(tag)

        // THEN: The issue should have one tag
        XCTAssertEqual(issue.issueTag.count, 1, "Adding a tag should update `issueTag` count.")
    }

    /// Tests if `issueTagList` correctly returns a formatted list of tag names.
    func test_issueTagList_showsCorrectTagNames() {
        // GIVEN: A tag with a name and an issue
        let tag = Tag(context: managedObjectContext)
        tag.name = "Bug"
        let issue = Issue(context: managedObjectContext)

        // WHEN: We add the tag to the issue
        issue.addToTags(tag)

        // THEN: The `issueTagList` should reflect the tag name
        XCTAssertEqual(issue.issueTagList, "Bug", "Adding a tag should update `issueTagList` correctly.")
    }
    
    /// Ensures issues are sorted first by title, then by creation date if titles match.
    func test_issueSorting_sortsByTitleThenDate() {
        // GIVEN: Three issues with different titles and creation dates
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        // WHEN: We sort the issues
        let sortedIssues = [issue1, issue2, issue3].sorted()

        // THEN: Issues should be sorted by title, then by creation date
        XCTAssertEqual(sortedIssues, [issue3, issue1, issue2], "Issues should be sorted by title, then creation date.")
    }
    
    /// Tests if setting `id` updates `tagId`.
    func test_tagId_matchesTagUUID() {
        // GIVEN: A new tag with a UUID
        let tag = Tag(context: managedObjectContext)
        tag.id = UUID()

        // WHEN: We read `tagId`
        // THEN: It should match `id`
        XCTAssertEqual(tag.tagId, tag.id, "Setting `id` should update `tagId`.")
    }

    /// Tests if setting `name` updates `tagName`.
    func test_tagName_updatesWithNameChange() {
        // GIVEN: A new tag with a name
        let tag = Tag(context: managedObjectContext)
        tag.name = "Example Tag"

        // WHEN: We read `tagName`
        // THEN: It should match `name`
        XCTAssertEqual(tag.tagName, "Example Tag", "Setting `name` should update `tagName`.")
    }
    
    /// Tests if a tag starts with zero active issues and updates when issues are linked or completed.
    func test_tagIssues_updatesWhenIssueAddedOrCompleted() {
        // GIVEN: A new tag and an issue
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        // THEN: The tag should have zero active issues initially
        XCTAssertEqual(tag.tagIssue.count, 0, "A new tag should have zero active issues.")

        // WHEN: The issue is linked to the tag
        tag.addToIssues(issue)

        // THEN: The tag should have one active issue
        XCTAssertEqual(tag.tagIssue.count, 1, "Tag should have one active issue after linking.")

        // WHEN: The issue is marked as completed
        issue.isCompleted = true

        // THEN: The tag should have zero active issues
        XCTAssertEqual(tag.tagIssue.count, 0, "A completed issue should be excluded from `tagIssue`.")
    }
    
    /// Ensures tags are sorted first by name, then by UUID string if names match.
    func test_tagSorting_sortsByNameThenUUID() {
        // GIVEN: Three tags with names and unique IDs
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-DC22-4463-8C69-7275D037C13D")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        // WHEN: We sort the tags
        let sortedTags = [tag1, tag2, tag3].sorted()

        // THEN: Tags should be sorted by name, then UUID
        XCTAssertEqual(sortedTags, [tag3, tag1, tag2], "Tags should be sorted by name, then UUID.")
    }
}
