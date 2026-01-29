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
                        onStartEvent(event)
                    } label: {
                        EventRow(event: event)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())  // 🔥 volle Breite
                    .padding(.vertical, 6)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle("Events")
    }
}
