//
//  GroupsView.swift
//  SUSU
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var selectedGroup: SUSUGroup?
    @State private var showCreateGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(appState.groups) { group in
                            GroupCard(group: group, theme: theme)
                                .onTapGesture { selectedGroup = group }
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
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(group: group)
                    .environmentObject(appState)
                    .environment(\.theme, theme)
            }
            .sheet(isPresented: $showCreateGroup) {
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

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        LinearGradient(colors: [theme.primary, theme.secondary],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                        VStack(spacing: 6) {
                            Text(group.emoji).font(.system(size: 48))
                            Text(group.name).font(.title2).bold().foregroundColor(.white)
                            Text(group.poolBalance.asCurrency)
                                .font(.system(size: 32, weight: .black)).foregroundColor(.white)
                            Text("Pool Balance")
                                .font(.caption).foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 24)
                    }
                    .frame(height: 200)

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
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
        }
    }

    var membersTab: some View {
        VStack(spacing: 10) {
            ForEach(group.members) { member in
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
                    Text(member.walletBalance.asCurrency)
                        .font(.subheadline).bold()
                        .foregroundColor(theme.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(theme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
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
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(selectedEmoji)
                        .font(.system(size: 72))
                        .padding(.top, 10)

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
                                            role: .owner, walletBalance: 0, colorHex: "#1B6CA8")
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
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
        }
    }
}
