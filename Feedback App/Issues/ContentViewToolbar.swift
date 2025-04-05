//
//  ContentViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A toolbar view that provides filtering, sorting, and issue creation options in the app.
struct ContentViewToolbar: View {
    
    /// The shared data controller for managing Core Data operations and UI states.
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        /// A menu containing filter and sorting options for issues.
     #if !os(watchOS)
        Menu {
            // A toggle button to enable or disable filtering.
            Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                dataController.filterEnabled.toggle()
            }
            
            /// A submenu for sorting options.
            Menu("Sort By") {
                // Picker for selecting sorting type (by creation date or modification date).
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Date Created").tag(SortType.dateCreated)
                    Text("Date Modified").tag(SortType.dateModified)
                }
                .pickerStyle(.inline)
                .labelsHidden()
                
                Divider() // Adds a visual separator between sections.
                
                // Picker for selecting sorting order (newest to oldest or vice versa).
                Picker("Sort Order", selection: $dataController.sortOldestFirst) {
                    Text("Newest To Oldest").tag(false)
                    Text("Oldest To Newest").tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            /// A picker to filter issues by status (All, Open, Closed).
            Picker("Status", selection: $dataController.filterStatus) {
                Text("All").tag(Status.all)
                Text("Open").tag(Status.open)
                Text("Closed").tag(Status.closed)
            }
            .disabled(dataController.filterEnabled == false) // Disables status filter if filtering is off.
            
            /// A picker to filter issues by priority (Low, Medium, High).
            Picker("Priority", selection: $dataController.filterPriority) {
                Text("All").tag(-1)
                Text("Low").tag(0)
                Text("Medium").tag(1)
                Text("High").tag(2)
            }
            .disabled(dataController.filterEnabled == false) // Disables priority filter if filtering is off.
            
        } label: {
            // Filter button with an icon that changes based on filter state.
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterEnabled ? .fill : .none)
        }
        .help("Filter")
       #endif
        
        /// A button to add a new issue.
        Button(action: dataController.addNewIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
        .help("New Issue")
    }
    
}

#Preview {
    /// A preview of `ContentViewToolbar`, using an in-memory data controller for testing.
    ContentViewToolbar()
        .environmentObject(DataController(inMemory: true))
}
