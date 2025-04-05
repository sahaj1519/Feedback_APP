//
//  DetailView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import CoreData
import SwiftUI

/// A view that displays the details of a selected issue.
/// If no issue is selected, it shows a placeholder message.
struct DetailView: View {
    
    /// The shared data controller responsible for managing app data.
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            // Check if an issue is selected and display the corresponding view
            if let issue = dataController.selectedIssue {
                DetailViewWithIssue(issue: issue)
            } else {
                DetailViewNoIssue()
            }
        }
        .navigationTitle("Details")
        .InlineNavigationBar()
    }
}

#Preview {
    DetailView()
        .environmentObject(DataController.preview)
}
