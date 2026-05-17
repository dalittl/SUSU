//
//  AppState.swift
//  SUSU
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var groups: [SUSUGroup] = SUSUGroup.sampleGroups
    @Published var currentUser: SUSUUser = .currentUser
    @Published var selectedGroupID: UUID?

    var selectedGroup: SUSUGroup? {
        guard let id = selectedGroupID else { return groups.first }
        return groups.first(where: { $0.id == id }) ?? groups.first
    }

    var totalPoolBalance: Double { groups.reduce(0) { $0 + $1.poolBalance } }
    var myWalletBalance: Double { currentUser.walletBalance }
    var pendingProposals: [Proposal] { groups.flatMap { $0.proposals }.filter { $0.status == .pending } }

    func vote(in groupID: UUID, proposalID: UUID, choice: Vote.VoteChoice) {
        guard let gi = groups.firstIndex(where: { $0.id == groupID }),
              let pi = groups[gi].proposals.firstIndex(where: { $0.id == proposalID }) else { return }
        let newVote = Vote(id: UUID(), memberName: currentUser.name, choice: choice)
        groups[gi].proposals[pi].votes.append(newVote)
        let p = groups[gi].proposals[pi]
        let trustees = groups[gi].members.filter { $0.role == .trustee || $0.role == .owner }
        if p.approveCount >= max(1, trustees.count / 2 + 1) {
            groups[gi].proposals[pi].status = .approved
        }
    }

    // MARK: - Wallet

    func contribute(amount: Double, toGroup groupID: UUID? = nil) {
        guard amount > 0 else { return }
        currentUser.walletBalance += amount
        currentUser.totalContributed += amount
        let targetID = groupID ?? groups.first?.id
        guard let gid = targetID,
              let gi = groups.firstIndex(where: { $0.id == gid }) else { return }
        let tx = GroupTransaction(
            id: UUID(), description: "Manual contribution",
            amount: amount, type: .contribution, date: Date(),
            memberName: currentUser.name
        )
        groups[gi].transactions.insert(tx, at: 0)
        groups[gi].poolBalance += amount
        if let mi = groups[gi].members.firstIndex(where: { $0.name.contains("You") }) {
            groups[gi].members[mi].walletBalance += amount
        }
    }

    func withdraw(amount: Double) {
        guard amount > 0, amount <= currentUser.walletBalance else { return }
        currentUser.walletBalance -= amount
        currentUser.totalDisbursed += amount
        guard let gi = groups.indices.first else { return }
        let tx = GroupTransaction(
            id: UUID(), description: "Wallet withdrawal",
            amount: -amount, type: .withdrawal, date: Date(),
            memberName: currentUser.name
        )
        groups[gi].transactions.insert(tx, at: 0)
    }

    // MARK: - Proposals

    func addProposal(_ proposal: Proposal, toGroup groupID: UUID) {
        guard let gi = groups.firstIndex(where: { $0.id == groupID }) else { return }
        groups[gi].proposals.insert(proposal, at: 0)
    }

    // MARK: - Groups

    func addGroup(_ group: SUSUGroup) {
        groups.append(group)
    }
}
