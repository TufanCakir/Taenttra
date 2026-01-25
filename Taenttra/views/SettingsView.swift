//
//  SettingsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {

                // MARK: - About
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Game")
                        Spacer()
                        Text("TAENTTRA")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(appBuild)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Tufan Cakir")
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Info
                Section(header: Text("INFO")) {
                    NavigationLink("Credits") {
                        CreditsView()
                    }

                    NavigationLink("Licenses") {
                        LicensesView()
                    }
                }

                // MARK: - System
                Section(header: Text("SYSTEM")) {
                    HStack {
                        Text("Platform")
                        Spacer()
                        Text(platformName)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("OS Version")
                        Spacer()
                        Text(osVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Options")
        }
    }

    // MARK: - App Info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var platformName: String {
        #if os(iOS)
            return "iOS"
        #elseif os(macOS)
            return "macOS"
        #else
            return "Unknown"
        #endif
    }

    private var osVersion: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }
}
