//
//  ProfileView.swift
//  SUSU
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.theme) var theme

    @State private var showThemePicker = false
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileHeader
                        yearInReview
                        themeSection
                        settingsSection
                        legalSection
                        Spacer(minLength: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Profile Header

    var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [theme.primary, theme.secondary],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)
                    .shadow(color: theme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
                Text("DL")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
            }

            Text("Dante Little")
                .font(.title2).bold()

            Text("Group Owner · Plus Member")
                .font(.caption)
                .foregroundColor(theme.primary)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(theme.primary.opacity(0.1))
                .cornerRadius(10)

            HStack(spacing: 0) {
                statItem(value: "\(appState.groups.count)", label: "Groups")
                Divider().frame(height: 30)
                statItem(value: appState.currentUser.totalContributed.asCurrency, label: "Contributed")
                Divider().frame(height: 30)
                statItem(value: appState.currentUser.totalDisbursed.asCurrency, label: "Disbursed")
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
        }
    }

    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.subheadline).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Year In Review

    var yearInReview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [theme.secondary.opacity(0.85), theme.primary],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: theme.primary.opacity(0.25), radius: 10, x: 0, y: 5)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎉 2026 In Review")
                        .font(.headline).bold().foregroundColor(.white)
                    Text("Your family pooled $4,200 and supported 14 family moments.")
                        .font(.subheadline).foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(18)
        }
    }

    // MARK: - Theme Section

    var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "App Appearance")
            Text("Choose a color palette")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(AppTheme.themes) { t in
                    ThemeChip(appTheme: t, isSelected: themeManager.current.id == t.id) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            themeManager.current = t
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Settings Section

    var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsToggleRow(icon: "bell.badge.fill", label: "Push Notifications",
                              color: theme.primary, isOn: $notificationsEnabled)
            Divider().padding(.leading, 52)
            SettingsToggleRow(icon: "faceid", label: "Face ID / Biometric",
                              color: theme.secondary, isOn: $biometricEnabled)
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "link", label: "Linked Bank Account",
                           detail: "Chase ****4821", color: theme.accent)
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "creditcard.fill", label: "SUSU Debit Card",
                           detail: "Plus Feature", color: theme.primary)
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Legal Section

    var legalSection: some View {
        VStack(spacing: 0) {
            SettingsNavRow(icon: "doc.text.fill", label: "Privacy Policy", detail: "", color: .secondary)
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "checkmark.shield.fill", label: "Terms of Service", detail: "", color: .secondary)
            Divider().padding(.leading, 52)
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 28)
                    .padding(.leading, 14)
                Text("SUSU v1.0.0")
                    .font(.subheadline)
                Spacer()
                Text("FDIC Insured")
                    .font(.caption2).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                    .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Theme Chip

struct ThemeChip: View {
    let appTheme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [appTheme.primary, appTheme.secondary],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 44)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white, lineWidth: 3)
                        Image(systemName: "checkmark")
                            .font(.subheadline).bold()
                            .foregroundColor(.white)
                    }
                }
                Text(appTheme.name)
                    .font(.caption).fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? appTheme.primary : .secondary)
            }
        }
    }
}

// MARK: - Settings Rows

struct SettingsToggleRow: View {
    let icon: String
    let label: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
                .padding(.leading, 14)
            Text(label).font(.subheadline)
            Spacer()
            Toggle("", isOn: $isOn).tint(color)
                .padding(.trailing, 14)
        }
        .padding(.vertical, 12)
    }
}

struct SettingsNavRow: View {
    let icon: String
    let label: String
    let detail: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
                .padding(.leading, 14)
            Text(label).font(.subheadline)
            Spacer()
            if !detail.isEmpty {
                Text(detail).font(.caption).foregroundColor(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(.secondary)
                .padding(.trailing, 14)
        }
        .padding(.vertical, 12)
    }
}
