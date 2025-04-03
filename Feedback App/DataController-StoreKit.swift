//
//  Datacontroller-StoreKit.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 02/04/25.
//

import Foundation
import StoreKit

extension DataController {
    static let unlockPremiumProductID = "Portfolio.FeedbackApp.premiumUnlock"
    
    var fullVersionUnlocked: Bool {
        get { defaults.bool(forKey: "fullVersionUnlocked") }
        set { defaults.set(newValue, forKey: "fullVersionUnlocked") }
    }
    
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
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }
    
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == DataController.unlockPremiumProductID {
            objectWillChange.send()
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }
    
    @MainActor
    func loadProducts() async throws {
        // don't load products more than once
        guard products.isEmpty else { return }

        try await Task.sleep(for: .seconds(2.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
