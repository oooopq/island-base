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
    @State private var fullImage: UIImage?
    @State private var didFinishLoadingFullImage = false
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                photoContent
                    .layoutPriority(1)
                memoEditor
            }
            .background(palette.cardBackground.ignoresSafeArea())
            .navigationTitle(formattedDate(photo.createdAt))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(languageStore.t(.close)) {
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
                    .accessibilityLabel(languageStore.t(.deletePhotoMemo))
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
            .task(id: photo.id) {
                didFinishLoadingFullImage = false
                fullImage = await store.fullImage(for: photo)
                didFinishLoadingFullImage = true
            }
            .onDisappear {
                saveNoteIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let fullImage {
            GeometryReader { proxy in
                ZoomableImageView(image: fullImage)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 8)
            .clipped()
            .accessibilityLabel(languageStore.t(.photoMemoLabel))
            .accessibilityHint(languageStore.t(.photoMemoZoomHint))
        } else if didFinishLoadingFullImage {
            ContentUnavailableView(
                languageStore.t(.photoCannotOpen),
                systemImage: "photo",
                description: Text(languageStore.t(.photoDataNotFound))
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProgressView()
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
