//
//  MainTabView.swift
//  SUSU
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var appState = AppState()
    @State private var selectedTab = 0

    var theme: AppTheme { themeManager.current }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            GroupsView()
                .tabItem { Label("Groups", systemImage: "person.3.fill") }
                .tag(1)

            WalletView()
                .tabItem { Label("Wallet", systemImage: "wallet.bifold.fill") }
                .tag(2)

            ProposalsView()
                .tabItem { Label("Proposals", systemImage: "checkmark.seal.fill") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                .tag(4)
        }
        .tint(theme.primary)
        .environmentObject(appState)
        .environment(\.theme, theme)
    }
}
