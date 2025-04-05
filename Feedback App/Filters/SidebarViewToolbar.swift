//
//  SidebarViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

/// A toolbar view for the sidebar, providing quick access to awards, tag creation, and sample data management.
struct SidebarViewToolbar: ToolbarContent {
    
    /// The shared data controller for managing application data.
    @EnvironmentObject var dataController: DataController
    
    /// A state variable that determines whether the awards sheet is displayed.
    @State private var isShowingAward = false
    @State private var isShowingStore = false
    
    func tryNewTag() {
        if dataController.addNewTag() == false {
            isShowingStore = true
        }
    }
    
    var body: some ToolbarContent {
        
        // Button to add a new tag using DataController's method
        ToolbarItem(placement: .automaticOrTrailing) {
            Button(action: tryNewTag) {
                Label("Add Tag", systemImage: "plus")
            }
            .help("Add Tag")
            .sheet(isPresented: $isShowingStore, content: StoreView.init)
        }
        
        // Button to toggle the Awards view
        ToolbarItem(placement: .automaticOrLeading) {
            Button {
                isShowingAward.toggle()
            } label: {
                Label("Show Awards", systemImage: "rosette")
            }
            .help("Show Awards")
            .sheet(isPresented: $isShowingAward, content: AwardsView.init)
        }
        
        // Debug-only button for deleting all data and creating sample data
//        ToolbarItem(placement: .automatic) {
//         #if DEBUG
//            Button {
//                dataController.deleteAllData()
//                dataController.createSampleData()
//            } label: {
//                Label("ADD SAMPLES", systemImage: "flame")
//            }
//         #endif
//        }
    }
}
