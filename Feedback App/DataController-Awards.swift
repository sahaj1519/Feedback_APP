//
//  DataController-Awards.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 04/04/25.
//

import Foundation

extension DataController {
    
    /// Determines if a user has earned a specific award.
    /// - Parameter award: The award to check.
    /// - Returns: `true` if the user has met the award's criterion, otherwise `false`.
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            return count(for: Issue.fetchRequest()) >= award.value
            
        case "closed":
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isCompleted = true")
            return count(for: fetchRequest) >= award.value
            
        case "tags":
            return count(for: Tag.fetchRequest()) >= award.value
            
        case "unlock":
            return fullVersionUnlocked
            
        default:
            return false
        }
    }
}
