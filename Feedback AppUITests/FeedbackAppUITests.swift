//
//  FeedbackAppUITests.swift
//  Feedback AppUITests
//
//  Created by Ajay Sangwan on 27/03/25.
//

import XCTest

/// An extension of `XCUIElement` that provides a helper function to clear text fields.
extension XCUIElement {
    
    /// Clears the text inside an `XCUIElement` (e.g., a text field).
    ///
    /// This function first checks if the element has a string value. If it does,
    /// it deletes the text by simulating a series of backspace key presses.
    ///
    /// - Warning: This function only works for elements with string values (e.g., text fields).
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear text in XCUIElement")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

/// UI test cases for the `Feedback App`.
///
/// This class contains a suite of UI tests that verify the basic functionality of the app,
/// including navigation bar presence, button availability, issue creation, deletion, and
/// interaction with UI elements.
final class FeedbackAppUITests: XCTestCase {

    /// The application instance used for UI testing.
    var app: XCUIApplication!

    /// Sets up the testing environment before each test case runs.
    ///
    /// - Throws: An error if setup fails.
    ///
    /// This function:
    /// - Prevents the test suite from continuing after a failure.
    /// - Initializes the `XCUIApplication` instance.
    /// - Launches the app with testing-specific arguments.
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    /// Tests if the app launches and contains a navigation bar.
    func test_launchApp_navigationBarExists() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }

    /// Tests if essential buttons exist when the app starts.
    func test_launchApp_buttonsExist() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filter button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists, "There should be a New Issue button on launch.")
    }

    /// Tests if the issue list starts empty.
    func test_launchApp_issueListIsEmpty() {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 list rows initially.")
    }

    /// Tests if creating and deleting issues updates the list count correctly.
    func test_createAndDeleteIssues_listUpdatesCorrectly() {
        for tapCount in 1...5 {
            app.buttons["New Issue"].tap()
            app.buttons["Issues"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }

        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
    }

    /// Tests if editing an issue title correctly updates it in the list.
    func test_editIssueTitle_titleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no rows initially.")

        app.buttons["New Issue"].tap()

        app.textFields["Enter the issue title here"].tap()
        app.textFields["Enter the issue title here"].clear()
        app.typeText("My New Issue")

        app.buttons["Issues"].tap()
        XCTAssertTrue(app.buttons["My New Issue"].exists, "A My New Issue cell should now exist.")
    }

    /// Tests if setting an issue to "High Priority" displays the priority icon.
    func test_editIssuePriority_priorityIconAppears() {
        app.buttons["New Issue"].tap()
        app.buttons["Priority, Medium"].tap()
        app.buttons["High"].tap()
        app.buttons["Issues"].tap()

        let identifier = "New issue High Priority"
        XCTAssert(app.images[identifier].exists, "A high-priority issue needs an icon next to it.")
    }

    /// Tests if tapping all awards displays a "Locked" alert.
    func test_viewAllAwards_lockedAlertsAppear() {
        app.buttons["Filters"].tap()
        app.buttons["Show Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }
}
