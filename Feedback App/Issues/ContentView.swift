//
//  ContentView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI
import CoreData

/// The main view displaying a list of issues in the app.
///
/// This view provides:
/// - A **list of issues** with support for selection and deletion.
/// - A **search bar** for filtering issues based on text or tags.
/// - A **toolbar** with sorting, filtering, and issue creation options.
///
/// - Note: This view requires a `DataController` to manage issue data.
struct ContentView: View {
    
    /// The view model responsible for managing issue-related operations.
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.requestReview) var requestReview
    
    /// Initializes the `ContentView` with a `DataController`.
    ///
    /// - Parameter dataController: The `DataController` instance responsible for handling Core Data operations.
    ///
    /// This initializer:
    /// 1. Creates an instance of `ContentView.ViewModel`.
    /// 2. Wraps the ViewModel inside a `StateObject` to ensure it's properly managed by SwiftUI.
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
    
    var body: some View {
        /// **List of Issues**
        /// - Displays all issues that match the selected filter.
        /// - Supports selection and deletion.
        List(selection: $viewModel.selectedIssue) {
            // Loops through filtered issues and displays each as a row.
            ForEach(viewModel.dataController.issueForSelectedFilter()) { item in
                ContentViewRows(issue: item)
            }
            .onDelete(perform: viewModel.deleteIssue) // Enables swipe-to-delete functionality.
        }
        
        /// **Navigation Title**
        /// - Sets the navigation bar title to "Issues".
        .navigationTitle("Issues")
        
        /// **Search Bar**
        /// - Allows users to search issues by text or tags.
        /// - Supports token-based filtering by typing `#` to add tags.
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.searchTokens,
            suggestedTokens: .constant(viewModel.suggestedSearchTokens),
            prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.tagName) // Displays suggested tag names.
        }
        
        /// **Toolbar**
        /// - Contains options for sorting, filtering, and creating new issues.
        .toolbar(content: ContentViewToolbar.init)
        .onAppear(perform: askForReview)
    }
}

#Preview {
    /// Provides a preview of `ContentView` using a sample `DataController`.
    ContentView(dataController: .preview)
        .environmentObject(DataController.preview)
}
