//
//  UserFilterRow.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    var rename: (Filter) -> Void
    var deleteTagAnotherMethod: (Filter) -> Void
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssueCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    }label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteTagAnotherMethod(filter)
                    }label: {
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
    UserFilterRow(filter: .all, rename: {_ in }, deleteTagAnotherMethod: {_ in })
}
