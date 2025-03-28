//
//  Feedback_AppApp.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//

import SwiftUI

@main
struct Feedback_AppApp: App {
    @StateObject  var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView{
                SidebarView()
            }content: {
                ContentView()
            }detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
