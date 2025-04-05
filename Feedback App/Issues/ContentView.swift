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
    
    private let newIssueActivity = "Portfolio.Feedback-App.newIssue"
    
    /// The view model responsible for managing issue-related operations.
    @StateObject private var viewModel: ViewModel
    
    /// Handles in-app review requests.
    #if !os(watchOS)
    @Environment(\.requestReview) var requestReview
    #endif
    
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
    
    /// Requests an in-app review if conditions are met.
    ///
    /// - This function is triggered when `ContentView` appears.
    /// - It checks whether the app should request a review, then prompts the system review dialog.
    #if !os(watchOS)
    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
    #endif
    
    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.addNewIssue()
    }
    
    var body: some View {
        /// **List of Issues**
        /// - Displays all issues that match the selected filter.
        /// - Supports selection and deletion.
        List(selection: $viewModel.selectedIssue) {
            /// Loops through filtered issues and displays each as a row.
            ForEach(viewModel.dataController.issueForSelectedFilter()) { item in
              #if os(watchOS)
                 ContentViewRowWatch(issue: item)
              #else
                ContentViewRows(issue: item)
              #endif
            }
            .onDelete(perform: viewModel.deleteIssue) // Enables swipe-to-delete functionality.
        }
        .macFrame(minWidth: 220)
        
        /// **Navigation Title**
        /// - Sets the navigation bar title to "Issues".
        .navigationTitle("Issues")
        
        /// **Search Bar**
        /// - Allows users to search issues by text or tags.
        /// - Supports token-based filtering by typing `#` to add tags.
        #if !os(watchOS)
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.searchTokens,
            suggestedTokens: .constant(viewModel.suggestedSearchTokens),
            prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.tagName) // Displays suggested tag names.
        }
        #endif
        
        /// **Toolbar**
        /// - Contains options for sorting, filtering, and creating new issues.
        .toolbar(content: ContentViewToolbar.init)
        
        /// **Triggers in-app review request when the view appears.**
        #if !os(watchOS)
        .onAppear(perform: askForReview)
        #endif
        .onOpenURL(perform: viewModel.openURL)
        .userActivity(newIssueActivity) { activity in
            #if !os(macOS)
            activity.isEligibleForPrediction = true
            #endif
            activity.title = "New Issue"
        }
        .onContinueUserActivity(newIssueActivity, perform: resumeActivity)
    }
}

#Preview {
    /// Provides a preview of `ContentView` using a sample `DataController`.
    ContentView(dataController: .preview)
        .environmentObject(DataController.preview)
}
