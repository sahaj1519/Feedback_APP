//
//  TagMenuView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

struct TagMenuView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            ForEach(issue.issueTag) { tag in
                Button {
                    issue.removeFromTags(tag)
                }label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
                let otherTags = dataController.missingTags(from: issue)
                
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
            
        }label: {
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
