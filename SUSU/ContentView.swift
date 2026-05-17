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

// MARK: - Popup Card Modifier

struct PopupCard<CardContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let maxWidth: CGFloat
    let maxHeight: CGFloat?
    @ViewBuilder let content: () -> CardContent

    func body(content outerContent: Content) -> some View {
        ZStack {
            outerContent
            if isPresented {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { isPresented = false } }
                    .transition(.opacity)

                VStack(spacing: 0) {
                    content()
                }
                .frame(maxWidth: maxWidth)
                .if(maxHeight != nil) { v in v.frame(maxHeight: maxHeight!) }
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.22), radius: 28, x: 0, y: 12)
                .padding(.horizontal, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.88, anchor: .center).combined(with: .opacity),
                    removal: .scale(scale: 0.88, anchor: .center).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isPresented)
    }
}

extension View {
    func popupCard<C: View>(isPresented: Binding<Bool>, maxWidth: CGFloat = 500, maxHeight: CGFloat? = nil, @ViewBuilder content: @escaping () -> C) -> some View {
        modifier(PopupCard(isPresented: isPresented, maxWidth: maxWidth, maxHeight: maxHeight, content: content))
    }
}

extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}
