//
//  FeedbackAppApp.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 27/03/25.
//
import CoreSpotlight
import SwiftUI

/// The main entry point of the Feedback App.
@main
struct FeedbackApp: App {
    
    /// The data controller responsible for managing Core Data operations.
    @StateObject var dataController = DataController()
    
    /// The current scene phase, used to detect app state changes.
    @Environment(\.scenePhase) var scenePhase
    
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.spotlightsearchissue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)  // Sidebar for navigation
            } content: {
                ContentView(dataController: dataController)  // Main content view
            } detail: {
                DetailView()  // Detail view for selected items
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) { newPhase, _ in
                if newPhase != .active {
                    dataController.saveChanges()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }
}
