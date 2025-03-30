//
//  IssueViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var openCloseButtonText: String {
        issue.isCompleted ? "Re-open Issue" : "Close Issue"
    }
    
    var body: some View {
        Menu {
            
            Button {
                UIPasteboard.general.string = issue.title
            }label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }
            
            Button {
                issue.isCompleted.toggle()
                dataController.saveChanges()
            }label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            
        }label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
        .environmentObject(DataController(inMemory: true))
}
