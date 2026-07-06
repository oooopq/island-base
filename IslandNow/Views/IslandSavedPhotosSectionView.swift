//
//  IslandSavedPhotosSectionView.swift
//  Island Now
//
//  港や案内所で撮影したダイヤ写真を、端末内だけに保存して表示する
//

import PhotosUI
import SwiftUI

struct IslandSavedPhotosSectionView: View {
    let islandID: String

    @Bindable var store: IslandSavedPhotoStore

    @Environment(\.detailPalette) private var palette
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var viewingPhoto: IslandSavedPhoto?
    @State private var cameraUnavailableMessage: String?
    @State private var showingPhotoLimitAlert = false

    private let thumbnailHeight: CGFloat = 90
    private let gridSpacing: CGFloat = 8

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: gridSpacing),
            count: 3
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("写真メモ")
                .font(.headline)

            Text("港や案内所で撮影した時刻表・案内を、この端末内だけに保存できます。各島あたり最大\(IslandSavedPhotoStore.maxPhotosPerIsland)枚まで。サムネイルをタップするとすぐ表示されます。")
                .font(.caption)
                .detailCardSecondaryText()

            photoCountLabel

            addPhotoButtons

            if store.photos.isEmpty {
                emptyState
            } else {
                photoGrid
            }
        }
        .detailSectionCard()
        .task(id: islandID) {
            store.loadPhotos(for: islandID)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await importPhoto(from: newItem)
                selectedPhotoItem = nil
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraImagePicker { image in
                addPhoto(image)
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(item: $viewingPhoto) { photo in
            IslandSavedPhotoViewerView(photo: photo, store: store)
        }
        .alert("カメラを使えません", isPresented: showCameraAlertBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(cameraUnavailableMessage ?? "この端末ではカメラ撮影が利用できません。")
        }
        .alert("保存上限に達しました", isPresented: $showingPhotoLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("この島の写真メモは\(IslandSavedPhotoStore.maxPhotosPerIsland)枚までです。不要な写真を削除すると追加できます。")
        }
    }

    private var photoCountLabel: some View {
        Text("\(store.photos.count)/\(IslandSavedPhotoStore.maxPhotosPerIsland)枚")
            .font(.caption)
            .fontWeight(.medium)
            .detailCardSecondaryText()
    }

    private var addPhotoButtons: some View {
        HStack(spacing: 10) {
            Button {
                openCamera()
            } label: {
                Label("撮影", systemImage: "camera.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(palette.accent)
            .disabled(store.canAddPhoto == false)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("写真を選ぶ", systemImage: "photo.on.rectangle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .disabled(store.canAddPhoto == false)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.viewfinder")
                .font(.largeTitle)
                .foregroundStyle(palette.secondaryText)

            Text("まだ写真メモがありません")
                .font(.subheadline)
                .detailCardSecondaryText()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var photoGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
            ForEach(store.photos) { photo in
                photoThumbnail(photo)
            }
        }
    }

    @ViewBuilder
    private func photoThumbnail(_ photo: IslandSavedPhoto) -> some View {
        Button {
            viewingPhoto = photo
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                if let image = store.image(for: photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: thumbnailHeight)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.chipBackground(isSelected: false))
                        .frame(height: thumbnailHeight)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(palette.secondaryText)
                        }
                }

                Text(formattedDate(photo.createdAt))
                    .font(.caption2)
                    .detailCardSecondaryText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(palette.cardBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(formattedDate(photo.createdAt))の写真メモ")
    }

    private var showCameraAlertBinding: Binding<Bool> {
        Binding(
            get: { cameraUnavailableMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    cameraUnavailableMessage = nil
                }
            }
        )
    }

    private func openCamera() {
        guard store.canAddPhoto else {
            showingPhotoLimitAlert = true
            return
        }

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraUnavailableMessage = "カメラがない端末、またはシミュレーターでは撮影できません。"
            return
        }
        showingCamera = true
    }

    private func importPhoto(from item: PhotosPickerItem) async {
        guard store.canAddPhoto else {
            showingPhotoLimitAlert = true
            return
        }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            return
        }
        addPhoto(image)
    }

    private func addPhoto(_ image: UIImage) {
        let added = store.addPhoto(image, for: islandID)
        if added == false {
            showingPhotoLimitAlert = true
        }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}

#Preview {
    IslandSavedPhotosSectionView(
        islandID: "ishigaki",
        store: IslandSavedPhotoStore()
    )
    .padding()
    .environment(\.detailPalette, DetailCardPalette.dark)
}
