//
//  Award.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 29/03/25.
//

import SwiftUI

/// A model representing an award in the Feedback App.
struct Award: Codable, Identifiable {
    
    /// A unique identifier for each award, derived from its name.
    var id: String { name }
    
    /// The display name of the award.
    var name: String
    
    /// A brief description of what the award represents.
    var description: String
    
    /// The color associated with the award, stored as a string.
    var color: String
    
    /// The criteria for unlocking the award.
    var criterion: String
    
    /// The value required to unlock the award.
    var value: Int
    
    /// The system image name used for displaying the award icon.
    var image: String
    
    /// A static property that loads all awards from the `Awards.json` file in the app bundle.
    static let allAward: [Award] = Bundle.main.decode("Awards.json", as: [Award].self)
    
    /// A sample award used for previews and testing.
    static let example: Award = allAward[0]
}
