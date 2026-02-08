//
//  Sidebar.swift
//  Taenttra
//
//  Created by Tufan Cakir on 07.02.26.
//

import SwiftUI

struct Sidebar: View {

    @ObservedObject var store: ChatStore
    var onOpenChat: (() -> Void)?

    @State private var renamingChat: ChatSession?
    @State private var renameText = ""

    var body: some View {
        List {
            Section {
                ForEach(store.sessions) { chat in
                    ChatRow(
                        chat: chat,
                        isActive: store.activeID == chat.id
                    )
                    .onTapGesture {
                        store.activeID = chat.id
                        onOpenChat?()
                    }
                    .contextMenu {
                        renameButton(for: chat)
                        deleteButton(for: chat)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
                    )
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .sheet(item: $renamingChat) { chat in
            renameSheet(for: chat)
        }
    }

    // MARK: - Context Menu Actions

    private func renameButton(for chat: ChatSession) -> some View {
        Button {
            renamingChat = chat
            renameText = chat.title
        } label: {
            Label("Rename", systemImage: "pencil")
        }
    }

    private func deleteButton(for chat: ChatSession) -> some View {
        Button(role: .destructive) {
            store.delete(chat)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Rename Sheet

    private func renameSheet(for chat: ChatSession) -> some View {
        NavigationStack {
            Form {
                TextField("Chat name", text: $renameText)
            }
            .navigationTitle("Rename Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        renamingChat = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.rename(chat, to: renameText)
                        renamingChat = nil
                    }
                    .disabled(
                        renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }

    // MARK: - List Actions

    private func delete(at offsets: IndexSet) {
        store.deleteChats(at: offsets)
    }

    private func move(from source: IndexSet, to destination: Int) {
        store.moveChats(from: source, to: destination)
    }
}

