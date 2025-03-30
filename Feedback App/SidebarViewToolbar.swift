//
//  SidebarViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @State private var isShowingAward = false
    
    var body: some View {
        Button {
            isShowingAward.toggle()
        }label: {
            Label("Show Awards", systemImage: "rosette")
        }
        .sheet(isPresented: $isShowingAward, content: AwardsView.init)
        
        Button(action: dataController.addNewTag) {
            Label("Add Tag", systemImage: "plus")
        }
    #if DEBUG
        Button {
            dataController.deleteAllData()
            dataController.createSampleData()
        }label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
    #endif
    }
}

#Preview {
    SidebarViewToolbar()
        .environmentObject(DataController(inMemory: true))
}
