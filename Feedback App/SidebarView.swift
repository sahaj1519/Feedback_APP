import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    @State private var tagToRename: Tag?
    @State private var isAlertForRenameTag = false
    @State private var tagNewName = ""

    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagId, name: tag.tagName, icon: "tag.fill", tag: tag)
        }
    }
    
    func deleteTag(_ offset: IndexSet) {
        for index in offset {
            let item = tags[index]
            dataController.deleteObject(object: item)
        }
    }
    
    func deleteTagAnotherMethod(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.deleteObject(object: tag)
        dataController.saveChanges()
    }
    
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagNewName = filter.name
        isAlertForRenameTag = true
    }
    
    func saveRenameTag() {
        tagToRename?.name = tagNewName
        dataController.saveChanges()
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
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
