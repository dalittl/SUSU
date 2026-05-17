//
//  ProposalsView.swift
//  SUSU
//

import SwiftUI

struct ProposalsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var filterStatus: Proposal.ProposalStatus? = nil
    @State private var showNewProposal = false

    var allProposals: [(SUSUGroup, Proposal)] {
        appState.groups.flatMap { group in
            group.proposals.map { (group, $0) }
        }
        .filter { filterStatus == nil || $0.1.status == filterStatus }
        .sorted { $0.1.createdAt > $1.1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterBar
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    if allProposals.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(theme.primary.opacity(0.4))
                            Text("No proposals yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                ForEach(allProposals, id: \.1.id) { group, proposal in
                                    ProposalCard(group: group, proposal: proposal, theme: theme) { choice in
                                        appState.vote(in: group.id, proposalID: proposal.id, choice: choice)
                                    }
                                }
                                Spacer(minLength: 30)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Proposals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewProposal = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showNewProposal) {
                NewProposalView(theme: theme, groups: appState.groups)
            }
        }
    }

    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: filterStatus == nil, theme: theme) {
                    filterStatus = nil
                }
                FilterChip(title: "Pending", isSelected: filterStatus == .pending, theme: theme) {
                    filterStatus = (filterStatus == .pending) ? nil : .pending
                }
                FilterChip(title: "Approved", isSelected: filterStatus == .approved, theme: theme) {
                    filterStatus = (filterStatus == .approved) ? nil : .approved
                }
                FilterChip(title: "Rejected", isSelected: filterStatus == .rejected, theme: theme) {
                    filterStatus = (filterStatus == .rejected) ? nil : .rejected
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? theme.primary : theme.primary.opacity(0.1))
                .foregroundColor(isSelected ? .white : theme.primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Proposal Card

struct ProposalCard: View {
    let group: SUSUGroup
    let proposal: Proposal
    let theme: AppTheme
    let onVote: (Vote.VoteChoice) -> Void

    @State private var showDetails = false

    var hasVoted: Bool {
        proposal.votes.contains { $0.memberName.contains("You") || $0.memberName == "Dante (You)" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status + Group
            HStack {
                StatusBadge(status: proposal.status, theme: theme)
                Spacer()
                Text("\(group.emoji) \(group.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Title & Amount
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(proposal.title)
                        .font(.headline).bold()
                    Text("By \(proposal.proposedBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(proposal.amount.asCurrency)
                    .font(.title3).bold()
                    .foregroundColor(theme.primary)
            }

            // Description
            if showDetails {
                Text(proposal.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Vote tally
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(theme.secondary)
                        .font(.caption)
                    Text("\(proposal.approveCount)")
                        .font(.caption).bold()
                }
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsdown.fill")
                        .foregroundColor(theme.primary)
                        .font(.caption)
                    Text("\(proposal.rejectCount)")
                        .font(.caption).bold()
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3)) { showDetails.toggle() }
                } label: {
                    Text(showDetails ? "Less" : "More")
                        .font(.caption).foregroundColor(theme.primary)
                }
            }

            // Vote buttons
            if proposal.status == .pending && !hasVoted {
                HStack(spacing: 12) {
                    Button {
                        withAnimation { onVote(.reject) }
                    } label: {
                        Text("Reject")
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(theme.primary.opacity(0.1))
                            .foregroundColor(theme.primary)
                            .cornerRadius(12)
                    }
                    Button {
                        withAnimation { onVote(.approve) }
                    } label: {
                        Text("Approve ✓")
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(theme.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            } else if hasVoted && proposal.status == .pending {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.secondary)
                    Text("You voted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: theme.primary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: Proposal.ProposalStatus
    let theme: AppTheme

    var color: Color {
        switch status {
        case .pending: return theme.accent
        case .approved: return theme.secondary
        case .rejected: return theme.primary
        }
    }

    var icon: String {
        switch status {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(status.rawValue).font(.caption).fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

// MARK: - New Proposal

struct NewProposalView: View {
    let theme: AppTheme
    let groups: [SUSUGroup]
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var amount = ""
    @State private var selectedGroupIndex = 0
    @State private var didSubmit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Group", systemImage: "person.3.fill")
                            .font(.subheadline).foregroundColor(.secondary)
                        Picker("Group", selection: $selectedGroupIndex) {
                            ForEach(groups.indices, id: \.self) { i in
                                Text("\(groups[i].emoji) \(groups[i].name)").tag(i)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(10)
                        .background(theme.primary.opacity(0.07))
                        .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Title", systemImage: "pencil")
                            .font(.subheadline).foregroundColor(.secondary)
                        TextField("e.g. Grandma's Birthday Gift", text: $title)
                            .padding(12)
                            .background(theme.primary.opacity(0.07))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Amount (USD)", systemImage: "dollarsign.circle.fill")
                            .font(.subheadline).foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(theme.primary.opacity(0.07))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "text.alignleft")
                            .font(.subheadline).foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(8)
                            .background(theme.primary.opacity(0.07))
                            .cornerRadius(10)
                    }

                    if didSubmit {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(theme.secondary)
                            Text("Proposal submitted!").font(.subheadline).foregroundColor(theme.secondary)
                        }
                        .padding()
                        .background(theme.secondary.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Button {
                        guard !title.isEmpty, let amountVal = Double(amount), amountVal > 0 else { return }
                        let targetGroup = groups.indices.contains(selectedGroupIndex) ? groups[selectedGroupIndex] : groups[0]
                        let proposal = Proposal(
                            id: UUID(), title: title, description: description,
                            amount: amountVal, proposedBy: "Dante (You)",
                            votes: [], status: .pending, createdAt: Date()
                        )
                        appState.addProposal(proposal, toGroup: targetGroup.id)
                        withAnimation { didSubmit = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                    } label: {
                        Text(didSubmit ? "Submitted!" : "Submit Proposal")
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(title.isEmpty || amount.isEmpty ? Color.gray : theme.primary)
                            .cornerRadius(16)
                    }
                    .disabled(title.isEmpty || amount.isEmpty || didSubmit)
                }
                .padding()
            }
            .navigationTitle("New Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
