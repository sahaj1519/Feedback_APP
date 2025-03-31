//
//  FeedbackAppTests.swift
//  Feedback AppTests
//
//  Created by Ajay Sangwan on 27/03/25.
//

import CoreData
import XCTest
@testable import Feedback_App

/// A base test case class that provides a **Core Data test environment** for unit tests.
///
/// This class initializes an **in-memory Core Data stack**, ensuring that tests do not
/// persist data between runs. Other test cases can inherit from `BaseTestCase` to
/// access the `dataController` and `managedObjectContext`.
class BaseTestCase: XCTestCase {
    
    /// A shared instance of `DataController` used for managing Core Data operations.
    ///
    /// - This instance is configured to use an **in-memory store** so that test data
    ///   does not persist after the test execution.
    var dataController: DataController!
    
    /// The Core Data **managed object context** used for interacting with test data.
    ///
    /// - This context is tied to the in-memory `NSPersistentContainer`, allowing
    ///   test cases to insert, update, and delete objects without affecting real data.
    var managedObjectContext: NSManagedObjectContext!

    /// Sets up the Core Data stack for testing.
    ///
    /// - This method is called before each test case execution.
    /// - It initializes the `dataController` using an **in-memory store**.
    /// - It also assigns the `managedObjectContext` to the view context of the persistent container.
    ///
    /// - Throws: An error if setup fails, though this is unlikely in an in-memory store.
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }

    /// Cleans up Core Data resources after each test case runs.
    ///
    /// - This method is called automatically after each test finishes.
    /// - It **destroys** the `dataController` and `managedObjectContext`, ensuring a fresh state for the next test.
    /// - Helps prevent **test data contamination** between test runs.
    override func tearDownWithError() throws {
        dataController = nil
        managedObjectContext = nil
    }
}
