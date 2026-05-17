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
    @State private var walletVisible = false
    @State private var selectedGroupIndex = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader
                            .padding(.bottom, 24)

                        VStack(spacing: 22) {
                            quickActions
                            if !appState.pendingProposals.isEmpty {
                                attentionBanner
                            }
                            groupCarousel
                            goalsSummary
                            recentActivitySection
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showContribute) {
                ContributeSheetView(theme: theme).environmentObject(appState)
            }
            .sheet(isPresented: $showPropose) {
                NewProposalView(theme: theme, groups: appState.groups).environmentObject(appState)
            }
            .sheet(isPresented: $showWithdraw) {
                WithdrawSheetView(theme: theme, balance: appState.currentUser.walletBalance).environmentObject(appState)
            }
            .sheet(isPresented: $showInvite) {
                InviteView(theme: theme)
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                    walletVisible = true
                }
            }
        }
    }

    // MARK: - Hero Header

    var heroHeader: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed gradient background
            LinearGradient(
                colors: [theme.primary, theme.secondary, theme.primary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Decorative circles
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 260, height: 260)
                        .offset(x: geo.size.width - 80, y: -60)
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 180, height: 180)
                        .offset(x: -40, y: 20)
                    Circle()
                        .fill(.white.opacity(0.04))
                        .frame(width: 120, height: 120)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.1)
                }
            }
            .frame(height: 260)

            // Content
            VStack(spacing: 0) {
                // Top bar
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Good \(greeting) 👋")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Dante")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Avatar + notification dot
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 46, height: 46)
                            .overlay(Text("DL").font(.subheadline).bold().foregroundColor(.white))
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)

                Spacer(minLength: 20)

                // Wallet + Pooled card
                HStack(spacing: 0) {
                    // Wallet
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("MY WALLET")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                        }
                        Text(walletVisible ? appState.myWalletBalance.asCurrency : "••••")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.5), value: walletVisible)
                    }
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 1, height: 50)

                    // Pooled
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("TOTAL POOLED")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                        }
                        Text(walletVisible ? appState.totalPoolBalance.asCurrency : "••••")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.5).delay(0.1), value: walletVisible)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                .background(.white.opacity(0.12))
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal, 16)

                // Pill stats row
                HStack(spacing: 10) {
                    HeroPill(icon: "person.3.fill", value: "\(appState.groups.count)", label: "Groups")
                    HeroPill(icon: "doc.text.fill", value: "\(appState.pendingProposals.count)", label: "Pending")
                    HeroPill(icon: "checkmark.seal.fill",
                             value: "\(appState.groups.flatMap(\.proposals).filter { $0.status == .approved }.count)",
                             label: "Approved")
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .frame(minHeight: 310)
    }

    // MARK: - Quick Actions

    var quickActions: some View {
        HStack(spacing: 10) {
            HomeActionTile(icon: "plus.circle.fill", label: "Add\nFunds",
                           gradient: [theme.primary, theme.primary.opacity(0.7)]) { showContribute = true }
            HomeActionTile(icon: "lightbulb.fill", label: "New\nProposal",
                           gradient: [theme.secondary, theme.secondary.opacity(0.7)]) { showPropose = true }
            HomeActionTile(icon: "arrow.down.circle.fill", label: "Withdraw",
                           gradient: [theme.accent, theme.accent.opacity(0.7)]) { showWithdraw = true }
            HomeActionTile(icon: "person.badge.plus", label: "Invite\nMember",
                           gradient: [theme.textSecondary, theme.textSecondary.opacity(0.7)]) { showInvite = true }
        }
    }

    // MARK: - Attention Banner

    var attentionBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(theme.accent.opacity(0.15)).frame(width: 42, height: 42)
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(theme.accent)
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(appState.pendingProposals.count) Proposal\(appState.pendingProposals.count == 1 ? "" : "s") Need Your Vote")
                    .font(.subheadline).bold()
                Text(appState.pendingProposals.first?.title ?? "")
                    .font(.caption).foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding(14)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.accent.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: theme.accent.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Group Carousel

    var groupCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSection(title: "Your Groups", count: appState.groups.count)

            TabView(selection: $selectedGroupIndex) {
                ForEach(appState.groups.indices, id: \.self) { i in
                    GroupPoolCard(group: appState.groups[i], theme: theme)
                        .tag(i)
                        .padding(.horizontal, 2)
                        .padding(.bottom, 12)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 185)
        }
    }

    // MARK: - Goals Summary

    var goalsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSection(title: "Active Goals", count: appState.groups.flatMap(\.goals).count)
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
            .cornerRadius(18)
            .shadow(color: theme.primary.opacity(0.07), radius: 10, x: 0, y: 4)
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

// MARK: - Group Pool Card

struct GroupPoolCard: View {
    let group: SUSUGroup
    let theme: AppTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [theme.primary.opacity(0.85), theme.secondary.opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: theme.primary.opacity(0.25), radius: 10, x: 0, y: 6)

            // Decorative blob
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 140, height: 140)
                .offset(x: 90, y: -30)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.emoji)
                            .font(.system(size: 30))
                        Text(group.name)
                            .font(.headline).bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    if group.isPlusGroup {
                        Text("PLUS")
                            .font(.caption2).bold()
                            .foregroundColor(theme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.white)
                            .cornerRadius(8)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("POOL BALANCE")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                    Text(group.poolBalance.asCurrency)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                }

                Spacer(minLength: 10)

                HStack {
                    // Member avatars
                    HStack(spacing: -8) {
                        ForEach(group.members.prefix(4)) { member in
                            Circle()
                                .fill(Color(hex: member.colorHex) ?? theme.primary)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Text(member.initials.prefix(2))
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        }
                        if group.members.count > 4 {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 26, height: 26)
                                .overlay(Text("+\(group.members.count - 4)").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        }
                    }
                    Spacer()
                    Text("\(group.members.count) members")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(18)
        }
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

// MARK: - Helpers

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >> 8)  & 0xFF) / 255,
            blue:  Double(val         & 0xFF) / 255
        )
    }
}

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
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 64))
                    .foregroundColor(theme.primary)
                    .padding(.top, 30)

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

                Spacer()
            }
            .navigationTitle("Invite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
        }
    }
}
