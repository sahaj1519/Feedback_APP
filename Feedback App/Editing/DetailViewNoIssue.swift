//
//  DetailViewNoIssue.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//

import CoreData
import SwiftUI

/// A placeholder view displayed when no issue is selected.
struct DetailViewNoIssue: View {
    
    /// The shared data controller responsible for managing app data.
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            // Display message when no issue is selected
            Text("No Issue Selected")
                .font(.title)
                .foregroundStyle(.secondary)
            
            // Button to create a new issue
            Button("New Issue", action: dataController.addNewIssue)
        }
        .padding()
    }
}

#Preview {
    DetailViewNoIssue()
        .environmentObject(DataController.preview)
}
