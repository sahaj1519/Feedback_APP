//
//  ContentViewRows.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//
import CoreData
import SwiftUI

struct ContentViewRows: View {
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue){
            HStack{
                
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                VStack(alignment: .leading){
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(issue.issueTagList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                }
                Spacer()
                
                VStack(alignment: .trailing){
                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)
                    
                    if issue.isCompleted{
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }.foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentViewRows(issue: .example)
}
