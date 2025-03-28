//
//  ContentView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue]{
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        
        if let tag = filter.tag{
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
            
        }else{
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@",  filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        return allIssues.sorted()
    }
    
    func delete(_ offset: IndexSet){
        for index in offset{
            let item = issues[index]
            dataController.deleteObject(object: item)
        }
    }
    
    var body: some View {
        
        List(selection: $dataController.selectedIssue){
            ForEach(issues){item in
                ContentViewRows(issue: item)
            }.onDelete(perform: delete)
        }.navigationTitle("Issues")
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
        
}
