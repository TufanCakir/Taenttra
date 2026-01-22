//
//  ChatSession.swift
//  Taenttara
//

import Foundation

struct ChatSession: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date

    init(title: String = "New Chat") {
        self.id = UUID()
        self.title = title
        self.messages = []
        self.createdAt = Date()
    }
}
