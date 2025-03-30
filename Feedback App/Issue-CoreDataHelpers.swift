//
//  Issue-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

extension Issue {
    
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    var issueTag: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var issueIsCompleted: String {
        if isCompleted {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    var issueTagList: String {
        guard let tags else { return "No tags" }
        
        if tags.count == 0 {
            return "No tags"
        } else {
            return issueTag.map(\.tagName).formatted()
        }
    }
    
    var issueFormattedCreationDate: String {
        issueCreationDate.formatted(date: .numeric, time: .omitted)
    }

    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        let issue = Issue(context: context)
            issue.title = "Example Issue"
            issue.content = "This is an example issue."
            issue.priority = 2
            issue.creationDate = .now
            return issue
    }
}

extension Issue: Comparable {
    
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
