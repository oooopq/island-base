//
//  ContentView.swift
//  Island Base
//
//  アプリの最初の画面
//

import SwiftUI

struct ContentView: View {
    @State private var themeStore = AppThemeStore()
    @State private var languageStore = AppLanguageStore()
    @State private var lastSelectedIslandStore = LastSelectedIslandStore()
    @State private var showsToolbarHint = false
    @State private var didScheduleToolbarHint = false

    var body: some View {
        NavigationStack {
            RegionHomeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea())
        .environment(themeStore)
        .environment(languageStore)
        .environment(lastSelectedIslandStore)
        .environment(\.detailPalette, themeStore.palette)
        .preferredColorScheme(themeStore.colorScheme)
        .task {
            await presentToolbarHintIfNeeded()
        }
        .sheet(isPresented: $showsToolbarHint, onDismiss: {
            themeStore.markToolbarHintShown()
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
    private func presentToolbarHintIfNeeded() async {
        guard didScheduleToolbarHint == false else { return }
        guard themeStore.shouldShowToolbarHint else { return }

        didScheduleToolbarHint = true

        // NavigationStack の初回レイアウト後に sheet を出す（onAppear だけだと出ないことがある）
        try? await Task.sleep(for: .milliseconds(500))
        guard themeStore.shouldShowToolbarHint else { return }
        showsToolbarHint = true
    }
}

#Preview {
    ContentView()
}
