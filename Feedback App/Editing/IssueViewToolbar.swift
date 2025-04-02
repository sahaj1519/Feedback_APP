//
//  IssueViewToolbar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 30/03/25.
//

import CoreHaptics
import SwiftUI

/// A toolbar menu for managing an issue, providing actions such as copying the issue title
/// and toggling its completion status.
///
/// This view includes an action menu that allows users to:
/// - Copy the issue title to the clipboard.
/// - Mark an issue as completed or re-open a closed issue.
/// - Provide haptic feedback when toggling an issue's completion status.
///
/// ## Topics
/// - `@EnvironmentObject`: Uses `DataController` to manage data persistence.
/// - `@ObservedObject`: Observes `Issue` to reflect real-time changes.
/// - Haptic feedback using `CoreHaptics`.
///
/// ## Example Usage:
/// ```swift
/// IssueViewToolbar(issue: Issue.example)
///     .environmentObject(DataController(inMemory: true))
/// ```
///
/// ## Dependencies:
/// - `DataController`: Manages app-wide data storage.
/// - `Issue`: Represents an issue with attributes such as title and completion status.
struct IssueViewToolbar: View {
    
    /// The shared data controller for managing application data.
    @EnvironmentObject var dataController: DataController
    
    /// The issue being displayed and managed in the toolbar.
    @ObservedObject var issue: Issue
    
    /// The haptic engine for generating feedback effects.
    @State private var engine = try? CHHapticEngine()
    
    /// Determines the text for the open/close issue button based on its completion status.
    var openCloseButtonText: String {
        issue.isCompleted ? "Re-open Issue" : "Close Issue"
    }
    
    /// Toggles the completion status of the issue and triggers haptic feedback.
    ///
    /// When toggled, the function:
    /// 1. Updates the `isCompleted` property of `issue`.
    /// 2. Saves the change using `dataController.saveChanges()`.
    /// 3. Attempts to generate a haptic feedback pattern.
    func toggleIsCompleted() {
            // Toggle the issue's completion status
            issue.isCompleted.toggle()
            
            // Save the updated status to persistent storage
            dataController.saveChanges()
            
            do {
                // Start the haptic engine if not already running
                try engine?.start()
                
                // Define haptic feedback parameters
                
                // Sharpness parameter controls the "crispness" of the feedback
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                
                // Intensity parameter determines the strength of the feedback
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                
                // Create a parameter curve that fades intensity from full to zero over time
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1) // Full intensity at start
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)   // No intensity at end
                
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )
                
                // Define a transient haptic event (quick tap-like feedback)
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [sharpness, intensity],
                    relativeTime: 0 // Occurs immediately
                )
                
                // Define a continuous haptic event (a short vibration that fades out)
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0,  // Starts immediately
                    duration: 1        // Lasts for 1 second
                )
                
                // Create a haptic pattern using both events and the parameter curve
                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                
                // Create a player to execute the haptic pattern
                let player = try engine?.makePlayer(with: pattern)
                
                // Start playing the haptic feedback immediately
                try player?.start(atTime: 0)
                
            } catch {
                // Haptic feedback failed, but we can safely ignore the error
                // This ensures the app does not crash if the device does not support haptics
            }
        }
    /// The body of the toolbar view, displaying a menu with available actions.
    ///
    /// The menu includes:
    /// - **Copy Issue Title:** Copies the issue title to the clipboard.
    /// - **Toggle Completion Status:** Marks the issue as completed or re-opens it.
    var body: some View {
        Menu {
            // Button to copy the issue title to the clipboard
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }
            
            // Button to toggle issue completion status and save the change
            Button {
               toggleIsCompleted()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
        .environmentObject(DataController(inMemory: true))
}
