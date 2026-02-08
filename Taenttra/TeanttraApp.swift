//
//  TaenttraApp.swift
//  Taenttra
//

import SwiftUI

@main
struct TaenttraApp: App {

    // MARK: - Hauptzustände und Manager
    @StateObject private var spiritGame = SpiritGameController()
    @StateObject private var musicManager = MusicManager()
    @StateObject private var internet = InternetMonitor()

    // MARK: - Singleton-Manager
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared
    @StateObject private var accountManager = AccountLevelManager.shared
    @StateObject private var giftManager = GiftManager.shared
    @StateObject private var dailyLoginManager = DailyLoginManager.shared
    @StateObject private var upgradeManager = UpgradeManager.shared
    @StateObject private var artefactInventoryManager = ArtefactInventoryManager
        .shared
    @StateObject private var questManager = QuestManager.shared
    @StateObject private var eventShopManager = EventShopManager.shared

    // MARK: - Init
    init() {
        ScreenFactory.shared.setGameController(spiritGame)
    }

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            rootView
                .environmentObject(spiritGame)
                .environmentObject(musicManager)
                .environmentObject(internet)
                .environmentObject(coinManager)
                .environmentObject(crystalManager)
                .environmentObject(accountManager)
                .environmentObject(giftManager)
                .environmentObject(dailyLoginManager)
                .environmentObject(upgradeManager)
                .environmentObject(artefactInventoryManager)
                .environmentObject(questManager)
                .environmentObject(eventShopManager)
                .onContinueUserActivity(
                    NSUserActivityTypeBrowsingWeb,
                    perform: handleActivity
                )
                .onAppear {
                    ScreenFactory.shared.setGameController(spiritGame)
                    GameCenterManager.shared.authenticate()
                    musicManager.configureAudioSession()
                }
        }
    }

    // MARK: - Root View
    @ViewBuilder
    private var rootView: some View {
        if internet.isConnected {
            WelcomeView()
        } else {
            OfflineScreen()
        }
    }

    // MARK: - Activity Handling (🔥 RAID ENTRY 🔥)
    private func handleActivity(_ activity: NSUserActivity) {
        guard
            let url = activity.webpageURL,
            let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            ),
            let activityID = components.queryItems?
                .first(where: { $0.name == "a" })?.value
        else { return }

        switch activityID {
        case "activity_malphas_abyss_raid":
            startMalphasRaid()
        default:
            break
        }
    }

    private func startMalphasRaid() {
        guard
            let raid = EventLoader.event(id: "event_malphas_abyss_raid"),
            raid.isActive
        else {
            print("⏰ Raid ist aktuell nicht aktiv")
            return
        }

        spiritGame.startEvent(raid)
        print("🔥 Malphas Abyss Raid gestartet")
    }
}
