//
//  ContentViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Menu {
            Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                dataController.filterEnabled.toggle()
            }
            
            Menu("Sort By") {
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Date Created").tag(SortType.dateCreated)
                    Text("Date Modified").tag(SortType.dateModified)
                }
                
                Divider()
                
                Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                    Text("Newest To Oldest").tag(true)
                    Text("Oldest To Newest").tag(false)
                }
            }
            
            Picker("Status", selection: $dataController.filterStatus) {
                Text("All").tag(Status.all)
                Text("Open").tag(Status.open)
                Text("Closed").tag(Status.closed)
            }
            .disabled(dataController.filterEnabled == false)
            
            Picker("Priority", selection: $dataController.filterPriority) {
                Text("All").tag(-1)
                Text("Low").tag(0)
                Text("Medium").tag(1)
                Text("High").tag(2)
            }
            .disabled(dataController.filterEnabled == false)
            
        }label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterEnabled ? .fill : .none)
        }
        
        Button(action: dataController.addNewIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
    }
}

#Preview {
    ContentViewToolbar()
        .environmentObject(DataController(inMemory: true))
}
