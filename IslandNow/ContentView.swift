//
//  ContentView.swift
//  Island Now
//
//  アプリの最初の画面
//

import SwiftUI

struct ContentView: View {
    @State private var themeStore = AppThemeStore()
    @State private var lastSelectedIslandStore = LastSelectedIslandStore()
    @State private var showsThemeHint = false
    @State private var didScheduleThemeHint = false

    var body: some View {
        NavigationStack {
            RegionHomeView()
        }
        .environment(themeStore)
        .environment(lastSelectedIslandStore)
        .environment(\.detailPalette, themeStore.palette)
        .preferredColorScheme(themeStore.colorScheme)
        .task {
            await presentThemeHintIfNeeded()
        }
        .sheet(isPresented: $showsThemeHint, onDismiss: {
            themeStore.markThemeHintShown()
        }) {
            ThemeToggleHintView(
                mode: themeStore.mode,
                palette: themeStore.palette
            )
            .environment(\.detailPalette, themeStore.palette)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    @MainActor
    private func presentThemeHintIfNeeded() async {
        guard didScheduleThemeHint == false else { return }
        guard themeStore.shouldShowThemeHint else { return }

        didScheduleThemeHint = true

        // NavigationStack の初回レイアウト後に sheet を出す（onAppear だけだと出ないことがある）
        try? await Task.sleep(for: .milliseconds(500))
        guard themeStore.shouldShowThemeHint else { return }
        showsThemeHint = true
    }
}

#Preview {
    ContentView()
}
