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
        Form{
            Section{
                VStack(alignment: .leading){
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueIsCompleted)")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority){
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                Menu {
                    ForEach(issue.issueTag){tag in
                        Button{
                            issue.removeFromTags(tag)
                        }label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }
                        let otherTags = dataController.missingTags(from: issue)
                        
                        if otherTags.isEmpty == false {
                            Divider()
                            
                            Section("Add Tags"){
                                ForEach(otherTags){item in
                                    Button(item.tagName){
                                        issue.addToTags(item)
                                    }
                                }
                            }
                        }
                    
                }label:{
                    Text(issue.issueTagList)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(nil,value: issue.issueTagList)
                }
            }
            
            Section(""){
                VStack(alignment: .leading){
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
                }
            }
        }.disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange){ _ in
                dataController.queueSave()
            }
        .onSubmit(dataController.saveChanges)
            .toolbar{
                Menu{
                    
                    Button{
                        UIPasteboard.general.string = issue.title
                    }label: {
                        Label("Copy Issue Title", systemImage: "doc.on.doc")
                    }
                    
                    Button{
                        issue.isCompleted.toggle()
                        dataController.saveChanges()
                    }label: {
                        Label(issue.isCompleted ? "Re-open Issue" : "Close Issue", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                    }
                    
                }label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        
    }
}

#Preview {
    DetailViewWithIssue(issue: .example)
}
