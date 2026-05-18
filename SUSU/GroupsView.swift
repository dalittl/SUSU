//
//  GroupsView.swift
//  SUSU
//

import SwiftUI
import Charts

struct GroupsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var selectedGroup: SUSUGroup?
    @State private var showGroupDetail = false
    @State private var showCreateGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(appState.groups) { group in
                            GroupCard(group: group, theme: theme)
                                .onTapGesture {
                                    selectedGroup = group
                                    showGroupDetail = true
                                }
                        }

                        // Create Group Prompt
                        Button {
                            showCreateGroup = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.title2)
                                    .foregroundColor(theme.primary)
                                Text("Create New Group")
                                    .font(.headline)
                                    .foregroundColor(theme.primary)
                                Spacer()
                            }
                            .padding(18)
                            .background(theme.primary.opacity(0.06))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(theme.primary.opacity(0.25), lineWidth: 1.5)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            )
                        }
                        .padding(.bottom, 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("My Groups")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showGroupDetail) {
                if let group = selectedGroup {
                    GroupDetailView(group: group)
                        .environmentObject(appState)
                        .environment(\.theme, theme)
                }
            }
            .navigationDestination(isPresented: $showCreateGroup) {
                CreateGroupView()
                    .environmentObject(appState)
                    .environment(\.theme, theme)
            }
        }
    }
}

// MARK: - Group Card

struct GroupCard: View {
    let group: SUSUGroup
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(group.emoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(group.name)
                            .font(.headline).bold()
                        if group.isPlusGroup {
                            Text("PLUS")
                                .font(.caption2).bold()
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    Text("\(group.members.count) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(group.poolBalance.asCurrency)
                        .font(.title3).bold()
                        .foregroundColor(theme.primary)
                    Text("pool balance")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Member avatars
            HStack(spacing: -8) {
                ForEach(group.members.prefix(5)) { member in
                    Circle()
                        .fill(Color(hex: member.colorHex))
                        .frame(width: 30, height: 30)
                        .overlay(Text(member.initials).font(.system(size: 9)).bold().foregroundColor(.white))
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                }
                if group.members.count > 5 {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(Text("+\(group.members.count - 5)").font(.system(size: 9)).bold().foregroundColor(.primary))
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                }
                Spacer()

                // Pending badge
                if group.proposals.filter({ $0.status == .pending }).count > 0 {
                    HStack(spacing: 4) {
                        Circle().fill(theme.accent).frame(width: 7, height: 7)
                        Text("\(group.proposals.filter { $0.status == .pending }.count) pending")
                            .font(.caption).foregroundColor(theme.accent)
                    }
                }
            }

            // Goals progress
            if let topGoal = group.goals.first {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(topGoal.emoji) \(topGoal.title)")
                            .font(.caption).fontWeight(.medium)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(topGoal.progress * 100))%")
                            .font(.caption2).bold()
                            .foregroundColor(theme.primary)
                    }
                    ProgressView(value: topGoal.progress)
                        .tint(theme.primary)
                }
            }
        }
        .padding(18)
        .background(theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: theme.primary.opacity(0.09), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Group Detail

struct GroupDetailView: View {
    let group: SUSUGroup
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    @State private var selectedMember: GroupMember?
    @State private var showMemberProfile = false

    var body: some View {
        VStack(spacing: 0) {
            // Pool balance banner
            ZStack {
                LinearGradient(colors: [theme.primary, theme.secondary],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(spacing: 4) {
                    Text(group.poolBalance.asCurrency)
                        .font(.system(size: 28, weight: .black)).foregroundColor(.white)
                    Text("Pool Balance")
                        .font(.caption).foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 16)
            }
            .frame(height: 80)

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("Members").tag(0)
                Text("Goals").tag(1)
                Text("Activity").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView(showsIndicators: false) {
                switch selectedTab {
                case 0: membersTab
                case 1: goalsTab
                default: activityTab
                }
            }
            .frame(maxHeight: 380)
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }.foregroundColor(theme.primary)
            }
        }
        .navigationDestination(isPresented: $showMemberProfile) {
            if let member = selectedMember {
                MemberProfileView(member: member, group: group)
                    .environment(\.theme, theme)
            }
        }
    }

    var membersTab: some View {
        VStack(spacing: 10) {
            ForEach(group.members) { member in
                Button {
                    selectedMember = member
                    showMemberProfile = true
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color(hex: member.colorHex))
                            .frame(width: 44, height: 44)
                            .overlay(Text(member.initials).font(.footnote).bold().foregroundColor(.white))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name).font(.subheadline).fontWeight(.semibold)
                            Text(member.role.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(member.walletBalance.asCurrency)
                                .font(.subheadline).bold()
                                .foregroundColor(theme.primary)
                            Text("wallet")
                                .font(.caption2).foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }

    var goalsTab: some View {
        VStack(spacing: 14) {
            ForEach(group.goals) { goal in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(goal.emoji + " " + goal.title)
                            .font(.subheadline).bold()
                        Spacer()
                        Text(goal.targetAmount.asCurrency)
                            .font(.caption).foregroundColor(.secondary)
                    }
                    ProgressView(value: goal.progress)
                        .tint(theme.primary)
                    HStack {
                        Text(goal.currentAmount.asCurrency)
                            .font(.caption).bold().foregroundColor(theme.primary)
                        Spacer()
                        if let deadline = goal.deadline {
                            Text("Due \(deadline, style: .date)")
                                .font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(14)
                .background(theme.cardBackground)
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }
        .padding(.top, 4)
    }

    var activityTab: some View {
        VStack(spacing: 0) {
            ForEach(group.transactions.sorted { $0.date > $1.date }) { tx in
                TransactionRow(tx: tx, theme: theme)
                Divider().padding(.leading, 52)
            }
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

// MARK: - Create Group

struct CreateGroupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var selectedEmoji = "👨‍👩‍👧‍👦"

    let emojis = ["👨‍👩‍👧‍👦", "🤝", "💼", "🎉", "❤️", "🏠", "✈️", "🎓", "💰", "🌍", "🌟", "🛡️"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(selectedEmoji)
                    .font(.system(size: 72))

                VStack(alignment: .leading, spacing: 8) {
                    Label("Group Name", systemImage: "pencil")
                        .font(.subheadline).foregroundColor(.secondary)
                    TextField("e.g. Little Family Fund", text: $groupName)
                        .padding(14)
                        .background(theme.primary.opacity(0.07))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Choose an Emoji", systemImage: "face.smiling")
                        .font(.subheadline).foregroundColor(.secondary)
                        .padding(.horizontal)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.title2)
                                    .padding(8)
                                    .background(selectedEmoji == emoji ? theme.primary.opacity(0.18) : Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedEmoji == emoji ? theme.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    guard !groupName.isEmpty else { return }
                    let newGroup = SUSUGroup(
                        id: UUID(), name: groupName, emoji: selectedEmoji,
                        members: [
                            GroupMember(id: UUID(), name: "Dante (You)", initials: "DL",
                                        role: .owner, walletBalance: 0, colorHex: "#1B6CA8",
                                        totalContributed: 0,
                                        joinedDate: Date(),
                                        bio: "",
                                        monthlyContributions: [0, 0, 0, 0, 0, 0],
                                        badges: [])
                        ],
                        poolBalance: 0, goals: [], proposals: [], transactions: [],
                        isPlusGroup: false, createdAt: Date()
                    )
                    appState.addGroup(newGroup)
                    dismiss()
                } label: {
                    Text("Create Group")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(groupName.isEmpty ? Color.gray.opacity(0.4) : theme.primary)
                        .cornerRadius(16)
                }
                .disabled(groupName.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }.foregroundColor(theme.primary)
            }
        }
    }
}

// MARK: - Member Profile

struct MemberProfileView: View {
    let member: GroupMember
    let group: SUSUGroup
    @Environment(\.theme) var theme

    // Transactions by this member in the group
    private var memberTransactions: [GroupTransaction] {
        group.transactions.filter { $0.memberName == member.name }.sorted { $0.date > $1.date }
    }

    // Contribution share % vs group total
    private var groupTotalContributed: Double {
        group.members.reduce(0) { $0 + $1.totalContributed }
    }
    private var sharePercent: Double {
        groupTotalContributed > 0 ? (member.totalContributed / groupTotalContributed) * 100 : 0
    }

    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // ── Avatar Hero ──────────────────────────────────────────
                ZStack {
                    LinearGradient(colors: [Color(hex: member.colorHex), Color(hex: member.colorHex).opacity(0.6)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 10) {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 88, height: 88)
                            .overlay(
                                Text(member.initials)
                                    .font(.system(size: 34, weight: .black))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 3))

                        Text(member.name)
                            .font(.title2).bold().foregroundColor(.white)

                        HStack(spacing: 6) {
                            Text(member.role.rawValue)
                                .font(.caption).bold()
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            Text("·")
                                .foregroundColor(.white.opacity(0.6))
                            Text("Since \(member.joinedDate, format: .dateTime.month().year())")
                                .font(.caption).foregroundColor(.white.opacity(0.85))
                        }

                        if !member.badges.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(member.badges, id: \.self) { badge in
                                    Text(badge)
                                        .font(.title3)
                                        .padding(6)
                                        .background(.white.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 28)
                }
                .cornerRadius(20)
                .padding(.horizontal)

                // ── Bio ──────────────────────────────────────────────────
                if !member.bio.isEmpty {
                    Text(member.bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // ── Stats Row ─────────────────────────────────────────────
                HStack(spacing: 12) {
                    StatTile(label: "Wallet", value: member.walletBalance.asCurrency, icon: "wallet.pass.fill", color: theme.primary)
                    StatTile(label: "Contributed", value: member.totalContributed.asCurrency, icon: "arrow.up.circle.fill", color: theme.secondary)
                    StatTile(label: "Group Share", value: String(format: "%.0f%%", sharePercent), icon: "chart.pie.fill", color: theme.accent)
                }
                .padding(.horizontal)

                // ── 6-Month Contribution Chart ────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Label("Monthly Contributions", systemImage: "chart.bar.fill")
                        .font(.subheadline).bold()
                        .padding(.horizontal)

                    Chart {
                        ForEach(Array(member.monthlyContributions.enumerated()), id: \.offset) { index, value in
                            BarMark(
                                x: .value("Month", months[index % months.count]),
                                y: .value("Amount", value)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [theme.primary, theme.secondary],
                                               startPoint: .bottom, endPoint: .top)
                            )
                            .cornerRadius(6)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(format: .currency(code: "USD").precision(.fractionLength(0)))
                    }
                    .frame(height: 160)
                    .padding(.horizontal)
                }
                .padding(.vertical, 14)
                .background(theme.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)

                // ── Contribution Rank in Group ────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Label("Group Contribution Rank", systemImage: "rosette")
                        .font(.subheadline).bold()

                    let sorted = group.members.sorted { $0.totalContributed > $1.totalContributed }
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, m in
                        HStack(spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption2).bold()
                                .frame(width: 20)
                                .foregroundColor(m.id == member.id ? theme.primary : .secondary)
                            Circle()
                                .fill(Color(hex: m.colorHex))
                                .frame(width: 26, height: 26)
                                .overlay(Text(m.initials).font(.system(size: 8)).bold().foregroundColor(.white))
                            Text(m.name)
                                .font(.subheadline)
                                .fontWeight(m.id == member.id ? .bold : .regular)
                                .foregroundColor(m.id == member.id ? theme.primary : .primary)
                            Spacer()
                            Text(m.totalContributed.asCurrency)
                                .font(.subheadline).bold()
                                .foregroundColor(m.id == member.id ? theme.primary : .secondary)
                        }
                        .padding(.vertical, 4)
                        if index < sorted.count - 1 { Divider() }
                    }
                }
                .padding(16)
                .background(theme.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)

                // ── Recent Activity ───────────────────────────────────────
                if !memberTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Recent Activity", systemImage: "clock.fill")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            ForEach(memberTransactions.prefix(5)) { tx in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(tx.amount >= 0 ? theme.primary.opacity(0.12) : Color.red.opacity(0.1))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: tx.amount >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                            .foregroundColor(tx.amount >= 0 ? theme.primary : .red)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tx.description).font(.subheadline)
                                        Text(tx.date, style: .relative)
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(tx.amount >= 0 ? "+\(tx.amount.asCurrency)" : tx.amount.asCurrency)
                                        .font(.subheadline).bold()
                                        .foregroundColor(tx.amount >= 0 ? theme.primary : .red)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                if tx.id != memberTransactions.prefix(5).last?.id { Divider().padding(.leading, 62) }
                            }
                        }
                    }
                    .background(theme.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 12)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(member.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stat Tile

struct StatTile: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.subheadline).bold()
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.07))
        .cornerRadius(14)
    }
}
