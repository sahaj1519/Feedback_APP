//
//  InlineNavigationBar.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 05/04/25.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
