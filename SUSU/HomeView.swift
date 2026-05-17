//
//  HomeView.swift
//  SUSU
//

import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var showContribute = false
    @State private var showPropose = false
    @State private var showWithdraw = false
    @State private var showInvite = false
    @State private var walletVisible = false

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
                            chartsDashboard
                            recentActivitySection
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showContribute) {
                ContributeSheetView(theme: theme).environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showPropose) {
                NewProposalView(theme: theme, groups: appState.groups).environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showWithdraw) {
                WithdrawSheetView(theme: theme, balance: appState.currentUser.walletBalance).environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showInvite) {
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

                // Debit card
                SUSUDebitCard(
                    walletBalance: walletVisible ? appState.myWalletBalance : nil,
                    pooledBalance: walletVisible ? appState.totalPoolBalance : nil,
                    theme: theme
                )
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

    // MARK: - Charts Dashboard

    var chartsDashboard: some View {
        VStack(spacing: 14) {
            HomeSection(title: "Pool Insights")
            HStack(alignment: .top, spacing: 14) {
                // Left — Donut: pool distribution
                VStack(alignment: .leading, spacing: 10) {
                    Text("Distribution")
                        .font(.caption).bold()
                        .foregroundColor(.secondary)

                    ZStack {
                        Chart(appState.groups) { group in
                            SectorMark(
                                angle: .value("Pool", group.poolBalance),
                                innerRadius: .ratio(0.58),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Group", group.name))
                            .cornerRadius(4)
                        }
                        .chartForegroundStyleScale([
                            appState.groups.indices.contains(0) ? appState.groups[0].name : "": theme.primary,
                            appState.groups.indices.contains(1) ? appState.groups[1].name : "": theme.secondary,
                            appState.groups.indices.contains(2) ? appState.groups[2].name : "": theme.accent,
                        ])
                        .chartLegend(.hidden)
                        .frame(height: 120)

                        VStack(spacing: 1) {
                            Text(appState.totalPoolBalance.asCurrency)
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(theme.primary)
                            Text("total")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Custom legend
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(appState.groups.indices, id: \.self) { i in
                            let group = appState.groups[i]
                            let colors: [Color] = [theme.primary, theme.secondary, theme.accent]
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(colors[i % colors.count])
                                    .frame(width: 7, height: 7)
                                Text(group.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                Spacer()
                                Text(group.poolBalance.asCurrency)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(14)
                .background(theme.cardBackground)
                .cornerRadius(18)
                .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)

                // Right — Bar: monthly contributions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contributions")
                        .font(.caption).bold()
                        .foregroundColor(.secondary)
                    let months = ["D", "J", "F", "M", "A", "M"]
                    let values = appState.currentUser.monthlyContributions
                    Chart(Array(zip(months, values)), id: \.0) { month, val in
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Amount", val)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [theme.primary, theme.secondary],
                                           startPoint: .bottom, endPoint: .top)
                        )
                        .cornerRadius(5)
                        .annotation(position: .top) {
                            if val == (values.max() ?? 0) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 7))
                                    .foregroundColor(theme.accent)
                            }
                        }
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel().font(.system(size: 9))
                        }
                    }
                    .frame(height: 130)
                }
                .padding(14)
                .background(theme.cardBackground)
                .cornerRadius(18)
                .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)
            }

            // Full-width line chart — 6-month wallet growth
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Savings Growth")
                        .font(.caption).bold()
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("6 months")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                let months = ["Dec", "Jan", "Feb", "Mar", "Apr", "May"]
                let values = appState.currentUser.monthlyContributions
                let cumulative: [Double] = values.indices.map { i in
                    values[0...i].reduce(0, +)
                }
                Chart(Array(zip(months, cumulative)), id: \.0) { month, val in
                    AreaMark(
                        x: .value("Month", month),
                        y: .value("Saved", val)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary.opacity(0.35), theme.primary.opacity(0.0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    LineMark(
                        x: .value("Month", month),
                        y: .value("Saved", val)
                    )
                    .foregroundStyle(theme.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Month", month),
                        y: .value("Saved", val)
                    )
                    .foregroundStyle(theme.primary)
                    .symbolSize(30)
                }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel().font(.system(size: 10))
                    }
                }
                .frame(height: 90)
            }
            .padding(14)
            .background(theme.cardBackground)
            .cornerRadius(18)
            .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
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
