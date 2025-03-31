//
//  FeedbackAppUITests.swift
//  Feedback AppUITests
//
//  Created by Ajay Sangwan on 27/03/25.
//

import XCTest

final class FeedbackAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    // @MainActor
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }

    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists, "There should be a Filters button on launch.")
    }

    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 list rows initially.")
    }

    func testCreatingAndDeletingIssues() {
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

    
}
