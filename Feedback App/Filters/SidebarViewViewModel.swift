//
//  SidebarViewViewModel.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 01/04/25.
//

import CoreData
import Foundation

/// ViewModel for `SidebarView`, responsible for handling tag-related operations.
///
/// This ViewModel is an `ObservableObject` that interacts with Core Data to manage tags
/// and their associated UI operations, such as renaming and deleting.
///
/// - Important: This class uses `NSFetchedResultsController` to manage fetched results
///   efficiently and update the UI in response to Core Data changes.
extension SidebarView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        /// A reference to the `DataController` for managing Core Data operations.
        var dataController: DataController

        /// Fetch controller for retrieving `Tag` entities from Core Data.
        ///
        /// This controller fetches and monitors changes to the `Tag` objects in the
        /// managed object context.
        private let tagsController: NSFetchedResultsController<Tag>

        /// A published array of `Tag` objects representing the fetched tags.
        ///
        /// This array is updated when Core Data changes are detected.
        @Published var tags = [Tag]()

        /// The tag selected for renaming.
        ///
        /// When a tag is selected for renaming, it is stored here.
        @Published var tagToRename: Tag?

        /// Boolean flag to control the display of the rename alert.
        ///
        /// - `true`: The rename alert is visible.
        /// - `false`: The rename alert is hidden.
        @Published var isAlertForRenameTag = false

        /// Stores the new name entered by the user for renaming a tag.
        ///
        /// This value is bound to the rename alert text field.
        @Published var tagNewName = ""

        /// Computed property that converts fetched `Tag` objects into `Filter` instances.
        ///
        /// This transformation is used for displaying the tags in a filtered format in the UI.
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagId, name: tag.tagName, icon: "tag.fill", tag: tag)
            }
        }

        /// Initializes the ViewModel and sets up the fetched results controller.
        ///
        /// - Parameter dataController: The `DataController` instance managing Core Data operations.
        ///
        /// This initializer:
        /// 1. Configures a fetch request to retrieve `Tag` objects sorted alphabetically.
        /// 2. Sets up an `NSFetchedResultsController` to manage tag fetching and automatic updates.
        /// 3. Attempts to fetch the initial tag list and assigns it to the `tags` array.
        init(dataController: DataController) {
            self.dataController = dataController
            let request = Tag.fetchRequest()

            // Sorting tags alphabetically by name.
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
            
            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            
            // Setting delegate to respond to data changes.
            tagsController.delegate = self

            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
        }

        /// Handles Core Data changes and updates the `tags` array.
        ///
        /// This method is triggered when the fetched results controller detects changes in Core Data.
        /// - Parameter controller: The `NSFetchedResultsController` instance managing the fetch request.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
        }

        /// Deletes a tag based on its index in the list.
        ///
        /// - Parameter offset: The index set of the tag(s) to be deleted.
        ///
        /// This method removes the tag(s) from Core Data and updates the UI.
        func deleteTag(_ offset: IndexSet) {
            for index in offset {
                let item = tags[index]
                dataController.deleteObject(object: item)
            }
        }

        /// Deletes a tag using an alternative method.
        ///
        /// - Parameter filter: The `Filter` instance representing the tag to be deleted.
        ///
        /// This method fetches the `Tag` from the `Filter`, deletes it from Core Data, and saves changes.
        func deleteTagAnotherMethod(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataController.deleteObject(object: tag)
            dataController.saveChanges()
        }

        /// Prepares a tag for renaming.
        ///
        /// - Parameter filter: The `Filter` instance representing the tag to be renamed.
        ///
        /// This method:
        /// 1. Sets the selected `Tag` object to `tagToRename`.
        /// 2. Assigns its current name to `tagNewName`.
        /// 3. Triggers the rename alert by setting `isAlertForRenameTag` to `true`.
        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagNewName = filter.name
            isAlertForRenameTag = true
        }

        /// Saves the new name for the selected tag.
        ///
        /// This method updates the `name` property of the `Tag` object stored in `tagToRename`
        /// and saves changes to Core Data.
        func saveRenameTag() {
            tagToRename?.name = tagNewName
            dataController.saveChanges()
        }
    }
}
