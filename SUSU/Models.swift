//
//  Models.swift
//  SUSU
//

import Foundation

// MARK: - User

struct SUSUUser: Identifiable {
    let id: UUID
    var name: String
    var initials: String
    var walletBalance: Double
    var totalContributed: Double
    var totalDisbursed: Double
    var roundUpEnabled: Bool
    var monthlyContributions: [Double]  // last 6 months

    static let currentUser = SUSUUser(
        id: UUID(),
        name: "You",
        initials: "YO",
        walletBalance: 142.80,
        totalContributed: 1_240.00,
        totalDisbursed: 980.00,
        roundUpEnabled: true,
        monthlyContributions: [38, 42, 55, 61, 47, 58]
    )
}

// MARK: - Group

struct SUSUGroup: Identifiable {
    let id: UUID
    var name: String
    var emoji: String
    var members: [GroupMember]
    var poolBalance: Double
    var goals: [FundGoal]
    var proposals: [Proposal]
    var transactions: [GroupTransaction]
    var isPlusGroup: Bool
    var createdAt: Date
}

struct GroupMember: Identifiable {
    let id: UUID
    var name: String
    var initials: String
    var role: MemberRole
    var walletBalance: Double
    var colorHex: String

    enum MemberRole: String {
        case owner = "Owner"
        case trustee = "Trustee"
        case member = "Member"
    }
}

// MARK: - Goals

struct FundGoal: Identifiable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var emoji: String
    var deadline: Date?

    var progress: Double { min(currentAmount / targetAmount, 1.0) }
}

// MARK: - Proposals

struct Proposal: Identifiable {
    var id: UUID
    var title: String
    var description: String
    var amount: Double
    var proposedBy: String
    var votes: [Vote]
    var status: ProposalStatus
    var createdAt: Date
    var photoURLs: [String] = []

    enum ProposalStatus: String {
        case pending = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"
    }

    var approveCount: Int { votes.filter { $0.choice == .approve }.count }
    var rejectCount: Int { votes.filter { $0.choice == .reject }.count }
}

struct Vote: Identifiable {
    let id: UUID
    var memberName: String
    var choice: VoteChoice
    enum VoteChoice { case approve, reject }
}

// MARK: - Transactions

struct GroupTransaction: Identifiable {
    let id: UUID
    var description: String
    var amount: Double
    var type: TransactionType
    var date: Date
    var memberName: String

    enum TransactionType: String {
        case roundUp = "Round-up"
        case contribution = "Contribution"
        case disbursement = "Disbursement"
        case withdrawal = "Withdrawal"
    }
}

// MARK: - Sample Data

extension SUSUGroup {
    static let sampleGroups: [SUSUGroup] = [littleFamily, friendGroup]

    static let littleFamily = SUSUGroup(
        id: UUID(),
        name: "Little Family Fund",
        emoji: "👨‍👩‍👧‍👦",
        members: [
            GroupMember(id: UUID(), name: "Dante (You)", initials: "DL", role: .owner, walletBalance: 142.80, colorHex: "#1B6CA8"),
            GroupMember(id: UUID(), name: "Mom", initials: "ML", role: .trustee, walletBalance: 218.40, colorHex: "#2D6A4F"),
            GroupMember(id: UUID(), name: "Dad", initials: "RL", role: .trustee, walletBalance: 190.00, colorHex: "#C84B31"),
            GroupMember(id: UUID(), name: "Sister Tara", initials: "TL", role: .member, walletBalance: 87.20, colorHex: "#4A2FBD"),
            GroupMember(id: UUID(), name: "Uncle James", initials: "JL", role: .member, walletBalance: 55.60, colorHex: "#BE185D"),
        ],
        poolBalance: 694.00,
        goals: [
            FundGoal(id: UUID(), title: "Grandma's 80th Birthday", targetAmount: 500, currentAmount: 380, emoji: "🎂", deadline: Calendar.current.date(byAdding: .month, value: 2, to: Date())),
            FundGoal(id: UUID(), title: "Family Reunion Trip", targetAmount: 2000, currentAmount: 694, emoji: "✈️", deadline: Calendar.current.date(byAdding: .month, value: 8, to: Date())),
            FundGoal(id: UUID(), title: "Emergency Support Pool", targetAmount: 1000, currentAmount: 694, emoji: "🆘", deadline: nil),
        ],
        proposals: [
            Proposal(
                id: UUID(),
                title: "Grandma's Birthday Gift",
                description: "Pool $200 to send a bouquet, dinner gift card, and photo book for Grandma's birthday next month.",
                amount: 200,
                proposedBy: "Dante (You)",
                votes: [
                    Vote(id: UUID(), memberName: "Mom", choice: .approve),
                    Vote(id: UUID(), memberName: "Dad", choice: .approve),
                ],
                status: .pending,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                photoURLs: [
                    "https://picsum.photos/seed/birthday/400/300",
                    "https://picsum.photos/seed/flowers/400/300",
                    "https://picsum.photos/seed/familyfun/400/300",
                ]
            ),
            Proposal(
                id: UUID(),
                title: "Help Tara's Security Deposit",
                description: "$500 to help Tara cover her new apartment security deposit.",
                amount: 500,
                proposedBy: "Mom",
                votes: [
                    Vote(id: UUID(), memberName: "Dante (You)", choice: .approve),
                    Vote(id: UUID(), memberName: "Dad", choice: .approve),
                    Vote(id: UUID(), memberName: "Uncle James", choice: .approve),
                ],
                status: .approved,
                createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                photoURLs: [
                    "https://picsum.photos/seed/apartment/400/300",
                    "https://picsum.photos/seed/keys/400/300",
                ]
            ),
        ],
        transactions: [
            GroupTransaction(id: UUID(), description: "Round-up from Starbucks", amount: 0.70, type: .roundUp, date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, memberName: "Dante (You)"),
            GroupTransaction(id: UUID(), description: "Round-up from Uber", amount: 0.45, type: .roundUp, date: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!, memberName: "Mom"),
            GroupTransaction(id: UUID(), description: "Monthly contribution", amount: 50, type: .contribution, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, memberName: "Dad"),
            GroupTransaction(id: UUID(), description: "Tara's Security Deposit", amount: -500, type: .disbursement, date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, memberName: "System"),
            GroupTransaction(id: UUID(), description: "Round-up from Target", amount: 1.30, type: .roundUp, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, memberName: "Uncle James"),
        ],
        isPlusGroup: true,
        createdAt: Calendar.current.date(byAdding: .month, value: -4, to: Date())!
    )

    static let friendGroup = SUSUGroup(
        id: UUID(),
        name: "The Crew",
        emoji: "🤝",
        members: [
            GroupMember(id: UUID(), name: "Dante (You)", initials: "DL", role: .owner, walletBalance: 62.10, colorHex: "#1B6CA8"),
            GroupMember(id: UUID(), name: "Marcus", initials: "MA", role: .trustee, walletBalance: 75.00, colorHex: "#2D6A4F"),
            GroupMember(id: UUID(), name: "Priya", initials: "PK", role: .member, walletBalance: 50.30, colorHex: "#C84B31"),
            GroupMember(id: UUID(), name: "Leo", initials: "LR", role: .member, walletBalance: 38.90, colorHex: "#4A2FBD"),
        ],
        poolBalance: 226.30,
        goals: [
            FundGoal(id: UUID(), title: "Summer Vegas Trip", targetAmount: 1200, currentAmount: 226.30, emoji: "🎰", deadline: Calendar.current.date(byAdding: .month, value: 5, to: Date())),
        ],
        proposals: [
            Proposal(
                id: UUID(),
                title: "Book Vegas Hotel Deposit",
                description: "Put down a $300 deposit on the Aria for our summer trip.",
                amount: 300,
                proposedBy: "Marcus",
                votes: [
                    Vote(id: UUID(), memberName: "Dante (You)", choice: .approve),
                ],
                status: .pending,
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                photoURLs: [
                    "https://picsum.photos/seed/vegas/400/300",
                    "https://picsum.photos/seed/hotel/400/300",
                ]
            ),
        ],
        transactions: [
            GroupTransaction(id: UUID(), description: "Round-up from DoorDash", amount: 0.85, type: .roundUp, date: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, memberName: "Dante (You)"),
            GroupTransaction(id: UUID(), description: "Monthly contribution", amount: 25, type: .contribution, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, memberName: "Marcus"),
        ],
        isPlusGroup: false,
        createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    )
}
