//
//  AwardsView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 29/03/25.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    
    @State private var selectedAward = Award.example
    @State private var isAlertShowingAwardDetails = false
    
    var coloumns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    
    var alertTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }
    
    func awardColor(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }
    
    func awardLabel(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: coloumns) {
                    ForEach(Award.allAward) {item in
                        Button {
                            
                            selectedAward = item
                            isAlertShowingAwardDetails = true
                            
                        }label: {
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
        }message: {
            Text(selectedAward.description)
        }
    }
}

#Preview {
    AwardsView()
}
