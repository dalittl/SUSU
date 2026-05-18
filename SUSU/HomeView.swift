//
//  HomeView.swift
//  SUSU
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var showContribute = false
    @State private var showPropose = false
    @State private var showWithdraw = false
    @State private var showInvite = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                theme.background.ignoresSafeArea()
                ambientBlobBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader
                            .padding(.bottom, 18)

                        VStack(spacing: 22) {
                            quickActions
                            organicGrowthSection
                            recentActivitySection
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(isPresented: $showContribute) {
                ContributeSheetView(theme: theme)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $showPropose) {
                NewProposalView(theme: theme, groups: appState.groups)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $showWithdraw) {
                WithdrawSheetView(theme: theme, balance: appState.currentUser.walletBalance)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $showInvite) {
                InviteView(theme: theme)
            }
        }
    }

    var ambientBlobBackground: some View {
        ZStack {
            Circle()
                .fill(theme.secondary.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: -120, y: -280)
            Circle()
                .fill(theme.primary.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 55)
                .offset(x: 160, y: -180)
            Circle()
                .fill(theme.primary.opacity(0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: -80, y: 120)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hero Header

    var heroHeader: some View {
        VStack(spacing: 22) {
            HStack {
                Text("Good \(greeting)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(theme.primary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(Text("DL").font(.caption).bold().foregroundColor(theme.primary))
            }

            VStack(spacing: 8) {
                Text(appState.totalPoolBalance.asCurrency)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(theme.primary)
                    .contentTransition(.numericText())
                Text("saved together")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text("\(appState.groups.count) groups · \(appState.groups.reduce(0) { $0 + $1.members.count }) people contributing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 10) {
                HeroPill(icon: "person.3.fill", value: "\(appState.groups.count)", label: "Groups")
                HeroPill(icon: "doc.text.fill", value: "\(appState.pendingProposals.count)", label: "Pending")
                HeroPill(icon: "checkmark.seal.fill",
                         value: "\(appState.groups.flatMap(\.proposals).filter { $0.status == .approved }.count)",
                         label: "Approved")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Quick Actions

    var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            FloatingActionPill(icon: "plus.circle.fill", label: "Contribute", tint: theme.primary) { showContribute = true }
            FloatingActionPill(icon: "checkmark.bubble.fill", label: "Vote", tint: theme.secondary) { showPropose = true }
            FloatingActionPill(icon: "heart.circle.fill", label: "Send Help", tint: theme.accent) { showWithdraw = true }
            FloatingActionPill(icon: "person.badge.plus", label: "Invite", tint: theme.textSecondary) { showInvite = true }
        }
    }

    // MARK: - Organic Growth

    var organicGrowthSection: some View {
        VStack(spacing: 14) {
            HomeSection(title: "Growth")
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(theme.cardBackground.opacity(0.78))
                Circle()
                    .fill(theme.primary.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                Circle()
                    .fill(theme.secondary.opacity(0.16))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                    .offset(x: 70, y: -40)

                VStack(spacing: 10) {
                    Text("Your group just keeps blooming")
                        .font(.headline)
                    Text("Every contribution expands the ecosystem")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 22) {
                        growthOrb(value: "\(appState.groups.count)", label: "circles")
                        growthOrb(value: "\(appState.pendingProposals.count)", label: "votes")
                        growthOrb(value: "\(appState.groups.flatMap(\.transactions).count)", label: "moments")
                    }
                }
                .padding(20)
            }
            .padding(16)
            .background(theme.cardBackground.opacity(0.7))
            .cornerRadius(34)
            .shadow(color: theme.primary.opacity(0.1), radius: 18, x: 0, y: 8)
        }
    }

    private func growthOrb(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(LinearGradient(colors: [theme.primary.opacity(0.4), theme.secondary.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 46, height: 46)
                .overlay(Circle().stroke(theme.primary.opacity(0.2), lineWidth: 1))
            Text(value)
                .font(.subheadline).bold()
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Recent Activity

    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSection(title: "Recent Activity")
            let all = Array(appState.groups.flatMap(\.transactions)
                .sorted { $0.date > $1.date }
                .prefix(5))
            VStack(spacing: 0) {
                ForEach(Array(all.enumerated()), id: \.element.id) { idx, tx in
                    TransactionRow(tx: tx, theme: theme)
                    if idx < all.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
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

// MARK: - Hero Pill

struct HeroPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.caption).bold()
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.15))
        .cornerRadius(20)
    }
}

struct FloatingActionPill: View {
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: icon)
                            .font(.subheadline)
                            .foregroundColor(tint)
                    )
                Text(label)
                    .font(.subheadline).bold()
                    .foregroundColor(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(.ultraThinMaterial.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(tint.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(30)
            .shadow(color: tint.opacity(0.14), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Home Action Tile

struct HomeActionTile: View {
    let icon: String
    let label: String
    let gradient: [Color]
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                pressed = false
                action()
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                        .shadow(color: gradient.first!.opacity(0.35), radius: 8, x: 0, y: 4)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(pressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Debit Card

struct SUSUDebitCard: View {
    let walletBalance: Double?
    let pooledBalance: Double?
    let theme: AppTheme

    var body: some View {
        ZStack {
            // Card base — frosted glass over the hero gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.22), .white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)

            // Holographic shimmer blobs
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 180, height: 180)
                .offset(x: 80, y: -50)
                .blur(radius: 2)
            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 120, height: 120)
                .offset(x: -60, y: 50)
                .blur(radius: 1)

            VStack(alignment: .leading, spacing: 0) {
                // Row 1 — chip + SUSU logo
                HStack(alignment: .center) {
                    // EMV chip
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [Color(hex: "#D4AF37"), Color(hex: "#F5D97E"), Color(hex: "#B8962E")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 28)
                        .overlay(
                            VStack(spacing: 3) {
                                // chip lines
                                RoundedRectangle(cornerRadius: 1).fill(.black.opacity(0.2)).frame(height: 1)
                                HStack(spacing: 3) {
                                    RoundedRectangle(cornerRadius: 1).fill(.black.opacity(0.2)).frame(width: 10, height: 8)
                                    RoundedRectangle(cornerRadius: 1).fill(.black.opacity(0.2)).frame(width: 10, height: 8)
                                }
                                RoundedRectangle(cornerRadius: 1).fill(.black.opacity(0.2)).frame(height: 1)
                            }
                            .padding(3)
                        )

                    Spacer()

                    // Brand name
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                        Text("SUSU")
                            .font(.system(size: 13, weight: .black))
                            .tracking(3)
                            .foregroundColor(.white)
                    }
                }

                Spacer(minLength: 14)

                // Row 2 — masked card number
                HStack(spacing: 6) {
                    ForEach(0..<3) { _ in
                        HStack(spacing: 3) {
                            ForEach(0..<4) { _ in
                                Circle()
                                    .fill(.white.opacity(0.7))
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }
                    Text("2026")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(2)
                }

                Spacer(minLength: 12)

                // Row 3 — balances
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MY WALLET")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(1.5)
                        Text(walletBalance.map { $0.asCurrency } ?? "••••")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("TOTAL POOLED")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(1.5)
                        Text(pooledBalance.map { $0.asCurrency } ?? "••••")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                    }
                }

                Spacer(minLength: 12)

                // Row 4 — cardholder + network circles
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("CARD HOLDER")
                            .font(.system(size: 7, weight: .semibold))
                            .foregroundColor(.white.opacity(0.55))
                            .tracking(1)
                        Text("DANTE LITTLE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    Spacer()
                    // Network logo (Mastercard-style two circles)
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.75))
                            .frame(width: 26, height: 26)
                            .offset(x: -9)
                        Circle()
                            .fill(Color.orange.opacity(0.75))
                            .frame(width: 26, height: 26)
                            .offset(x: 9)
                    }
                    .frame(width: 50, height: 26)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .aspectRatio(1.586, contentMode: .fit)  // Standard card ratio
    }
}

// MARK: - Home Section Header

struct HomeSection: View {
    let title: String
    var count: Int? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline).bold()
            if let count {
                Text("\(count)")
                    .font(.caption).bold()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(8)
            }
            Spacer()
        }
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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.08), radius: 8, x: 0, y: 4)
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

// MARK: - Invite View

struct InviteView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    @State private var copied = false

    let inviteLink = "https://susu.app/invite/DL-ABC123"

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(theme.primary)

            Text("Invite Someone")
                .font(.title2).bold()

            Text("Share this link to bring someone into one of your SUSU groups.")
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack {
                Text(inviteLink)
                    .font(.caption)
                    .foregroundColor(theme.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button {
                    UIPasteboard.general.string = inviteLink
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { copied = false }
                    }
                } label: {
                    Text(copied ? "Copied!" : "Copy")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(copied ? theme.secondary : theme.primary)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(theme.primary.opacity(0.07))
            .cornerRadius(12)
            .padding(.horizontal)

            ShareLink(item: inviteLink) {
                Label("Share Link", systemImage: "square.and.arrow.up")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.primary)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding(.top)
        .navigationTitle("Invite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }.foregroundColor(theme.primary)
            }
        }
    }
}
