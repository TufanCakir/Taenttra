//
//  EventViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import Combine
import Foundation

final class EventViewModel: ObservableObject {

    @Published var events: [EventMode] = []
    @Published var selectedEvent: EventMode?

    init() {
        events = EventLoader.load().events
    }

    func select(_ event: EventMode) {
        selectedEvent = event
    }
}
