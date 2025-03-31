//
//  AwardTest.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 31/03/25.
//

import CoreData
import XCTest
@testable import Feedback_App

/// A test case class for verifying **awards and their unlocking criteria**.
///
/// This class ensures that:
/// - Award IDs correctly match their names.
/// - New users do not start with any awards.
/// - Completing issues unlocks awards correctly.
class AwardTest: BaseTestCase {
    
    /// A list of all available awards loaded from JSON.
    let awards = Award.allAward
    

    /// Tests that each **award's ID correctly matches its name**.
    ///
    /// **Expected Behavior:**
    /// - Each award should have an **ID identical to its name**.
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(
                award.id,
                award.name,
                "Award ID should always match its name."
            )
        }
    }
    
    /// Tests that **new users start with no earned awards**.
    ///
    /// **Expected Behavior:**
    /// - A freshly created user should have **zero unlocked awards**.
    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(
                dataController.hasEarned(award: award),
                "New users should have no earned awards."
            )
        }
    }
    
    /// Tests that **completing a specific number of issues unlocks the correct number of awards**.
    ///
    /// **How it Works:**
    /// - Creates a list of issue completion milestones: `[1, 10, 20, 50, 100, 250, 500, 1000]`.
    /// - For each milestone:
    ///   1. Creates the corresponding number of **completed** issues.
    ///   2. Filters awards to check how many are earned (`award.criterion == "closed"`).
    ///   3. Ensures the correct number of awards is unlocked.
    ///   4. Deletes the created issues to clean up.
    ///
    /// **Expected Behavior:**
    /// - Completing **1, 10, 20, 50, 100, 250, 500, 1000**
    ///  issues should unlock **1, 2, 3, ..., 8 awards**, respectively.
    func testClosedAwards() {
        /// A list of issue completion milestones.
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            // Create `value` number of completed issues
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.isCompleted = true
                issues.append(issue)
            }

            // Check how many awards have been unlocked
            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(
                matches.count,
                count + 1,
                "Completing \(value) issues should unlock \(count + 1) awards."
            )

            // Clean up: Delete all created issues
            for issue in issues {
                dataController.deleteObject(object: issue)
            }
        }
    }
}
