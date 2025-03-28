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
    
    static var preview: DataController {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }
    
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.loadPersistentStores{ storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
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
}
