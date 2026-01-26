//
//  EventView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct EventView: View {

    @ObservedObject var viewModel: EventViewModel
    let onStartEvent: (EventMode) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.events) { event in
                    Button {
                        viewModel.select(event)
                        onStartEvent(event)  // ✅ nur Intent
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)

                                Text("TIME: \(event.timeLimit)s")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("ENDS: \(event.expiresAt)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Events")
        }
    }
}
