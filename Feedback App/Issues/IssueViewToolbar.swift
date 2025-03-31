//
//  IssueViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A toolbar menu for managing an issue,
/// providing actions such as copying the issue title
/// and toggling completion status.
struct IssueViewToolbar: View {
    
    /// The shared data controller for managing application data.
    @EnvironmentObject var dataController: DataController
    
    /// The issue being displayed and managed in the toolbar.
    @ObservedObject var issue: Issue
    
    /// Determines the text for the open/close issue button based on its completion status.
    var openCloseButtonText: String {
        issue.isCompleted ? "Re-open Issue" : "Close Issue"
    }
    
    var body: some View {
        Menu {
            // Button to copy the issue title to the clipboard
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }
            
            // Button to toggle issue completion status and save the change
            Button {
                issue.isCompleted.toggle()
                dataController.saveChanges()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
        .environmentObject(DataController(inMemory: true))
}
