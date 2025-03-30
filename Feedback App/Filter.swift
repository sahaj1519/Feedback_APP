//
//  Filter.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import Foundation

struct Filter: Identifiable, Hashable{
    
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    var activeIssueCount: Int{
        tag?.tagIssue.count ?? 0
    }
    
    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    static var recent = Filter(id: UUID(), name: "Recent Issues", icon: "clock", minModificationDate: .now.addingTimeInterval(86400 * -7))
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
     
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
