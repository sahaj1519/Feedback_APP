//
//  ContentViewRowWatch.swift
//  UPAWatch Watch App
//
//  Created by Ajay Sangwan on 05/04/25.
//

import SwiftUI

struct ContentViewRowWatch: View {
    @EnvironmentObject var dataController: DataController
        @ObservedObject var issue: Issue

        var body: some View {
            NavigationLink(value: issue) {
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)
                }
                .foregroundStyle(issue.isCompleted ? .secondary : .primary)
            }
        }
}

#Preview {
    ContentViewRowWatch(issue: .example)
}
