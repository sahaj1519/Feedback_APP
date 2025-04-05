//
//  ToolbarItemPlacement.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 05/04/25.
//

import SwiftUI

extension ToolbarItemPlacement {
    #if os(watchOS)
    static let automaticOrLeading = ToolbarItemPlacement.topBarLeading
    static let automaticOrTrailing = ToolbarItemPlacement.topBarTrailing
    #else
    static let automaticOrLeading = ToolbarItemPlacement.automatic
    static let automaticOrTrailing = ToolbarItemPlacement.automatic
    #endif
}

