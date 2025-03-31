//
//  SidebarView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI

/// A sidebar view that displays smart filters and user-defined tags for issue management.
struct SidebarView: View {
    
    /// Access to the shared data controller for managing Core Data operations.
    @EnvironmentObject var dataController: DataController
    
    /// Predefined smart filters available for all users.
    let smartFilters: [Filter] = [.all, .recent]
    
    /// Fetch request to retrieve tags from Core Data, sorted alphabetically by name.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    /// The tag selected for renaming.
    @State private var tagToRename: Tag?
    
    /// Boolean to control the display of the rename alert.
    @State private var isAlertForRenameTag = false
    
    /// The new name entered by the user for renaming a tag.
    @State private var tagNewName = ""

    /// Converts fetched `Tag` objects into `Filter` instances for display in the UI.
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagId, name: tag.tagName, icon: "tag.fill", tag: tag)
        }
    }
    
    /// Deletes a tag based on its index in the list.
    /// - Parameter offset: The index set of the tag(s) to be deleted.
    func deleteTag(_ offset: IndexSet) {
        for index in offset {
            let item = tags[index]
            dataController.deleteObject(object: item)
        }
    }
    
    /// Deletes a tag using an alternative method.
    /// - Parameter filter: The filter representing the tag to be deleted.
    func deleteTagAnotherMethod(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.deleteObject(object: tag)
        dataController.saveChanges()
    }
    
    /// Prepares a tag for renaming.
    /// - Parameter filter: The filter representing the tag to be renamed.
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagNewName = filter.name
        isAlertForRenameTag = true
    }
    
    /// Saves the new name for the selected tag.
    func saveRenameTag() {
        tagToRename?.name = tagNewName
        dataController.saveChanges()
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            // Section for Smart Filters
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            
            // Section for User-defined Tags
            Section("Tags") {
                ForEach(tagFilters) { item in
                    UserFilterRow(
                        filter: item,
                        rename: rename,
                        deleteTagAnotherMethod: deleteTagAnotherMethod
                    )
                }
                .onDelete(perform: deleteTag)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename Tag", isPresented: $isAlertForRenameTag) {
            Button("OK", action: saveRenameTag)
            Button("Cancel", role: .cancel) { }
            TextField("New Name", text: $tagNewName)
        }
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
