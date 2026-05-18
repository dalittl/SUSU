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

    private var totalMembers: Int {
        appState.groups.reduce(0) { $0 + $1.members.count }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HStack(spacing: 10) {
                            overviewPill(icon: "person.3.fill", value: "\(totalMembers)", label: "Members")
                            overviewPill(icon: "doc.text.fill", value: "\(appState.pendingProposals.count)", label: "Pending")
                            overviewPill(icon: "dollarsign.circle.fill", value: appState.totalPoolBalance.asCurrency, label: "Pooled")
                        }

                        ForEach(appState.groups) { group in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedGroup = group
                                    showGroupDetail = true
                                }
                            } label: {
                                GroupCard(group: group, theme: theme)
                            }
                            .buttonStyle(.plain)
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
                            .padding(16)
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

    private func overviewPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(theme.primary)
            Text(value)
                .font(.caption).bold()
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Group Card

struct GroupCard: View {
    let group: SUSUGroup
    let theme: AppTheme

    private var pendingCount: Int {
        group.proposals.filter { $0.status == .pending }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                VStack(alignment: .trailing, spacing: 4) {
                    Text(group.poolBalance.asCurrency)
                        .font(.title3).bold()
                        .foregroundColor(theme.primary)
                    HStack(spacing: 5) {
                        Text("pool")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(theme.primary)
                    }
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
                if pendingCount > 0 {
                    HStack(spacing: 4) {
                        Circle().fill(theme.accent).frame(width: 7, height: 7)
                        Text("\(pendingCount) pending")
                            .font(.caption).foregroundColor(theme.accent)
                            .padding(.trailing, 2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accent.opacity(0.12))
                    .cornerRadius(99)
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

            HStack(spacing: 10) {
                metricTag(icon: "target", text: "\(group.goals.count) goals")
                metricTag(icon: "bubble.left.and.bubble.right.fill", text: "\(group.boardPosts.count) posts")
                metricTag(icon: "checkmark.circle.fill", text: "\(group.proposals.filter { $0.status == .approved }.count) approved")
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [theme.cardBackground, theme.primary.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.primary.opacity(0.14), lineWidth: 1)
        )
    }

    private func metricTag(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundColor(theme.primary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(theme.primary.opacity(0.08))
        .cornerRadius(99)
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
    @State private var expandedComments: Set<UUID> = []
    @Namespace private var tabSelectionAnimation

    private let tabItems = ["Members", "Goals", "Activity", "Board"]

    private var ownerCount: Int { group.members.filter { $0.role == .owner }.count }
    private var trusteeCount: Int { group.members.filter { $0.role == .trustee }.count }
    private var memberCount: Int { group.members.filter { $0.role == .member }.count }

    private var totalGoalTarget: Double { group.goals.reduce(0) { $0 + $1.targetAmount } }
    private var totalGoalCurrent: Double { group.goals.reduce(0) { $0 + $1.currentAmount } }
    private var goalProgress: Double {
        guard totalGoalTarget > 0 else { return 0 }
        return min(totalGoalCurrent / totalGoalTarget, 1)
    }

    private var contributionTxCount: Int { group.transactions.filter { $0.amount > 0 }.count }
    private var disbursementTxCount: Int { group.transactions.filter { $0.amount < 0 }.count }

    private var boardPollCount: Int { group.boardPosts.filter { $0.type == .poll }.count }
    private var boardCommentCount: Int { group.boardPosts.reduce(0) { $0 + $1.comments.count } }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(tabItems.enumerated()), id: \.offset) { index, title in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    selectedTab = index
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: tabIcon(for: index))
                                        .font(.caption)
                                    Text(title)
                                        .font(.subheadline)
                                        .fontWeight(selectedTab == index ? .bold : .semibold)
                                }
                                .foregroundColor(selectedTab == index ? .white : theme.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background {
                                    if selectedTab == index {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(colors: [theme.primary, theme.secondary],
                                                               startPoint: .leading,
                                                               endPoint: .trailing)
                                            )
                                            .matchedGeometryEffect(id: "tabSelection", in: tabSelectionAnimation)
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(theme.primary.opacity(0.08))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        switch selectedTab {
                        case 0: membersTab
                        case 1: goalsTab
                        case 2: activityTab
                        default: boardTab
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.primary, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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

    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "person.2.fill"
        case 1: return "target"
        case 2: return "waveform.path.ecg"
        default: return "bubble.left.and.bubble.right.fill"
        }
    }

    private func detailPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2).bold()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.white.opacity(0.2))
        .cornerRadius(99)
    }

    var membersTab: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                tabWidget(icon: "crown.fill", title: "Owners", value: "\(ownerCount)")
                tabWidget(icon: "checkmark.shield.fill", title: "Trustees", value: "\(trusteeCount)")
                tabWidget(icon: "person.fill", title: "Members", value: "\(memberCount)")
            }
            .padding(.horizontal)

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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }

    var goalsTab: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Goal Progress", systemImage: "chart.bar.fill")
                        .font(.subheadline).bold()
                    Spacer()
                    Text("\(Int(goalProgress * 100))% funded")
                        .font(.caption).bold()
                        .foregroundColor(theme.primary)
                }
                ProgressView(value: goalProgress)
                    .tint(theme.primary)
                HStack {
                    Text(totalGoalCurrent.asCurrency)
                        .font(.caption).bold().foregroundColor(theme.primary)
                    Text("of \(totalGoalTarget.asCurrency)")
                        .font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("\(group.goals.count) goals")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(theme.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.primary.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)

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

                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.caption2)
                            .foregroundColor(theme.primary)
                        Text("Milestone tracking")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(theme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.primary.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
            }
        }
    }

    var activityTab: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                tabWidget(icon: "arrow.up.circle.fill", title: "Inflow", value: "\(contributionTxCount)")
                tabWidget(icon: "arrow.down.circle.fill", title: "Outflow", value: "\(disbursementTxCount)")
                tabWidget(icon: "clock.fill", title: "Total", value: "\(group.transactions.count)")
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(group.transactions.sorted { $0.date > $1.date }) { tx in
                    TransactionRow(tx: tx, theme: theme)
                    Divider().padding(.leading, 52)
                }
            }
            .background(theme.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.primary.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Board Tab

    var boardTab: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                tabWidget(icon: "text.bubble.fill", title: "Posts", value: "\(group.boardPosts.count)")
                tabWidget(icon: "checklist", title: "Polls", value: "\(boardPollCount)")
                tabWidget(icon: "ellipsis.bubble.fill", title: "Comments", value: "\(boardCommentCount)")
            }
            .padding(.horizontal)

            if group.boardPosts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 44))
                        .foregroundColor(theme.primary.opacity(0.35))
                    Text("No posts yet")
                        .font(.headline).foregroundColor(.secondary)
                    Text("Be the first to share something with the group.")
                        .font(.caption).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
            } else {
                ForEach(group.boardPosts) { post in
                    BoardPostCard(
                        post: post,
                        theme: theme,
                        isExpanded: expandedComments.contains(post.id),
                        onToggleComments: {
                            if expandedComments.contains(post.id) {
                                expandedComments.remove(post.id)
                            } else {
                                expandedComments.insert(post.id)
                            }
                        }
                    )
                }
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal)
    }

    private func tabWidget(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(theme.primary)
            Text(value)
                .font(.subheadline).bold()
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Board Post Card

struct BoardPostCard: View {
    let post: BoardPost
    let theme: AppTheme
    let isExpanded: Bool
    let onToggleComments: () -> Void

    private var totalPollVotes: Int {
        post.pollOptions.reduce(0) { $0 + $1.votes.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: post.authorColorHex))
                    .frame(width: 38, height: 38)
                    .overlay(Text(post.authorInitials).font(.system(size: 12, weight: .bold)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(post.author)
                            .font(.subheadline).bold()
                        if let emoji = post.pinnedEmoji {
                            Text(emoji).font(.caption)
                        }
                        if post.type == .poll {
                            Text("POLL")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.8)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(theme.accent.opacity(0.15))
                                .foregroundColor(theme.accent)
                                .cornerRadius(5)
                        }
                    }
                    Text(post.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            // ── Content ────────────────────────────────────────────────
            Text(post.content)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.top, 10)

            // ── Poll Options ───────────────────────────────────────────
            if post.type == .poll && !post.pollOptions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(post.pollOptions) { option in
                        PollOptionRow(option: option, totalVotes: totalPollVotes, theme: theme)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)

                Text("\(totalPollVotes) vote\(totalPollVotes == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
            }

            // ── Footer ─────────────────────────────────────────────────
            HStack(spacing: 20) {
                // Likes
                HStack(spacing: 5) {
                    Image(systemName: post.likes.contains("Dante (You)") ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .foregroundColor(post.likes.contains("Dante (You)") ? .red : .secondary)
                    Text("\(post.likes.count)")
                        .font(.caption).foregroundColor(.secondary)
                }

                // Comments toggle
                Button(action: onToggleComments) {
                    HStack(spacing: 5) {
                        Image(systemName: isExpanded ? "bubble.left.fill" : "bubble.left")
                            .font(.subheadline)
                            .foregroundColor(isExpanded ? theme.primary : .secondary)
                        Text("\(post.comments.count)")
                            .font(.caption)
                            .foregroundColor(isExpanded ? theme.primary : .secondary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // Who liked — stacked avatars
                if !post.likes.isEmpty {
                    HStack(spacing: -6) {
                        ForEach(post.likes.prefix(3), id: \.self) { name in
                            let initials = String(name.split(separator: " ").compactMap { $0.first }.prefix(2))
                            Circle()
                                .fill(Color.secondary.opacity(0.25))
                                .frame(width: 20, height: 20)
                                .overlay(Text(initials).font(.system(size: 7, weight: .bold)).foregroundColor(.primary))
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // ── Comments (expanded) ────────────────────────────────────
            if isExpanded && !post.comments.isEmpty {
                Divider().padding(.horizontal, 14)
                VStack(spacing: 0) {
                    ForEach(post.comments) { comment in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color(hex: comment.authorColorHex))
                                .frame(width: 28, height: 28)
                                .overlay(Text(comment.authorInitials).font(.system(size: 9, weight: .bold)).foregroundColor(.white))

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(comment.author)
                                        .font(.caption).bold()
                                    Text(comment.timestamp, style: .relative)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Text(comment.text)
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.primary.opacity(0.85))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        if comment.id != post.comments.last?.id {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .background(theme.primary.opacity(0.03))
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Poll Option Row

struct PollOptionRow: View {
    let option: PollOption
    let totalVotes: Int
    let theme: AppTheme

    private var fraction: Double {
        totalVotes > 0 ? Double(option.votes.count) / Double(totalVotes) : 0
    }
    private var isLeading: Bool {
        option.votes.count > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(option.text)
                    .font(.caption).fontWeight(.medium)
                    .lineLimit(2)
                Spacer()
                Text("\(option.votes.count)")
                    .font(.caption2).bold()
                    .foregroundColor(isLeading ? theme.primary : .secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.primary.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [theme.primary, theme.secondary],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: max(4, geo.size.width * fraction), height: 6)
                }
            }
            .frame(height: 6)

            if !option.votes.isEmpty {
                Text(option.votes.prefix(3).joined(separator: ", ") + (option.votes.count > 3 ? " +\(option.votes.count - 3)" : ""))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isLeading ? theme.primary.opacity(0.06) : theme.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isLeading ? theme.primary.opacity(0.2) : Color.clear, lineWidth: 1)
        )
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
                        boardPosts: [], isPlusGroup: false, createdAt: Date()
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
            VStack(spacing: 16) {

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
