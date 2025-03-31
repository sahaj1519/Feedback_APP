//
//  SmartFilterRow.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A row view that represents a smart filter in the navigation list.
/// It provides a navigation link to the corresponding filter's details.
struct SmartFilterRow: View {
    
    /// The filter represented by this row.
    var filter: Filter
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
        }
    }
}

#Preview {
    SmartFilterRow(filter: .all)
}
