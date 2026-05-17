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
}
