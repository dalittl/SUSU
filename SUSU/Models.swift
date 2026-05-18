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
    var boardPosts: [BoardPost]
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
    var totalContributed: Double
    var joinedDate: Date
    var bio: String
    var monthlyContributions: [Double]  // last 6 months
    var badges: [String]                // emoji badges

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

// MARK: - Community Board

struct BoardPost: Identifiable {
    let id: UUID
    var author: String
    var authorColorHex: String
    var authorInitials: String
    var type: PostType
    var content: String
    var timestamp: Date
    var likes: [String]             // member names
    var comments: [BoardComment]
    var pollOptions: [PollOption]   // non-empty only when type == .poll
    var pinnedEmoji: String?

    enum PostType { case post, poll }
}

struct BoardComment: Identifiable {
    let id: UUID
    var author: String
    var authorColorHex: String
    var authorInitials: String
    var text: String
    var timestamp: Date
}

struct PollOption: Identifiable {
    let id: UUID
    var text: String
    var votes: [String]             // member names who voted
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
            GroupMember(id: UUID(), name: "Dante (You)", initials: "DL", role: .owner, walletBalance: 142.80, colorHex: "#1B6CA8",
                totalContributed: 620, joinedDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
                bio: "Founder of the Little Family Fund. Building for the future together.",
                monthlyContributions: [90, 110, 105, 120, 95, 100], badges: ["🏆", "⚡️", "💎"]),
            GroupMember(id: UUID(), name: "Mom", initials: "ML", role: .trustee, walletBalance: 218.40, colorHex: "#2D6A4F",
                totalContributed: 850, joinedDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
                bio: "Heart of the family. Consistent contributor and trusted voice.",
                monthlyContributions: [130, 145, 160, 155, 130, 130], badges: ["❤️", "🌟", "💎"]),
            GroupMember(id: UUID(), name: "Dad", initials: "RL", role: .trustee, walletBalance: 190.00, colorHex: "#C84B31",
                totalContributed: 760, joinedDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
                bio: "Steady hand. Always shows up when it matters most.",
                monthlyContributions: [120, 130, 120, 140, 110, 140], badges: ["🛡️", "💰"]),
            GroupMember(id: UUID(), name: "Sister Tara", initials: "TL", role: .member, walletBalance: 87.20, colorHex: "#4A2FBD",
                totalContributed: 320, joinedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                bio: "New to the fund and growing fast!",
                monthlyContributions: [40, 55, 60, 70, 45, 50], badges: ["🌱", "⚡️"]),
            GroupMember(id: UUID(), name: "Uncle James", initials: "JL", role: .member, walletBalance: 55.60, colorHex: "#BE185D",
                totalContributed: 210, joinedDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                bio: "Proud to support the family.",
                monthlyContributions: [30, 40, 35, 45, 30, 30], badges: ["🤝"]),
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
        boardPosts: SUSUGroup.littleFamilyBoard,
        isPlusGroup: true,
        createdAt: Calendar.current.date(byAdding: .month, value: -4, to: Date())!
    )

    static let friendGroup = SUSUGroup(
        id: UUID(),
        name: "The Crew",
        emoji: "🤝",
        members: [
            GroupMember(id: UUID(), name: "Dante (You)", initials: "DL", role: .owner, walletBalance: 62.10, colorHex: "#1B6CA8",
                totalContributed: 280, joinedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                bio: "Started The Crew to fund our (legendary) summer trip.",
                monthlyContributions: [60, 70, 80, 65, 55, 50], badges: ["🏆", "✈️"]),
            GroupMember(id: UUID(), name: "Marcus", initials: "MA", role: .trustee, walletBalance: 75.00, colorHex: "#2D6A4F",
                totalContributed: 310, joinedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                bio: "Always down for an adventure. Finance nerd in disguise.",
                monthlyContributions: [70, 80, 75, 90, 80, 85], badges: ["🧠", "💰", "⚡️"]),
            GroupMember(id: UUID(), name: "Priya", initials: "PK", role: .member, walletBalance: 50.30, colorHex: "#C84B31",
                totalContributed: 210, joinedDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                bio: "Counting down the days till Vegas!",
                monthlyContributions: [35, 40, 45, 50, 40, 0], badges: ["🌟", "🎉"]),
            GroupMember(id: UUID(), name: "Leo", initials: "LR", role: .member, walletBalance: 38.90, colorHex: "#4A2FBD",
                totalContributed: 165, joinedDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                bio: "Living for the weekend.",
                monthlyContributions: [20, 30, 35, 40, 20, 20], badges: ["🌱"]),
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
        boardPosts: SUSUGroup.friendGroupBoard,
        isPlusGroup: false,
        createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    )
}

// MARK: - Sample Board Data

extension SUSUGroup {

    static let littleFamilyBoard: [BoardPost] = {
        let d = Calendar.current

        // Poll 1 — Mom asks about birthday weekend
        let poll1Options = [
            PollOption(id: UUID(), text: "Weekend of June 7th", votes: ["Mom", "Sister Tara", "Uncle James"]),
            PollOption(id: UUID(), text: "Weekend of June 14th", votes: ["Dante (You)", "Dad"]),
            PollOption(id: UUID(), text: "I'm flexible, either works", votes: []),
        ]
        let poll1 = BoardPost(
            id: UUID(),
            author: "Mom",
            authorColorHex: "#2D6A4F",
            authorInitials: "ML",
            type: .poll,
            content: "Which weekend works best for Grandma's birthday dinner? Want to make sure everyone can make it! 🎂",
            timestamp: d.date(byAdding: .hour, value: -2, to: Date())!,
            likes: ["Dad", "Sister Tara", "Uncle James"],
            comments: [
                BoardComment(id: UUID(), author: "Dad", authorColorHex: "#C84B31", authorInitials: "RL",
                             text: "Either weekend works for me. Just let me know so I can request off work 🙏",
                             timestamp: d.date(byAdding: .minute, value: -90, to: Date())!),
                BoardComment(id: UUID(), author: "Dante (You)", authorColorHex: "#1B6CA8", authorInitials: "DL",
                             text: "Going with June 14th — I have a work thing the 7th. But I'll make it work regardless!",
                             timestamp: d.date(byAdding: .minute, value: -60, to: Date())!),
                BoardComment(id: UUID(), author: "Sister Tara", authorColorHex: "#4A2FBD", authorInitials: "TL",
                             text: "June 7th is better for me, got plans the 14th 🥲",
                             timestamp: d.date(byAdding: .minute, value: -30, to: Date())!),
            ],
            pollOptions: poll1Options,
            pinnedEmoji: "📅"
        )

        // Post 1 — Dad celebrating contribution
        let post1 = BoardPost(
            id: UUID(),
            author: "Dad",
            authorColorHex: "#C84B31",
            authorInitials: "RL",
            type: .post,
            content: "Just dropped my contribution for the month 💪 We're almost at our birthday goal for Grandma. Let's push through and surprise her right!",
            timestamp: d.date(byAdding: .hour, value: -26, to: Date())!,
            likes: ["Mom", "Dante (You)", "Sister Tara", "Uncle James"],
            comments: [
                BoardComment(id: UUID(), author: "Mom", authorColorHex: "#2D6A4F", authorInitials: "ML",
                             text: "That's my husband! 🥹 Always on time.",
                             timestamp: d.date(byAdding: .hour, value: -25, to: Date())!),
                BoardComment(id: UUID(), author: "Dante (You)", authorColorHex: "#1B6CA8", authorInitials: "DL",
                             text: "Let's gooo 🔥 I'll throw in mine tomorrow. We'll hit the goal by end of week.",
                             timestamp: d.date(byAdding: .hour, value: -24, to: Date())!),
            ],
            pollOptions: [],
            pinnedEmoji: "🙌"
        )

        // Poll 2 — Dante about emergency pool
        let poll2Options = [
            PollOption(id: UUID(), text: "Yes — open it for true emergencies only", votes: ["Mom", "Dad"]),
            PollOption(id: UUID(), text: "No — let it keep growing for now", votes: ["Sister Tara"]),
            PollOption(id: UUID(), text: "Set a clear rule before we decide", votes: ["Uncle James"]),
        ]
        let poll2 = BoardPost(
            id: UUID(),
            author: "Dante (You)",
            authorColorHex: "#1B6CA8",
            authorInitials: "DL",
            type: .poll,
            content: "Should the emergency support pool be accessible for any urgent family need, or should we define clearer criteria first?",
            timestamp: d.date(byAdding: .day, value: -3, to: Date())!,
            likes: ["Mom", "Dad"],
            comments: [
                BoardComment(id: UUID(), author: "Uncle James", authorColorHex: "#BE185D", authorInitials: "JL",
                             text: "I think rules first. Otherwise it gets muddy real quick 😅",
                             timestamp: d.date(byAdding: .day, value: -3, to: Date())!),
                BoardComment(id: UUID(), author: "Mom", authorColorHex: "#2D6A4F", authorInitials: "ML",
                             text: "Agreed with James — maybe we vote on a written policy at the next check-in?",
                             timestamp: d.date(byAdding: .day, value: -2, to: Date())!),
            ],
            pollOptions: poll2Options,
            pinnedEmoji: "🆘"
        )

        // Post 2 — Uncle James appreciation post
        let post2 = BoardPost(
            id: UUID(),
            author: "Uncle James",
            authorColorHex: "#BE185D",
            authorInitials: "JL",
            type: .post,
            content: "Proud to be part of this. Watching what y'all built here with this fund is inspiring. Little family doing big things 🤝❤️",
            timestamp: d.date(byAdding: .day, value: -5, to: Date())!,
            likes: ["Mom", "Dad", "Dante (You)", "Sister Tara"],
            comments: [
                BoardComment(id: UUID(), author: "Sister Tara", authorColorHex: "#4A2FBD", authorInitials: "TL",
                             text: "Uncle James! 😭 This made my morning. We got you too.",
                             timestamp: d.date(byAdding: .day, value: -5, to: Date())!),
            ],
            pollOptions: [],
            pinnedEmoji: nil
        )

        return [poll1, post1, poll2, post2]
    }()

    static let friendGroupBoard: [BoardPost] = {
        let d = Calendar.current

        // Post 1 — Marcus hypes up Aria availability
        let post1 = BoardPost(
            id: UUID(),
            author: "Marcus",
            authorColorHex: "#2D6A4F",
            authorInitials: "MA",
            type: .post,
            content: "🎰 Aria confirmed availability for July 4th weekend! Rooms are filling fast — if we're doing this, NOW is the time to drop that deposit. I ran the numbers and it's totally doable from our pool.",
            timestamp: d.date(byAdding: .hour, value: -4, to: Date())!,
            likes: ["Dante (You)", "Priya", "Leo"],
            comments: [
                BoardComment(id: UUID(), author: "Priya", authorColorHex: "#C84B31", authorInitials: "PK",
                             text: "YESSSS 🙌 I've been ready. Let's vote on the proposal and lock it down!",
                             timestamp: d.date(byAdding: .hour, value: -3, to: Date())!),
                BoardComment(id: UUID(), author: "Leo", authorColorHex: "#4A2FBD", authorInitials: "LR",
                             text: "July 4th at the Aria?? Bro we're really doing this 😭🔥",
                             timestamp: d.date(byAdding: .hour, value: -2, to: Date())!),
                BoardComment(id: UUID(), author: "Dante (You)", authorColorHex: "#1B6CA8", authorInitials: "DL",
                             text: "Already voted to approve 👑 Let's go!",
                             timestamp: d.date(byAdding: .hour, value: -1, to: Date())!),
            ],
            pollOptions: [],
            pinnedEmoji: "🏨"
        )

        // Poll — Priya asks about monthly savings target
        let pollOptions = [
            PollOption(id: UUID(), text: "$50 / month", votes: ["Leo"]),
            PollOption(id: UUID(), text: "$75 / month", votes: ["Priya", "Marcus"]),
            PollOption(id: UUID(), text: "$100 / month", votes: ["Dante (You)"]),
        ]
        let poll = BoardPost(
            id: UUID(),
            author: "Priya",
            authorColorHex: "#C84B31",
            authorInitials: "PK",
            type: .poll,
            content: "How much should we each try to contribute per month to hit our Vegas goal by July? 💸 I think we need to be real with ourselves lol",
            timestamp: d.date(byAdding: .day, value: -2, to: Date())!,
            likes: ["Marcus", "Leo"],
            comments: [
                BoardComment(id: UUID(), author: "Leo", authorColorHex: "#4A2FBD", authorInitials: "LR",
                             text: "$50 is my max rn fr 😭 rent is tough",
                             timestamp: d.date(byAdding: .day, value: -2, to: Date())!),
                BoardComment(id: UUID(), author: "Marcus", authorColorHex: "#2D6A4F", authorInitials: "MA",
                             text: "$75 is realistic if we're disciplined. I'll even throw in extra some months to cover the gap 🧠",
                             timestamp: d.date(byAdding: .day, value: -1, to: Date())!),
            ],
            pollOptions: pollOptions,
            pinnedEmoji: "💰"
        )

        // Post 2 — Leo doing round-ups
        let post2 = BoardPost(
            id: UUID(),
            author: "Leo",
            authorColorHex: "#4A2FBD",
            authorInitials: "LR",
            type: .post,
            content: "Turned on round-ups yesterday and already saved $2.40 without even thinking about it 😅 small wins but it adds up! Anyone else doing this?",
            timestamp: d.date(byAdding: .day, value: -4, to: Date())!,
            likes: ["Dante (You)", "Priya"],
            comments: [
                BoardComment(id: UUID(), author: "Dante (You)", authorColorHex: "#1B6CA8", authorInitials: "DL",
                             text: "Round-ups are lowkey the move. I've saved like $12 this month just from coffee runs ☕️",
                             timestamp: d.date(byAdding: .day, value: -4, to: Date())!),
                BoardComment(id: UUID(), author: "Priya", authorColorHex: "#C84B31", authorInitials: "PK",
                             text: "I need to turn mine back on 😭 I accidentally disabled it",
                             timestamp: d.date(byAdding: .day, value: -3, to: Date())!),
            ],
            pollOptions: [],
            pinnedEmoji: "🔄"
        )

        return [post1, poll, post2]
    }()
}
