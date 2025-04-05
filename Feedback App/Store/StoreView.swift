//
//  StoreView.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 03/04/25.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    /// The shared data controller managing purchases and app state.
    @EnvironmentObject var dataController: DataController
    
    @Environment(\.purchase) var purchaseAction
    
    /// Dismiss action for closing the store view.
    @Environment(\.dismiss) var dismiss
   
    /// Enumeration to represent the different loading states of the store.
    enum LoadState {
        case loading, loaded, error
    }
    
    /// Tracks the current loading state of the store.
    @State private var loadState = LoadState.loading
    
    /// Indicates whether the user can make purchases.
    @State private var isCanPurchase = false
    
    /**
     Checks whether the full version has already been unlocked.
     
     If the user has previously unlocked the premium version, this function dismisses the store view.
     */
    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }
    
    /**
     Initiates the purchase process for a given product.
     
     - Parameter product: The `Product` object representing the item to be purchased.
     
     If in-app purchases are disabled, an alert is shown to notify the user.
     Otherwise, the purchase transaction is initiated using `dataController.purchase(_:)`.
     */
    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            isCanPurchase.toggle()
            return
        }
        Task { @MainActor in
           
            let result = try await purchaseAction(product)
            
            if case let .success(validation) = result {
                try await dataController.finalize(validation.payloadValue)
            }
        
        }
    }
    
    /**
     Loads available products from the App Store.
     
     - This function sets `loadState` to `.loading` before attempting to fetch products.
     - If the fetch is successful and products are available, `loadState` is set to `.loaded`.
     - If no products are found or an error occurs, `loadState` is set to `.error`.
     */
    func load() async {
        loadState = .loading

        do {
            try await dataController.loadProducts()

            if dataController.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
        }
    }
    
    /**
     Restores previously purchased items.
     
     This function calls `AppStore.sync()` to revalidate past transactions and restore purchases.
     */
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                /// Store header section with an image and text.
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()

                    Text("Upgrade Today!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Get the most out of the app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)

                /// Main content section with product listing or error messages.
                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            Text("Fetching offers…")
                                .font(.title2.bold())
                                .padding(.top, 50)

                            ProgressView()
                                .controlSize(.large)

                        case .loaded:
                            /// Display available products for purchase.
                            ForEach(dataController.products) { product in
                                Button {
                                    purchase(product)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.title2.bold())

                                            Text(product.description)
                                        }

                                        Spacer()

                                        Text(product.displayPrice)
                                            .font(.title)
                                            .fontDesign(.rounded)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }

                        case .error:
                            /// Display an error message when loading fails.
                            Text("Sorry, there was an error loading our store.")
                                .padding(.top, 50)

                            Button("Try Again") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }

                /// Restore purchases button.
                Button("Restore Purchases", action: restore)

                /// Cancel button to close the store view.
                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
        /// Alert shown when in-app purchases are disabled on the device.
        .alert("In-app purchases are disabled", isPresented: $isCanPurchase) {
        } message: {
            Text("""
            You can't purchase the premium unlock because in-app purchases are disabled on this device.

            Please ask whomever manages your device for assistance.
            """)
        }
        /// Observes changes in the `fullVersionUnlocked` property.
        /// If the user has unlocked premium, the store view is dismissed.
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
        /// Loads store data when the view appears.
        .task {
            await load()
        }
    }
}

#Preview {
    StoreView()
        .environmentObject(DataController.preview)
}
