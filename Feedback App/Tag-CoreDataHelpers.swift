//
//  Tag-CoreDataHelpers.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import SwiftUI

extension Tag{
    
    var tagId: UUID{
        id ?? UUID()
    }
    
    var tagName: String{
        name ?? ""
    }
    
    var tagIssue: [Issue]{
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { $0.isCompleted == false}
    }
    
    static var example: Tag{
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = "Example Tag"
        return tag
    }
}

extension Tag: Comparable{
    
    public static func <(lhs: Tag, rhs: Tag) -> Bool{
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        
        if left == right {
            return lhs.tagId.uuidString < rhs.tagId.uuidString
        }else{
            return left < right
        }
    }
}
