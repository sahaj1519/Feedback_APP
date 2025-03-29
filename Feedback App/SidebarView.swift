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
    
    @State private var tagToRename: Tag?
    @State private var isAlertForRenameTag = false
    @State private var tagNewName = ""
    
    @State private var isShowingAward = false
    
    var tagFilters: [Filter]{
        tags.map{ tag in
            Filter(id: tag.tagId, name: tag.tagName, icon: "tag.fill", tag: tag)
               
        }
    }
    
    func deleteTag(_ offset: IndexSet){
        for index in offset {
            let item = tags[index]
            dataController.deleteObject(object: item)
        }
    }
    
    func deleteTagAnotherMethod(_ filter: Filter){
        guard let tag = filter.tag else{ return}
        
        dataController.deleteObject(object: tag)
        dataController.saveChanges()
    }
    
    func rename(_ filter: Filter){
        tagToRename = filter.tag
        tagNewName = filter.name
        isAlertForRenameTag = true
    }
    
    func saveRenameTag(){
        tagToRename?.name = tagNewName
        dataController.saveChanges()
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
                            .badge(item.tag?.tagIssue.count ?? 0)
                            .contextMenu{
                                Button{
                                    rename(item)
                                }label:{
                                    Label("Rename", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive){
                                    deleteTagAnotherMethod(item)
                                }label:{
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    
                }.onDelete(perform: deleteTag)
            }
        }.toolbar{
            Button{
                isShowingAward.toggle()
            }label:{
                Label("Show Awards", systemImage: "rosette")
            }
            
            Button(action: dataController.addNewTag){
                Label("Add Tag", systemImage: "plus")
            }
        #if DEBUG
            Button{
                dataController.deleteAllData()
                dataController.createSampleData()
            }label: {
                Label("Add Samples", systemImage: "flame")
            }
        #endif
        }
        .alert("Rename Tag", isPresented: $isAlertForRenameTag){
            Button("OK", action: saveRenameTag)
            Button("Cancel", role: .cancel){ }
            TextField("New Name", text: $tagNewName)
        }
        .sheet(isPresented: $isShowingAward, content: AwardsView.init)
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
