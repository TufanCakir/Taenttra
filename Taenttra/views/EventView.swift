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
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.events) { event in
                        Button {
                            viewModel.select(event)
                            onStartEvent(event)
                        } label: {
                            EventRow(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
        }
        .navigationTitle("EVENTS")
        .navigationBarTitleDisplayMode(.inline)
    }
}
