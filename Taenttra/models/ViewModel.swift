//
//  ViewModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import Combine
import Foundation
import FoundationModels
import UIKit

@MainActor
final class ViewModel: ObservableObject {

    // MARK: - UI State
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isProcessing = false
    @Published var errorMessage: String?

    // MARK: - Modes
    @Published private(set) var modes: [Mode] = Bundle.main
        .loadModes()
    @Published private(set) var selectedMode: Mode?

    @Published var selectedReplyStyle: ReplyStyle?

    // MARK: - Model
    private let model = SystemLanguageModel.default
    private var currentTask: Task<Void, Never>?

    var onMessagesChanged: (([ChatMessage]) -> Void)?

    init() {
        modes = Bundle.main.loadModes()
        selectedMode = modes.first
        onMessagesChanged?(messages)

        if let modeID = UserDefaults.standard.string(
            forKey: "start_mode"
        ),
            let mode = modes.first(where: { $0.id == modeID })
        {
            selectedMode = mode
            UserDefaults.standard.removeObject(forKey: "start_mode")
        }
    }

    var greeting: Greeting {
        GreetingManager.randomGreeting()
    }

    // MARK: - Mode Handling
    func setMode(_ mode: Mode) {
        guard selectedMode?.id != mode.id else { return }
        selectedMode = mode
        reset()
    }

    func setModeByID(_ id: String) {
        guard let mode = modes.first(where: { $0.id == id }) else { return }
        setMode(mode)
    }

    // MARK: - Public API
    func send(text: String, image: UIImage?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let finalText: String
        if image != nil && trimmed.isEmpty {
            finalText = "The user attached an image but did not describe it."
        } else {
            finalText = trimmed
        }

        guard !finalText.isEmpty else { return }

        cancelCurrentTask()
        appendUserMessage(text: finalText, image: image)
        isProcessing = true

        currentTask = Task { [weak self] in
            await self?.generateResponse()
        }
    }

    func removeGreetingIfNeeded() {
        messages.removeAll { $0.kind == .greeting }
    }

    func loadMessages(_ newMessages: [ChatMessage]) {
        messages = newMessages
    }

    func reset() {
        messages.removeAll()
    }

    func cancel() {
        cancelCurrentTask()
        isProcessing = false
    }

    private func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }

    // MARK: - Core Logic
    private func generateResponse() async {
        guard model.isAvailable else {
            handleError("Language model not available.")
            return
        }

        let prompt = buildPrompt()

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            guard !Task.isCancelled else { return }

            appendAssistantMessage(
                response.content.isEmpty ? "…" : response.content
            )
        } catch {
            handleError(error.localizedDescription)
        }

        isProcessing = false
    }

    // MARK: - Prompt Builder
    private func buildPrompt() -> String {
        let system = systemPrompt()

        let history =
            messages
            .dropLast()
            .suffix(12)
            .compactMap { msg in
                guard let text = msg.text else { return nil }
                return "\(msg.role == .user ? "User" : "Assistant"):\n\(text)"
            }
            .joined(separator: "\n\n")

        let currentUser =
            messages.last?.text.map {
                "User:\n\($0)"
            } ?? ""

        return [
            system,
            history,
            currentUser,
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "\n\n")
    }

    private func conversationHistoryWithoutLastUser() -> String {
        messages
            .dropLast()
            .suffix(16)
            .map { msg in
                "\(msg.role == .user ? "User" : "Assistant"):\n\(msg.text ?? "")"
            }
            .joined(separator: "\n\n")
    }

    private func currentUserPrompt() -> String {
        guard let last = messages.last, last.role == .user else { return "" }
        return """
            User:
            \(last.text ?? "")
            """
    }

    private func conversationHistory() -> String {
        messages.suffix(16).map {
            "\( $0.role == .user ? "User" : "Assistant"):\n\($0.text ?? "")"
        }.joined(separator: "\n\n")
    }

    private func systemPrompt() -> String {
        var prompt = """
            System:
            You are Taenttra, an on-device AI assistant.
            You run locally and prioritize clarity, correctness, and efficiency.
            Always respond in the user's language.

            Core behavior:
            - Be calm, precise, and natural.
            - No marketing language. No filler phrases.
            - Answer directly. Explain only what is necessary.
            - Prefer accuracy over verbosity.

            Response strategy:
            - For code, architecture, or implementation: respond technically and precisely.
              Use Markdown code blocks for all code.
            - For bugs or errors: identify the likely cause, then give concrete steps to fix it.
            - For explanations: explain step by step with clear structure.
            - For decisions or comparisons: weigh options objectively and give a clear recommendation.
            - For creative requests: generate original ideas, but keep them structured.

            Constraints:
            - Do not invent facts.
            - Do not assume missing information.
            - Ask a short clarifying question only if absolutely required.

            Accessibility:
            - If the user uses simple language or appears to need assistance,
              use short sentences and clear structure.

            """

        if let mode = selectedMode?.systemPrompt {
            prompt += "\nMODE:\n\(mode)"
        }

        if let style = selectedReplyStyle?.prompt {
            prompt += "\n\nREPLY STYLE:\n\(style)"
        }

        return prompt
    }

    // MARK: - Message Handling
    private func appendUserMessage(text: String, image: UIImage?) {
        messages.append(ChatMessage(role: .user, text: text, image: image))
        onMessagesChanged?(messages)
    }

    private func appendAssistantMessage(_ text: String) {
        messages.append(ChatMessage(role: .assistant, text: text))
        onMessagesChanged?(messages)
    }

    private func handleError(_ message: String) {
        errorMessage = message
        isProcessing = false
    }
}
