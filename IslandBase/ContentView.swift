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
    @State private var navigationPath = NavigationPath()
    @State private var showsToolbarHint = false
    @State private var didScheduleToolbarHint = false
    @State private var showsLaunchSplash = true

    var body: some View {
        NavigationStack(path: $navigationPath) {
            RegionHomeView()
        }
        .environment(\.popToHome, { popToHome() })
        .environment(\.navigateToRegion, { regionID in
            navigationPath.append(regionID)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea())
        .environment(themeStore)
        .environment(languageStore)
        .environment(lastSelectedIslandStore)
        .environment(\.detailPalette, themeStore.palette)
        .preferredColorScheme(themeStore.colorScheme)
        .overlay {
            if showsLaunchSplash {
                LaunchSplashOverlayView(onFinished: handleSplashFinished)
            }
        }
        .sheet(isPresented: $showsToolbarHint, onDismiss: {
            themeStore.markToolbarHintShown()
        }) {
            ThemeToggleHintView(
                mode: themeStore.mode,
                palette: themeStore.palette
            )
            .environment(languageStore)
            .environment(\.detailPalette, themeStore.palette)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    /// スプラッシュ終了後に初回ヒントを出す（ループ待ちはしない）
    private func handleSplashFinished() {
        showsLaunchSplash = false
        Task { await presentToolbarHintIfNeeded() }
    }

    @MainActor
    private func presentToolbarHintIfNeeded() async {
        guard didScheduleToolbarHint == false else { return }
        guard themeStore.shouldShowToolbarHint else { return }

        didScheduleToolbarHint = true

        // NavigationStack の初回レイアウト後に sheet を出す（onAppear だけだと出ないことがある）
        try? await Task.sleep(for: .milliseconds(400))
        guard themeStore.shouldShowToolbarHint else { return }
        showsToolbarHint = true
    }

    private func popToHome() {
        withAnimation {
            navigationPath = NavigationPath()
        }
    }
}

#Preview {
    ContentView()
}
