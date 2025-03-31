//
//  PerformanceTests.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import CoreData
import XCTest
@testable import Feedback_App

/// Performance test cases for measuring the efficiency of award calculations.
class PerformanceTests: BaseTestCase {
    
    /// Tests the performance of the `hasEarned` function when checking multiple awards.
    ///
    /// - This test creates a large amount of sample data (100 iterations).
    /// - It then checks if award calculations remain performant.
    /// - The measure block evaluates how long it takes to filter earned awards.
    func test_awardCalculation_performance() {
        // GIVEN: A dataset with 100 sample data sets
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // WHEN: Creating a collection of awards (25 repetitions)
        let awards = Array(repeating: Award.allAward, count: 25).joined()

        // THEN: Ensure the expected count remains consistent
        XCTAssertEqual(awards.count, 500, "This verifies the award count is constant. Update if new awards are added.")

        // Measure performance of filtering earned awards
        measure {
            _ = awards.filter(dataController.hasEarned).count
        }
    }
}
