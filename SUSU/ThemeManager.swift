//
//  ThemeManager.swift
//  SUSU
//

import SwiftUI
import Combine

// MARK: - Theme Definition

struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let cardBackground: Color
    let textPrimary: Color
    let textSecondary: Color

    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool { lhs.id == rhs.id }
}

extension AppTheme {
    static let themes: [AppTheme] = [ocean, forest, sunset, royal, slate, rose]

    static let ocean = AppTheme(
        id: "ocean",
        name: "Ocean",
        primary: Color(hex: "#1B6CA8"),
        secondary: Color(hex: "#22B5BF"),
        accent: Color(hex: "#F0A500"),
        background: Color(hex: "#F0F5FA"),
        cardBackground: .white,
        textPrimary: Color(hex: "#0D1B2A"),
        textSecondary: Color(hex: "#5A7A8A")
    )

    static let forest = AppTheme(
        id: "forest",
        name: "Forest",
        primary: Color(hex: "#2D6A4F"),
        secondary: Color(hex: "#52B788"),
        accent: Color(hex: "#D4A017"),
        background: Color(hex: "#F2F7F4"),
        cardBackground: .white,
        textPrimary: Color(hex: "#1B2621"),
        textSecondary: Color(hex: "#4A7060")
    )

    static let sunset = AppTheme(
        id: "sunset",
        name: "Sunset",
        primary: Color(hex: "#C84B31"),
        secondary: Color(hex: "#F4845F"),
        accent: Color(hex: "#F7C948"),
        background: Color(hex: "#FDF5F0"),
        cardBackground: .white,
        textPrimary: Color(hex: "#2A1A14"),
        textSecondary: Color(hex: "#8A5A4A")
    )

    static let royal = AppTheme(
        id: "royal",
        name: "Royal",
        primary: Color(hex: "#4A2FBD"),
        secondary: Color(hex: "#7C5CBF"),
        accent: Color(hex: "#FFB703"),
        background: Color(hex: "#F5F3FF"),
        cardBackground: .white,
        textPrimary: Color(hex: "#1A1230"),
        textSecondary: Color(hex: "#6B5A8A")
    )

    static let slate = AppTheme(
        id: "slate",
        name: "Slate",
        primary: Color(hex: "#334155"),
        secondary: Color(hex: "#64748B"),
        accent: Color(hex: "#06B6D4"),
        background: Color(hex: "#F1F5F9"),
        cardBackground: .white,
        textPrimary: Color(hex: "#0F172A"),
        textSecondary: Color(hex: "#475569")
    )

    static let rose = AppTheme(
        id: "rose",
        name: "Rose",
        primary: Color(hex: "#BE185D"),
        secondary: Color(hex: "#EC4899"),
        accent: Color(hex: "#F59E0B"),
        background: Color(hex: "#FFF1F6"),
        cardBackground: .white,
        textPrimary: Color(hex: "#2D0A1A"),
        textSecondary: Color(hex: "#9D4E6E")
    )
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    @Published var current: AppTheme {
        didSet { UserDefaults.standard.set(current.id, forKey: "selectedThemeID") }
    }

    init() {
        let savedID = UserDefaults.standard.string(forKey: "selectedThemeID") ?? "ocean"
        current = AppTheme.themes.first(where: { $0.id == savedID }) ?? .ocean
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Environment Key

struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .ocean
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
