//
//  ChatRow.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI

struct ChatRow: View {

    let chat: ChatSession
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {

            // Avatar / Initial
            Circle()
                .fill(avatarColor)
                .frame(width: 32, height: 32)
                .overlay {
                    Text(initial)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.primary)
                }

            // Title
            Text(chat.title)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)
                .foregroundStyle(isActive ? .primary : .secondary)

            Spacer(minLength: 8)

            // Active Indicator (cleaner than chevron)
            if isActive {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    isActive
                        ? Color.accentColor.opacity(0.14)
                        : Color.clear
                )
        )
        .animation(.easeOut(duration: 0.2), value: isActive)
    }

    // MARK: - Helpers

    private var initial: String {
        chat.title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(1)
            .uppercased()
    }

    private var avatarColor: Color {
        isActive
            ? Color.accentColor
            : Color.secondary.opacity(0.35)
    }
}
