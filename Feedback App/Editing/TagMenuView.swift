//
//  TagMenuView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A menu view for managing tags associated with an issue.
///
/// - Features:
///   - Allows users to **view, add, and remove** tags for an issue.
///   - Displays **existing tags** with a checkmark and provides a **removal option**.
///   - Lists **unassigned tags** and allows users to add them.
struct TagMenuView: View {
    
    /// The shared data controller for managing application data.
    ///
    /// - Used to retrieve available tags and manage tag associations.
    @EnvironmentObject var dataController: DataController
    
    /// The issue whose tags are being managed.
    ///
    /// - Observed for changes to dynamically update the UI.
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            /// **Displays assigned tags with a checkmark**
            ///
            /// - Users can tap a tag to remove it from the issue.
            ForEach(issue.issueTag) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            /// **Fetches unassigned tags**
            ///
            /// - Calls `dataController.missingTags(from: issue)` to get available tags.
            let otherTags = dataController.missingTags(from: issue)
            
            /// **Displays additional tags that can be assigned**
            ///
            /// - If there are unassigned tags, they appear under an "Add Tags" section.
            if otherTags.isEmpty == false {
                Divider()
                
                /// **Allows users to add new tags**
                Section("Add Tags") {
                    ForEach(otherTags) { item in
                        Button(item.tagName) {
                            issue.addToTags(item)
                        }
                    }
                }
            }
            
        } label: {
            /// **Displays a list of issue tags**
            ///
            /// - Ensures proper text alignment.
            /// - Updates dynamically when tags are modified.
            Text(issue.issueTagList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagList)
        }
    }
}

/// **Previews `TagMenuView` with example data**.
#Preview {
    TagMenuView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
