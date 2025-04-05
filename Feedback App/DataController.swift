/// DataController is responsible for managing Core Data operations and CloudKit integration.
/// It handles data persistence, filtering, sorting, and deletion of issues and tags.
///
/// - Uses `NSPersistentCloudKitContainer` for CloudKit synchronization.
/// - Implements filtering and searching logic for issues.
/// - Provides methods to manage issues and tags.
/// - Supports batch deletion and remote store updates.

import CoreData
import StoreKit
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

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
    
    #if !os(watchOS)
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
    #endif
    
    
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
    @Published var sortOldestFirst = false
    
    @Published var products = [Product]()
    
    /// Background save task to optimize performance.
    private var saveTask: Task<Void, Error>?
    var storeTask: Task<Void, Never>?
    
    let defaults: UserDefaults
    
    /// Preview instance for SwiftUI previews, preloaded with sample data.
    static var preview: DataController  = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    /// Provides suggested tags based on the current search text.
    var suggestedSearchTokens: [Tag] {
        // Ensure the search text starts with "#" before suggesting tags
        guard searchText.starts(with: "#") else { return [] }
        
        let trimmedSearchText = String(searchText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        // Apply a case-insensitive predicate if search text is not empty
        if !trimmedSearchText.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedSearchText)
        }
        
        // Fetch and return the sorted results, or return an empty array if fetch fails
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    /// Loads the Core Data model from the app bundle.
    static let model: NSManagedObjectModel = {
        // Locate the model file in the app bundle
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }
        
        // Load the model file into an `NSManagedObjectModel` instance
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        
        return managedObjectModel
    }()
    
    /**
     Initializes the Core Data stack, setting up the persistent container
     along with CloudKit integration and Spotlight indexing.

     This initializer performs several key tasks:
     
     1. **Persistent Container Initialization:**
        It creates an instance of `NSPersistentCloudKitContainer` using the specified data model.
        This container is responsible for managing the Core Data stack and
        integrating with CloudKit for syncing changes.
     
     2. **Store Task Setup:**
        A background task is started to monitor transactions, ensuring that any changes are tracked appropriately.
     
     3. **In-Memory Store Configuration (Optional):**
        If the `inMemory` parameter is set to `true`,
        the persistent store is configured to use an in-memory store (by setting its URL to `/dev/null`),
        which is particularly useful for previews and unit testing without affecting the on-disk database.
     
     4. **Context Merging and Conflict Resolution:**
        The main view context is configured to automatically merge changes from its parent and
        uses the `mergeByPropertyObjectTrump` merge policy to resolve conflicts,
        ensuring that in-memory changes take precedence.
     
     5. **CloudKit Remote Change Notifications:**
        Remote change notifications are enabled by setting the
       `NSPersistentStoreRemoteChangeNotificationPostOptionKey` on the persistent store.
        This allows the app to listen for updates from CloudKit and update the UI accordingly.
     
     6. **Observing Remote Store Changes:**
        An observer is added to the notification center to handle `NSPersistentStoreRemoteChange` notifications,
        enabling the app to react to changes that occur in the remote store.
     
     7. **Persistent Store Loading and Error Handling:**
        The persistent store is loaded asynchronously. In the event of an error,
        the app terminates with a fatal error message containing a description of the failure.
     
     8. **Persistent History Tracking and Spotlight Indexing:**
        After successfully loading the store, persistent history tracking is enabled for data consistency.
        If available, the `NSCoreDataCoreSpotlightDelegate`
        is configured to start indexing Core Data entities with Spotlight,
        making the data searchable from the system level.
     
     9. **Testing Environment Setup:**
        For debugging and testing purposes (when the "enable-testing" argument is present),
        all existing data is deleted and UI animations are disabled to ensure a consistent test environment.

     - Parameters:
        - inMemory: A Boolean flag indicating whether an in-memory store should be used.
                   Defaults to `false`. Set this to `true` for testing or previews.
        - defaults: The `UserDefaults` instance used for storing application preferences. Defaults to `.standard`.

     After execution, the Core Data stack is fully initialized with support for local persistence,
     remote syncing via CloudKit, and integration with system-wide search through Spotlight.
     */
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // Create a persistent container using the loaded model
        container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: DataController.model)
        
        storeTask = Task {
            await monitorTransaction()
        }
        
        // Configure an in-memory store if requested (used for previews and unit tests)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        } else {
             let groupID = "group.Portfolio.Feedback-App"
            
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Model.sqlite")
            }
        }
        
        // Enable automatic merging of changes between contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Enable remote store change notifications for CloudKit syncing
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey)
        
        // Observe CloudKit changes and update UI accordingly
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
       
        // Load the persistent store and handle errors if any occur
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            // Enable persistent history tracking for data consistency
           #if !os(watchOS)
            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                
                // Configure Spotlight search indexing
                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )
                    
                    // Start indexing Core Data entities with Spotlight
                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }
            #endif
            self?.checkForTestEnvironment()
        }
    }

    
    /// Handles remote store changes from CloudKit.
    private func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    /// Searches for an issue using a unique identifier from Spotlight.
    /// - Parameter uniqueIdentifier: The identifier of the issue.
    /// - Returns: The matching `Issue` object, or `nil` if not found.
    func spotlightsearchissue(with uniqueIdentifier: String) -> Issue? {
        // Ensure the identifier is a valid URL
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }
        
        // Retrieve the object ID from the Core Data store
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        
        // Fetch the corresponding `Issue` object
        return try? container.viewContext.existingObject(with: id) as? Issue
    }
    
    /// Creates sample data for SwiftUI previews and testing.
    func createSampleData() {
        let viewContext = container.viewContext
        
        // Generate five sample tags
        for tagCount in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCount)"
            
            // Each tag contains ten sample issues
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
        
        // Save the sample data
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
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    /// Deletes a specific Core Data object.
    /// - Parameter object: The object to delete.
    func deleteObject(object: NSManagedObject) {
        // Notify observers that a change is happening
        objectWillChange.send()
        
        // Remove the object from the context
        container.viewContext.delete(object)
        
        // Persist the deletion
        saveChanges()
    }
    
    /// Deletes all objects matching a given fetch request using batch deletion.
    /// - Parameter request: The fetch request specifying objects to delete.
    private func deleteRequest(request: NSFetchRequest<NSFetchRequestResult>) {
        // Create a batch delete request to remove all matching objects
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        // Execute the batch delete request and merge changes into the context
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    /// Deletes all data in the Core Data store.
    func deleteAllData() {
        // Create fetch requests for each entity
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        deleteRequest(request: request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        deleteRequest(request: request2)
        
        // Save changes to persist deletions
        saveChanges()
    }
    
    /// Determines missing tags for a given issue.
    /// - Parameter issue: The issue for which missing tags are needed.
    /// - Returns: An array of missing tags.
    func missingTags(from issue: Issue) -> [Tag] {
        // Fetch all available tags from Core Data
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        // Convert fetched tags into a Set for comparison
        let allTagsSet = Set(allTags)
        
        // Compute the difference between all tags and the issue's tags
        let difference = allTagsSet.symmetricDifference(issue.issueTag)
        
        // Return sorted missing tags
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
        for token in searchTokens {
            let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", token)
            predicates.append(tokenPredicate)
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
                let lookForClosed = (filterStatus == .closed)
                let statusPredicate = NSPredicate(format: "isCompleted = %@", NSNumber(value: lookForClosed))
                predicates.append(statusPredicate)
            }
        }
        
        // Step 6: Create a fetch request for `Issue`
        let request = Issue.fetchRequest()
        
        // Combine all predicates using AND logic to match multiple conditions
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Step 7: Apply sorting based on the selected sort type
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortOldestFirst)]
        
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
    func addNewTag() -> Bool {
        var shouldCreate = fullVersionUnlocked
        if shouldCreate == false {
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }
        
        guard shouldCreate else { return false }
        let tag = Tag(context: container.viewContext)
        
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        
        saveChanges()
        return true
    }
    
    /// Counts the number of objects for a given fetch request.
    /// - Parameter fetchRequest: The fetch request to count.
    /// - Returns: The number of objects matching the request.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        
        request.predicate = NSPredicate(format: "isCompleted = false")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Issue.priority, ascending: false)
        ]
        
        request.fetchLimit = count
        return request
    }
    
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
