//
//  AssetTest.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import XCTest
@testable import Feedback_App

/// A test case class for verifying that app assets,
/// such as colors and awards, are correctly loaded.
class AssetTest: XCTestCase {

    /// Tests that all predefined colors exist in the Asset Catalog.
    ///
    /// This test ensures that the colors used in the app are correctly defined
    /// and accessible from the Asset Catalog. If any color is missing or
    /// misnamed, this test will fail.
    ///
    /// - Fails if any color in the `allColors` array cannot be loaded using `UIColor(named:)`.
    func testAllColors() {
        /// A list of color names expected to be present in the Asset Catalog.
        let allColors = [
            "Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
            "Light Blue", "Midnight", "Orange", "Pink", "Purple",
            "Red", "Teal"
        ]
        
        for color in allColors {
            XCTAssertNotNil(
                UIColor(named: color),
                "Failed to load color '\(color)' from asset catalog."
            )
        }
    }
    
    /// Tests that award data is loaded correctly from the JSON file.
    ///
    /// This test ensures that the `Award.allAward` array is not empty, meaning
    /// that the app was able to load the awards correctly from the JSON file.
    ///
    /// - Fails if `Award.allAward` is empty, which indicates a problem with
    ///   loading or parsing the JSON data.
    func testAwardLoadCorrectly() {
        XCTAssertTrue(
            Award.allAward.isEmpty == false,
            "Failed to load awards from JSON."
        )
    }
}
