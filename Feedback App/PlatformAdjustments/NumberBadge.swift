//
//  NumberBadge.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 05/04/25.
//

import SwiftUI

extension View {
    func NumberBadge(_ number: Int) -> some View {
        #if os(watchOS)
           self
        #else
        self.badge(number)
        #endif
    }
}
