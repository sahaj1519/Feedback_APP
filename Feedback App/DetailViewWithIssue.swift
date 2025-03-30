//
//  DetailViewWithIssue.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//
import CoreData
import SwiftUI

struct DetailViewWithIssue: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueIsCompleted)")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                TagMenuView(issue: issue)
            }
            
            Section("") {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                }
            }
        }.disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
                dataController.queueSave()
            }
        .onSubmit(dataController.saveChanges)
        .toolbar {IssueViewToolbar(issue: issue)}
        
    }
}

#Preview {
    DetailViewWithIssue(issue: .example)
}
