//
//  SidebarView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    var tagFilters: [Filter]{
        tags.map{ tag in
            Filter(id: tag.id ?? UUID(), name: tag.name ?? "No name", icon: "tag.fill", tag: tag)
        }
    }
    
    var body: some View {

        List(selection: $dataController.selectedFilter){
            Section("Smart Filters"){
                ForEach(smartFilters){ item in
                    NavigationLink(value: item){
                        Label(item.name, systemImage: item.icon)
                    }
                }
            }
            Section("Tags"){
                ForEach(tagFilters){ item in
                    NavigationLink(value: item){
                        Label(item.name, systemImage: item.icon)
                    }
                    
                }
            }
        }.toolbar{
            Button{
                dataController.deleteAllData()
                dataController.createSampleData()
            }label: {
                Label("Add Samples", systemImage: "plus")
            }
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
