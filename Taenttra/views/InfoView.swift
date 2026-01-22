//
//  InfoView.swift
//  Teanttra
//

import SwiftUI

struct InfoView: View {

    @AppStorage("language")
    private var language =
        Locale.current.language.languageCode?.identifier ?? "en"

    private var content: InfoContent {
        Bundle.main.loadKhioneInfo(language: language)
    }

    var body: some View {
        List {
            headerSection

            ForEach(content.sections) { section in
                infoSection(section)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(content.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        Section {
            VStack(spacing: 8) {
                Image("taenttra_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.thinMaterial)
                    )

                Text(content.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private func infoSection(_ section: InfoSection) -> some View {
        Section(section.title) {
            Text(section.text)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    InfoView()
}
