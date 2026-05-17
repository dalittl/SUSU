//
//  SUSUApp.swift
//  SUSU
//
//  Created by Dante Little on 5/17/26.
//

import SwiftUI

@main
struct SUSUApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeManager)
                .environment(\.theme, themeManager.current)
        }
    }
}
