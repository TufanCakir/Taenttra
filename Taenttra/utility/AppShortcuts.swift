//
//  AppShortcuts.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import AppIntents

struct TaenttraAppShortcuts: AppShortcutsProvider {

    static var shortcutTileColor: ShortcutTileColor { .purple }

    @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenTaenttraIntent(),
            phrases: [
                "Open ${applicationName}",
                "Start ${applicationName}",
                "Launch ${applicationName}",
            ],
            shortTitle: "Open Taenttra",
            systemImageName: "sparkles"
        )

        AppShortcut(
            intent: OpenTaenttraModeIntent(mode: .chat),
            phrases: [
                "Open ${applicationName} chat",
                "Chat with ${applicationName}",
            ],
            shortTitle: "Taenttra Chat",
            systemImageName: "message"
        )

        AppShortcut(
            intent: OpenTaenttraModeIntent(mode: .accessibility),
            phrases: [
                "Open ${applicationName} accessibility",
                "Use ${applicationName} with accessibility",
            ],
            shortTitle: "Taenttra Accessibility",
            systemImageName: "figure.roll"
        )
    }
}

// MARK: - Mode Enum

enum ModeIntent: String, AppEnum {
    case chat
    case accessibility

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Taenttra Mode")
    }

    static var caseDisplayRepresentations: [ModeIntent: DisplayRepresentation] {
        [
            .chat: "Chat",
            .accessibility: "Accessibility",
        ]
    }
}

// MARK: - Open App Intent

struct OpenTaenttraIntent: AppIntent {

    static var title: LocalizedStringResource = "Open Taenttra"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

// MARK: - Open Mode Intent

struct OpenTaenttraModeIntent: AppIntent {

    static var title: LocalizedStringResource =
        "Open Taenttra in a specific mode"

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Mode")
    var mode: ModeIntent

    init() {
        self.mode = .chat
    }

    init(mode: ModeIntent) {
        self.mode = mode
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(
            mode.rawValue,
            forKey: "start_mode"
        )
        return .result()
    }
}
