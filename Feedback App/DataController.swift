//
//  DataController.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import CoreData

class DataController: ObservableObject {
    
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var searchText = ""
    @Published var searchTokens = [Tag]()
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController  = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    var suggestedSearchTokens: [Tag]{
        guard searchText.starts(with: "#")else{ return []}
        
        let trimmedSearchText = String(searchText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedSearchText.isEmpty == false{
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedSearchText)
        }
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        container.loadPersistentStores{ storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func remoteStoreChanged(_ notification: Notification){
        objectWillChange.send()
    }
    
    func createSampleData(){
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.isCompleted = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
            
        }
        try? viewContext.save()
    }
    
    func saveChanges(){
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func queueSave(){
        saveTask?.cancel()
        
        saveTask = Task{ @MainActor in 
             try await Task.sleep(for: .seconds(3))
             saveChanges()
        }
    }
    
    func deleteObject(object: NSManagedObject){
        objectWillChange.send()
        container.viewContext.delete(object)
        saveChanges()
    }
    
     private func deleteRequest(request: NSFetchRequest<NSFetchRequestResult>){
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
  func deleteAllData(){
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        deleteRequest(request: request1)
        
        let request2:  NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        deleteRequest(request: request2)
      
        saveChanges()
    }
    
    func missingTags(from issue: Issue) -> [Tag]{
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        
        let difference = allTagsSet.symmetricDifference(issue.issueTag)
        
        return difference.sorted()
    }
    
   func issueForSelectedFilter() -> [Issue]{
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        if let tag = filter.tag{
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
            
        }else{
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        if  trimmedSearchText.isEmpty == false{
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedSearchText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedSearchText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
       
       if searchTokens.isEmpty == false{
           
           for token in searchTokens {
               let tokenPredicate = NSPredicate(format: " tags CONTAINS %@", token)
               predicates.append(tokenPredicate)
           }
       }
       
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues.sorted()
    }
    
}
