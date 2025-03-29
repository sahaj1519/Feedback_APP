//
//  DetailViewNoIssue.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 28/03/25.
//
import CoreData
import SwiftUI

struct DetailViewNoIssue: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue", action: dataController.addNewIssue)
    }
}

#Preview {
    DetailViewNoIssue()
        .environmentObject(DataController.preview)
}
