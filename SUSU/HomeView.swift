//
//  HomeView.swift
//  SUSU
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerCard
                        statsRow
                        quickActions
                        recentActivitySection
                        goalsSummary
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header Card

    var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(colors: [theme.primary, theme.secondary],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: theme.primary.opacity(0.35), radius: 16, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good \(greeting), Dante 👋")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                        Text("SUSU")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(Text("DL").font(.headline).bold().foregroundColor(.white))
                }

                Text("Shared Spending Platform")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 8)

                Divider().background(.white.opacity(0.3))
                    .padding(.vertical, 4)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MY WALLET")
                            .font(.caption2).fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                        Text(appState.myWalletBalance.asCurrency)
                            .font(.title2).bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TOTAL POOLED")
                            .font(.caption2).fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                        Text(appState.totalPoolBalance.asCurrency)
                            .font(.title2).bold()
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(22)
        }
    }

    // MARK: - Stats Row

    var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(icon: "person.3.fill", label: "Groups", value: "\(appState.groups.count)", color: theme.primary)
            StatCard(icon: "doc.text.fill", label: "Pending", value: "\(appState.pendingProposals.count)", color: theme.accent)
            StatCard(icon: "checkmark.circle.fill", label: "Approved", value: "\(appState.groups.flatMap(\.proposals).filter { $0.status == .approved }.count)", color: theme.secondary)
        }
    }

    // MARK: - Quick Actions

    var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Actions")
            HStack(spacing: 12) {
                QuickActionButton(icon: "plus.circle.fill", label: "Contribute", color: theme.primary) {}
                QuickActionButton(icon: "lightbulb.fill", label: "Propose", color: theme.secondary) {}
                QuickActionButton(icon: "arrow.down.circle.fill", label: "Withdraw", color: theme.accent) {}
                QuickActionButton(icon: "person.badge.plus", label: "Invite", color: theme.textSecondary) {}
            }
        }
    }

    // MARK: - Recent Activity

    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Activity")
            let all = appState.groups.flatMap(\.transactions)
                .sorted { $0.date > $1.date }
                .prefix(5)
            VStack(spacing: 0) {
                ForEach(Array(all)) { tx in
                    TransactionRow(tx: tx, theme: theme)
                    if tx.id != all.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Goals Summary

    var goalsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Active Goals")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(appState.groups.flatMap(\.goals)) { goal in
                        GoalCard(goal: goal, theme: theme)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}

// MARK: - Sub-Components

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3).bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: icon).foregroundColor(color).font(.system(size: 20)))
                Text(label)
                    .font(.caption2).fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TransactionRow: View {
    let tx: GroupTransaction
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: iconName).foregroundColor(iconColor).font(.system(size: 16)))
                .padding(.leading, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.description)
                    .font(.subheadline).fontWeight(.medium)
                    .lineLimit(1)
                Text("\(tx.memberName) · \(tx.date.relativeString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text((tx.amount >= 0 ? "+" : "") + tx.amount.asCurrency)
                .font(.subheadline).bold()
                .foregroundColor(tx.amount >= 0 ? theme.secondary : theme.primary)
                .padding(.trailing, 14)
        }
        .padding(.vertical, 10)
    }

    var iconName: String {
        switch tx.type {
        case .roundUp: return "arrow.up.right.circle"
        case .contribution: return "plus.circle"
        case .disbursement: return "arrow.down.circle"
        case .withdrawal: return "minus.circle"
        }
    }

    var iconColor: Color {
        switch tx.type {
        case .roundUp, .contribution: return theme.secondary
        case .disbursement, .withdrawal: return theme.primary
        }
    }
}

struct GoalCard: View {
    let goal: FundGoal
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.emoji)
                    .font(.title2)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(theme.primary)
            }
            Text(goal.title)
                .font(.subheadline).fontWeight(.semibold)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView(value: goal.progress)
                .tint(theme.primary)

            HStack {
                Text(goal.currentAmount.asCurrency)
                    .font(.caption).bold()
                    .foregroundColor(theme.primary)
                Text("of \(goal.targetAmount.asCurrency)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(width: 170)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline).fontWeight(.bold)
    }
}

// MARK: - Helpers

extension Double {
    var asCurrency: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

extension Date {
    var relativeString: String {
        let diff = Date().timeIntervalSince(self)
        if diff < 3600 { return "\(Int(diff / 60))m ago" }
        if diff < 86400 { return "\(Int(diff / 3600))h ago" }
        return "\(Int(diff / 86400))d ago"
    }
}
