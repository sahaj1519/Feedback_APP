//
//  AwardsView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 29/03/25.
//

import SwiftUI

/// `AwardsView` displays a collection of awards,
///  indicating which ones have been unlocked by the user.
/// Users can tap an award to view additional details in an alert.
struct AwardsView: View {
    /// Accesses the shared `DataController` instance to check award status.
    @EnvironmentObject var dataController: DataController
    
    /// Stores the currently selected award when tapped.
    @State private var selectedAward = Award.example
    
    /// Controls the visibility of the award details alert.
    @State private var isAlertShowingAwardDetails = false
    
    /// Defines the layout for the grid of awards, making them adapt to different screen sizes.
    var coloumns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    
    /// Returns the title for the award detail alert,
    /// showing whether the award is unlocked or still locked.
    var alertTitle: LocalizedStringKey {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }
    
    /// Determines the color of the award icon
    ///  based on whether it has been earned or not.
    /// - Parameter award: The award to check.
    /// - Returns: The color indicating its status.
    /// Earned awards appear in their assigned color;
    /// locked awards are grayed out.
    func awardColor(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }
    
    /// Provides a localized accessibility label for each award.
    /// - Parameter award: The award to describe.
    /// - Returns: A string indicating whether the award is unlocked or still locked.
    func awardLabel(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: coloumns) {
                    ForEach(Award.allAward) { item in
                        Button {
                            /// When an award is tapped, store it in `selectedAward`
                            /// and display its details in an alert.
                            selectedAward = item
                            isAlertShowingAwardDetails = true
                        } label: {
                            Image(systemName: item.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(awardColor(for: item))
                        }
                        .accessibilityLabel(awardLabel(for: item))
                        .accessibilityHint(item.description)
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(alertTitle, isPresented: $isAlertShowingAwardDetails) {
        } message: {
            /// Displays the description of the selected award in the alert.
            Text(selectedAward.description)
        }
    }
}

#Preview {
    AwardsView()
}
