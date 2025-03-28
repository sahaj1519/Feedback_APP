//
//  DetailView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//
import CoreData
import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        VStack{
            if let issue = dataController.selectedIssue{
                DetailViewWithIssue(issue: issue)
            }else{
                DetailViewNoIssue()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
        .environmentObject(DataController.preview)
}
