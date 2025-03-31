//
//  ContentView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI
import CoreData

/// The main view displaying a list of issues in the app.
struct ContentView: View {
    
    /// The shared data controller for managing Core Data operations and UI states.
    @EnvironmentObject var dataController: DataController
    
    /// Deletes an issue from the list.
    /// - Parameter offset: The index set of issues to delete.
    func deleteIssue(_ offset: IndexSet) {
        let issues = dataController.issueForSelectedFilter()
        for index in offset {
            let item = issues[index]
            dataController.deleteObject(object: item)
        }
    }
    
    var body: some View {
        /// A list of issues, supporting selection and deletion.
        List(selection: $dataController.selectedIssue) {
            // Loops through filtered issues and displays each as a row.
            ForEach(dataController.issueForSelectedFilter()) { item in
                ContentViewRows(issue: item)
            }
            .onDelete(perform: deleteIssue) // Enables swipe-to-delete functionality.
        }
        .navigationTitle("Issues") // Sets the navigation bar title.
        
        // Adds a search bar for filtering issues by text or tags.
        .searchable(
            text: $dataController.searchText,
            tokens: $dataController.searchTokens,
            suggestedTokens: .constant(dataController.suggestedSearchTokens),
            prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.tagName) // Displays suggested tag names.
        }
        
        // Adds the toolbar containing sorting, filtering, and issue creation options.
        .toolbar(content: ContentViewToolbar.init)
    }
}

#Preview {
    /// A preview of `ContentView`, using a preview data controller.
    ContentView()
        .environmentObject(DataController.preview)
}
