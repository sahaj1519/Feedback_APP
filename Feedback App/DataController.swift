/// DataController is responsible for managing Core Data operations and CloudKit integration.
/// It handles data persistence, filtering, sorting, and deletion of issues and tags.
///
/// - Uses `NSPersistentCloudKitContainer` for CloudKit synchronization.
/// - Implements filtering and searching logic for issues.
/// - Provides methods to manage issues and tags.
/// - Supports batch deletion and remote store updates.

import CoreData
import SwiftUI

/// Enumeration representing sorting options for issues.
enum SortType: String {
    case dateCreated = "creationDate"  /// Sort by issue creation date.
    case dateModified = "modificationDate"  /// Sort by last modification date.
}

/// Enumeration representing the issue status filter.
enum Status {
    case all   /// Show all issues.
    case open  /// Show only open issues.
    case closed /// Show only closed issues.
}

/// `DataController` is an ObservableObject that manages Core Data operations.
class DataController: ObservableObject {
    /// Persistent container for Core Data with CloudKit support.
    let container: NSPersistentCloudKitContainer
    
    /// Currently selected filter for issues.
       @Published var selectedFilter: Filter? = Filter.all
       /// Currently selected issue.
       @Published var selectedIssue: Issue?
       
       /// Search text used to filter issues by title and content.
       @Published var searchText = ""
       /// List of tags used for token-based filtering.
       @Published var searchTokens = [Tag]()
       
       /// Indicates whether additional filters are enabled.
       @Published var filterEnabled = false
       /// Priority filter (-1 means no filtering by priority).
       @Published var filterPriority = -1
       /// Status filter (open, closed, or all).
       @Published var filterStatus = Status.all
       /// Sorting type (date created or date modified).
       @Published var sortType = SortType.dateCreated
       /// Sort order (true for newest first, false for oldest first).
       @Published var sortNewestFirst = true
       
       /// Background save task to optimize performance.
       private var saveTask: Task<Void, Error>?
       
       /// Preview instance for SwiftUI previews, preloaded with sample data.
       static var preview: DataController  = {
           let dataController = DataController(inMemory: true)
           dataController.createSampleData()
           return dataController
       }()
    
    /// Provides suggested tags based on the current search text.
        var suggestedSearchTokens: [Tag] {
            guard searchText.starts(with: "#") else { return [] }
            
            let trimmedSearchText = String(searchText.dropFirst()).trimmingCharacters(in: .whitespaces)
            let request = Tag.fetchRequest()
            
            if !trimmedSearchText.isEmpty {
                request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedSearchText)
            }
            
            return (try? container.viewContext.fetch(request).sorted()) ?? []
        }
    
        static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
        }()
    
    /// Initializes the Core Data stack.
        /// - Parameter inMemory: A flag to indicate if an in-memory store should be used (for previews/testing).
        init(inMemory: Bool = false) {
            container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: DataController.model)
            
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            container.persistentStoreDescriptions.first?.setOption(
                true as NSNumber,
                forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
            )
            
            NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: container.persistentStoreCoordinator,
                queue: .main,
                using: remoteStoreChanged
            )
            
            container.loadPersistentStores { _, error in
                if let error {
                    fatalError("Fatal error loading store: \(error.localizedDescription)")
                }
                
                #if DEBUG
                 if CommandLine.arguments.contains("enable-testing") {
                     self.deleteAllData()
                     UIView.setAnimationsEnabled(false)
                }
                #endif
            }
        }
    
    /// Handles remote store changes from CloudKit.
       private func remoteStoreChanged(_ notification: Notification) {
           objectWillChange.send()
       }
    
    /// Creates sample data for SwiftUI previews and testing.
        func createSampleData() {
            let viewContext = container.viewContext
            
            for tagCount in 1...5 {
                let tag = Tag(context: viewContext)
                tag.id = UUID()
                tag.name = "Tag \(tagCount)"
                
                for issueCount in 1...10 {
                    let issue = Issue(context: viewContext)
                    issue.title = "Issue \(tagCount)-\(issueCount)"
                    issue.content = "Description goes here"
                    issue.creationDate = .now
                    issue.isCompleted = Bool.random()
                    issue.priority = Int16.random(in: 0...2)
                    tag.addToIssues(issue)
                }
            }
            try? viewContext.save()
        }
    
    /// Saves any pending changes in the Core Data context.
    /// If there are changes, they are committed to the persistent store.
    /// Any previously queued save tasks are canceled to avoid redundant operations.
    func saveChanges() {
        // Step 1: Cancel any previously queued save task to prevent duplicate saves
        saveTask?.cancel()
        
        // Step 2: Check if there are unsaved changes in the context
        if container.viewContext.hasChanges {
            // Step 3: Attempt to save changes, using `try?` to safely ignore errors
            try? container.viewContext.save()
        }
    }

        
        /// Queues a save operation with a 3-second delay.
        func queueSave() {
            saveTask?.cancel()
            
            saveTask = Task { @MainActor in
                try await Task.sleep(for: .seconds(3))
                saveChanges()
            }
        }
        
        /// Deletes a specific Core Data object.
        /// - Parameter object: The object to delete.
        func deleteObject(object: NSManagedObject) {
            objectWillChange.send()
            container.viewContext.delete(object)
            saveChanges()
        }
        
        /// Deletes all objects matching a given fetch request using batch deletion.
        /// - Parameter request: The fetch request specifying objects to delete.
        private func deleteRequest(request: NSFetchRequest<NSFetchRequestResult>) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
            }
        }
        
        /// Deletes all data in the Core Data store.
        func deleteAllData() {
            let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
            deleteRequest(request: request1)
            
            let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
            deleteRequest(request: request2)
            
            saveChanges()
        }
        
        /// Determines missing tags for a given issue.
        /// - Parameter issue: The issue for which missing tags are needed.
        /// - Returns: An array of missing tags.
        func missingTags(from issue: Issue) -> [Tag] {
            let request = Tag.fetchRequest()
            let allTags = (try? container.viewContext.fetch(request)) ?? []
            
            let allTagsSet = Set(allTags)
            
            let difference = allTagsSet.symmetricDifference(issue.issueTag)
            
            return difference.sorted()
        }
     
        /// Fetches issues based on the currently selected filters and search criteria.
        /// - Returns: An array of `Issue` objects that match the selected criteria.
        func issueForSelectedFilter() -> [Issue] {
        // Step 1: Get the current filter or default to `.all`
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        // Step 2: Apply filter based on selected tag OR modification date
        if let tag = filter.tag {
            // If a specific tag is selected, filter issues that contain this tag
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            // If no tag is selected, filter issues modified after the minimum modification date
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        // Step 3: Apply search text filter
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedSearchText.isEmpty {
            // Search for issues where title or content contains the search text (case-insensitive)
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedSearchText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedSearchText)

            // Combine title and content predicates using OR logic
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
            predicates.append(combinedPredicate)
        }

        // Step 4: Apply token-based filtering if tokens are present
        if !searchTokens.isEmpty {
            for token in searchTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", token)
                predicates.append(tokenPredicate)
            }
        }

        // Step 5: Apply additional filtering options if enabled
        if filterEnabled {
            // Apply priority filter if a valid priority value is set
            if filterPriority >= 0 {
                let priorityPredicate = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityPredicate)
            }

            // Apply status filter based on completion state
            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusPredicate = NSPredicate(format: "isCompleted = %@", NSNumber(value: lookForClosed))
                predicates.append(statusPredicate)
            }
        }

        // Step 6: Create a fetch request for `Issue`
        let request = Issue.fetchRequest()
        
        // Combine all predicates using AND logic to match multiple conditions
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        // Step 7: Apply sorting based on the selected sort type
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]

        // Step 8: Execute the fetch request and return the results
        return (try? container.viewContext.fetch(request)) ?? []
        }

        
        /// Creates and adds a new issue to Core Data with default values.
        /// If a tag is currently selected, the new issue is linked to that tag.
        func addNewIssue() {
        // Step 1: Create a new Issue object in the managed object context
        let issue = Issue(context: container.viewContext)
        
        // Step 2: Set default properties for the new issue
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue") // Default title (localized)
        issue.creationDate = .now  // Set the creation date to the current time
        issue.priority = 1         // Default priority level
        
        // Step 3: If a tag is selected, associate it with the new issue
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        
        // Step 4: Save the changes to persist the new issue
        saveChanges()
        
        // Step 5: Set the newly created issue as the currently selected issue
        selectedIssue = issue
        }

        
        /// Adds a new tag to Core Data.
        func addNewTag() {
            let tag = Tag(context: container.viewContext)
            
            tag.id = UUID()
            tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
            
            saveChanges()
        }
        
        /// Counts the number of objects for a given fetch request.
        /// - Parameter fetchRequest: The fetch request to count.
        /// - Returns: The number of objects matching the request.
        func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
            (try? container.viewContext.count(for: fetchRequest)) ?? 0
        }
        
        /// Determines if a user has earned a specific award.
        /// - Parameter award: The award to check.
        /// - Returns: `true` if the user has met the award's criterion, otherwise `false`.
        func hasEarned(award: Award) -> Bool {
            switch award.criterion {
            case "issues":
                return count(for: Issue.fetchRequest()) >= award.value
            case "closed":
                let fetchRequest = Issue.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "isCompleted = true")
                return count(for: fetchRequest) >= award.value
            case "tags":
                return count(for: Tag.fetchRequest()) >= award.value
            default:
                return false
            }
        }
    }
