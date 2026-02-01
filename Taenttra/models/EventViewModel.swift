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
    let modes: [EventCategory]

    init() {
        self.events = EventLoader.load().events
        self.modes = EventModeLoader.load()
    }

    func events(for mode: EventCategory) -> [EventMode] {
        events.filter { $0.type == mode.id }
    }
}
