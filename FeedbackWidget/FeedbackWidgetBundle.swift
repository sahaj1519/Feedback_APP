//
//  FeedbackWidgetBundle.swift
//  FeedbackWidget
//
//  Created by Ajay Sangwan on 04/04/25.
//

import WidgetKit
import SwiftUI

@main
struct FeedbackWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleFeedbackWidget()
        ComplexFeedbackWidget()
    }
}
