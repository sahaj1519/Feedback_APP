//
//  Award.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 29/03/25.
//

import SwiftUI

struct Award: Codable, Identifiable{
    
    var id: String{ name }
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String
    
    static let allAward = Bundle.main.decode("Awards.json" , as: [Award].self)
    static let example = allAward[0]
}
