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
    
    func deleteIssue(_ offset: IndexSet) {
        let issues = dataController.issueForSelectedFilter()
        for index in offset {
            let item = issues[index]
            dataController.deleteObject(object: item)
        }
    }
    
    var body: some View {
        
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issueForSelectedFilter()) { item in
                ContentViewRows(issue: item)
            }
            .onDelete(perform: deleteIssue)
        }
        .navigationTitle("Issues")
            .searchable(
                text: $dataController.searchText,
                tokens: $dataController.searchTokens,
                suggestedTokens: .constant(dataController.suggestedSearchTokens),
                prompt: "Filter issues, or type # to add tags"
            ) { tag in
                Text(tag.tagName)
              }
            .toolbar(content: ContentViewToolbar.init)
        
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
        
}
