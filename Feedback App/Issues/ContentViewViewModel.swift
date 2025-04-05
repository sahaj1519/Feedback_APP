//
//  ContentViewViewModel.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 01/04/25.
//

import CoreData
import Foundation

/// An extension of `ContentView` containing its ViewModel.
///
/// The `ViewModel` is responsible for managing data interactions with Core Data,
/// including issue retrieval and deletion.
extension ContentView {
    
    /// A `ViewModel` class for `ContentView`, designed to manage Core Data interactions
    /// and provide issue management functionalities.
    ///
    /// - Features:
    ///   - Provides access to the shared `DataController` for handling Core Data operations.
    ///   - Implements **dynamic member lookup** to access `DataController` properties.
    ///   - Supports **issue deletion** from the list.
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        
        /// The shared `DataController` instance used to interact with Core Data.
        var dataController: DataController
        
        /// Determines whether the app should request an App Store review.
        ///
        /// - The app prompts for a review once at least **five tags** exist in Core Data.
        /// - Returns `true` if the tag count is 5 or more; otherwise, `false`.
        var shouldRequestReview: Bool {
            if dataController.count(for: Tag.fetchRequest()) >= 5 {
                
                let reviewRequestCount = UserDefaults.standard.integer(forKey: "reviewRequestCount")
                UserDefaults.standard.set(reviewRequestCount + 1, forKey: "reviewRequestCount")
                
                if reviewRequestCount.isMultiple(of: 10) {
                    return true
                }
            }
            return false
            
        }
        
        /// Initializes the `ViewModel` with a given `DataController`.
        ///
        /// - Parameter dataController: The `DataController` instance responsible for Core Data operations.
        init(dataController: DataController) {
            self.dataController = dataController
        }
        
        /// Provides access to properties of `DataController` using key paths.
        ///
        /// This allows `ViewModel` to forward property accesses to `DataController`
        /// dynamically, simplifying the code by reducing explicit property forwarding.
        ///
        /// - Parameter keyPath: A `KeyPath` to a property in `DataController`.
        /// - Returns: The value of the property accessed from `DataController`.
        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }
        
        /// Provides read-write access to mutable properties of `DataController`.
        ///
        /// This enables direct modification of `DataController` properties through the `ViewModel`.
        ///
        /// - Parameter keyPath: A `ReferenceWritableKeyPath` to a modifiable property in `DataController`.
        /// - Returns: The value of the property, allowing both retrieval and modification.
        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get { dataController[keyPath: keyPath] }
            set { dataController[keyPath: keyPath] = newValue }
        }
        
        /// Deletes selected issues from the Core Data store.
        ///
        /// - Parameter offset: The `IndexSet` representing the indices of issues to delete.
        ///
        /// - Details:
        ///   - Retrieves the filtered list of issues using `dataController.issueForSelectedFilter()`.
        ///   - Iterates through the provided `IndexSet` and deletes each corresponding issue.
        ///   - Calls `dataController.deleteObject(object:)` to remove the issue.
        ///
        /// - Note: Changes made here are propagated to Core Data and will reflect in the UI.
        func deleteIssue(_ offset: IndexSet) {
            let issues = dataController.issueForSelectedFilter()
            for index in offset {
                let item = issues[index]
                dataController.deleteObject(object: item)
            }
        }
        
        
        func openURL(_ url: URL) {
            if url.absoluteString.contains("newIssue") {
                dataController.addNewIssue()
            } else if let issue = dataController.spotlightsearchissue(with: url.absoluteString) {
                dataController.selectedIssue = issue
                dataController.selectedFilter = .all
            }
        }
        
    }
}
