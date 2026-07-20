//
//  IslandSavedPhotoViewerView.swift
//  Island Base
//
//  保存したダイヤ写真を全画面表示し、下にメモを入力できる
//

import SwiftUI

struct IslandSavedPhotoViewerView: View {
    let photo: IslandSavedPhoto
    let store: IslandSavedPhotoStore

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @Environment(\.dismiss) private var dismiss

    @State private var noteText: String = ""
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                photoContent
                memoEditor
            }
            .background(palette.cardBackground.ignoresSafeArea())
            .navigationTitle(formattedDate(photo.createdAt))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        saveNoteIfNeeded()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        store.deletePhoto(photo)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("写真メモを削除")
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(languageStore.t(.photoMemoDone)) {
                        isNoteFocused = false
                        saveNoteIfNeeded()
                    }
                }
            }
            .onAppear {
                noteText = photo.note
            }
            .onDisappear {
                saveNoteIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let image = store.image(for: photo) {
            ScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            ContentUnavailableView(
                "写真を開けません",
                systemImage: "photo",
                description: Text("保存データが見つかりませんでした")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var memoEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.photoMemoLabel))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(palette.text)

            TextField(
                languageStore.t(.photoMemoPlaceholder),
                text: $noteText,
                axis: .vertical
            )
            .lineLimit(3...8)
            .textFieldStyle(.plain)
            .padding(12)
            .foregroundStyle(palette.text)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.chipBackground(isSelected: false))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(palette.cardBorder, lineWidth: 1)
            }
            .focused($isNoteFocused)
            .onChange(of: isNoteFocused) { _, focused in
                if focused == false {
                    saveNoteIfNeeded()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.cardBackground)
    }

    private func saveNoteIfNeeded() {
        store.updateNote(noteText, for: photo)
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
