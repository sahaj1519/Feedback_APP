//
//  SidebarView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI

/// A sidebar view that displays smart filters and user-defined tags for issue management.
///
/// This view consists of:
/// - A **Smart Filters** section containing predefined filters.
/// - A **Tags** section displaying user-created tags that can be renamed or deleted.
/// - A **Toolbar** providing quick actions.
/// - An **Alert** for renaming tags.
///
/// - Note: This view requires a `DataController` instance for Core Data operations.
struct SidebarView: View {
    
    /// The view model responsible for handling tag-related operations.
    @StateObject private var viewModel: ViewModel

    /// Predefined smart filters available for all users.
    ///
    /// These filters help users quickly access all issues or recent ones.
    let smartFilters: [Filter] = [.all, .recent]
    
    /// Initializes the `SidebarView` with a `DataController`.
    ///
    /// - Parameter dataController: The `DataController` instance managing Core Data operations.
    ///
    /// This initializer:
    /// 1. Creates an instance of `SidebarView.ViewModel`.
    /// 2. Wraps the ViewModel inside a `StateObject` to ensure it's properly managed by SwiftUI.
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {

            /// **Smart Filters Section**
            /// - Displays predefined filters that users can use to categorize issues.
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            
            /// **Tags Section**
            /// - Displays user-created tags.
            /// - Allows renaming and deleting tags.
            Section("Tags") {
                ForEach(viewModel.tagFilters) { item in
                    UserFilterRow(
                        filter: item,
                        rename: viewModel.rename,
                        deleteTagAnotherMethod: viewModel.deleteTagAnotherMethod
                    )
                }
                .onDelete(perform: viewModel.deleteTag) // Enables swipe-to-delete for tags.
            }
        }
        .toolbar(content: SidebarViewToolbar.init) // Adds toolbar actions.
        
        /// **Rename Tag Alert**
        /// - Displays an alert when a tag is selected for renaming.
        /// - Provides a text field to enter a new name.
        /// - Includes "OK" and "Cancel" buttons.
        .alert("Rename Tag", isPresented: $viewModel.isAlertForRenameTag) {
            Button("OK", action: viewModel.saveRenameTag)
            Button("Cancel", role: .cancel) { }
            TextField("New Name", text: $viewModel.tagNewName)
        }
        
        /// Sets the navigation title for the sidebar.
        .navigationTitle("Filters")
    }
}

#Preview {
    /// Provides a preview of `SidebarView` using a sample `DataController`.
    SidebarView(dataController: .preview)
        .environmentObject(DataController.preview)
}
