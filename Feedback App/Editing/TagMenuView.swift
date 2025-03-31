//
//  TagMenuView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A menu view for managing tags associated with an issue.
struct TagMenuView: View {
    
    /// The shared data controller for managing application data.
    @EnvironmentObject var dataController: DataController
    
    /// The issue whose tags are being managed.
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            // Display existing tags with a checkmark and allow removal
            ForEach(issue.issueTag) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            // Fetch tags that are not currently assigned to the issue
            let otherTags = dataController.missingTags(from: issue)
            
            // If there are unassigned tags, provide an option to add them
            if otherTags.isEmpty == false {
                Divider()
                
                Section("Add Tags") {
                    ForEach(otherTags) { item in
                        Button(item.tagName) {
                            issue.addToTags(item)
                        }
                    }
                }
            }
            
        } label: {
            Text(issue.issueTagList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagList)
        }
    }
}

#Preview {
    TagMenuView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
