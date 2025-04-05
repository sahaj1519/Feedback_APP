//
//  DataController-Testing.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 05/04/25.
//

import SwiftUI

extension DataController {
    func checkForTestEnvironment() {
        
        // If running in test mode, delete all existing data and disable animations
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            self.deleteAllData()
            #if os(iOS)
            UIView.setAnimationsEnabled(false)
            #endif
        }
        #endif
    }
}
