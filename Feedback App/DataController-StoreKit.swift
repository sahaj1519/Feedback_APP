//
//  Datacontroller-StoreKit.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 02/04/25.
//

import Foundation
import StoreKit

extension DataController {
    
    /// The product identifier for unlocking the premium version of the app.
    static let unlockPremiumProductID = "Portfolio.FeedbackApp.premiumUnlock"
    
    /**
     A computed property that represents whether the full version of the app is unlocked.
     
     This property gets and sets a Boolean value in `UserDefaults` under the key `"fullVersionUnlocked"`.
     
     - Note: When set to `true`, the app is considered to be in full version mode.
     */
    var fullVersionUnlocked: Bool {
        get { defaults.bool(forKey: "fullVersionUnlocked") }
        set { defaults.set(newValue, forKey: "fullVersionUnlocked") }
    }
    
    /**
     Monitors the current transactions and transaction updates from StoreKit.#imageLiteral(resourceName: "simulator_screenshot_7C79F65F-7DA1-470B-8741-CEEDA4F98C1F.png")
     #imageLiteral(resourceName: "simulator_screenshot_FB63A94A-0D5D-49BB-B3D2-DB4B17E1EA8B.png")
     This asynchronous method listens for:
     
     - Current entitlements: It iterates over `Transaction.currentEntitlements` to finalize any verified transactions.
     - Transaction updates: It iterates over `Transaction.updates` and
       finalizes new transactions when they are received.
     
     Finalization involves calling the `finalize(_:)` method on any valid transaction.
     */
    func monitorTransaction() async {
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }
        
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }
    
    
    /**
     Finalizes a completed transaction.
     
     This method is executed on the main actor and performs the following actions:
     
     - Checks if the transaction's product identifier matches the premium unlock product.
     - Updates the `fullVersionUnlocked` property based on the transaction's revocation status.
     - Sends a change notification to update any dependent UI.
     - Finishes the transaction by calling `transaction.finish()`.
     
     - Parameter transaction: The `Transaction` object to be finalized.
     */
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == DataController.unlockPremiumProductID {
            objectWillChange.send()
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }
    
    /**
     Loads the available in-app purchase products.
     
     This method is executed on the main actor and:
     
     - Checks if the `products` array is already populated. If so, it returns immediately to avoid redundant loading.
     - Waits for 2.2 seconds before attempting to load products
       (possibly to simulate a delay or wait for a UI transition).
     - Loads the products using StoreKit's `Product.products(for:)` method with the premium unlock product identifier.
     
     - Throws: An error if the product loading fails.
     */
    @MainActor
    func loadProducts() async throws {
        // Don't load products more than once
        guard products.isEmpty else { return }

        try await Task.sleep(for: .seconds(2.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
