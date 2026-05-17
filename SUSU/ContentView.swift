//
//  ContentView.swift
//  SUSU
//
//  Created by Dante Little on 5/17/26.
//

import SwiftUI

// ContentView is replaced by MainTabView as the app entry point.
// Kept for backward compatibility with Xcode preview infrastructure.
struct ContentView: View {
    var body: some View {
        MainTabView()
            .environmentObject(ThemeManager())
    }
}

#Preview {
    ContentView()
}
