//
//  UserFilterRow.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A row view that represents a user-defined filter in the navigation list.
/// It provides options to rename or delete the filter via a context menu.
struct UserFilterRow: View {
    
    /// The filter represented by this row.
    var filter: Filter
    
    /// A closure that handles renaming the filter.
    var rename: (Filter) -> Void
    
    /// A closure that handles deleting the filter.
    var deleteTagAnotherMethod: (Filter) -> Void
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssueCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteTagAnotherMethod(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.activeIssueCount) issues")
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in }, deleteTagAnotherMethod: { _ in })
}
