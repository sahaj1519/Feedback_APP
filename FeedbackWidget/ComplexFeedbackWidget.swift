//
//  ComplexFeedbackWidget.swift
//  FeedbackWidget
//
//  Created by Ajay Sangwan on 04/04/25.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: Date.now, issue: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: Date.now, issue: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = ComplexEntry(date: Date.now, issue: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 7)
        return dataController.results(for: request)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let issue: [Issue]
}

struct ComplexFeedbackWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var entry: ComplexProvider.Entry
    
    var issues: ArraySlice<Issue> {
        let issueCount: Int
        
        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemLarge, .systemExtraLarge:
            if dynamicTypeSize < .xxLarge {
                issueCount = 6
            } else {
                issueCount = 5
            }
        default:
            if dynamicTypeSize < .xLarge {
                issueCount = 3
            } else {
                issueCount = 2
            }
        }
        
        return entry.issue.prefix(issueCount)
    }
    

    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading) {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        
                        if issue.issueTag.isEmpty == false {
                            Text(issue.issueTagList)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct ComplexFeedbackWidget: Widget {
    let kind: String = "ComplexFeedbackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
            if #available(iOS 17.0, *) {
                ComplexFeedbackWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplexFeedbackWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    ComplexFeedbackWidget()
} timeline: {
    ComplexEntry(date: .now, issue: [.example])
    ComplexEntry(date: .now, issue: [.example])
}
