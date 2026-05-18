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
                        .padding(.vertical, 8)

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
                                    } onDelete: {
                                        appState.deleteProposal(id: proposal.id, in: group.id)
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
            .navigationDestination(isPresented: $showNewProposal) {
                NewProposalView(theme: theme, groups: appState.groups)
                    .environmentObject(appState)
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
    let onDelete: () -> Void

    @State private var showDetails = false
    @State private var showDeleteConfirm = false

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

            // Photo strip
            if !proposal.photoURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(proposal.photoURLs, id: \.self) { urlStr in
                            AsyncImage(url: URL(string: urlStr)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                case .failure:
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.25))
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                default:
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(ProgressView().scaleEffect(0.6))
                                }
                            }
                            .frame(width: 130, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.vertical, 2)
                }
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
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
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
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.08), radius: 8, x: 0, y: 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Proposal?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\"\(proposal.title)\" will be permanently removed.")
        }
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
    @State private var photoURLs: [String] = []
    @State private var showPhotoPicker = false

    var body: some View {
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

                // Photos
                VStack(alignment: .leading, spacing: 8) {
                    Label("Photos", systemImage: "photo.on.rectangle.angled")
                        .font(.subheadline).foregroundColor(.secondary)
                    if !photoURLs.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photoURLs, id: \.self) { url in
                                    ZStack(alignment: .topTrailing) {
                                        AsyncImage(url: URL(string: url)) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            default: Color.gray.opacity(0.2)
                                            }
                                        }
                                        .frame(width: 80, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Button {
                                            photoURLs.removeAll { $0 == url }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.white, Color.black.opacity(0.6))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                    }
                    Button {
                        showPhotoPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.app")
                            Text(photoURLs.isEmpty ? "Add Photos" : "Add More")
                        }
                        .font(.subheadline)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(theme.primary.opacity(0.07))
                        .foregroundColor(theme.primary)
                        .cornerRadius(10)
                    }
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
                        votes: [], status: .pending, createdAt: Date(),
                        photoURLs: photoURLs
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
                .padding(.bottom, 24)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerSheet(theme: theme, selectedURLs: $photoURLs)
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

// MARK: - Photo Picker Sheet

struct PhotoPickerSheet: View {
    let theme: AppTheme
    @Binding var selectedURLs: [String]
    @Environment(\.dismiss) var dismiss

    let dummyPhotos: [(label: String, url: String)] = [
        ("Birthday",   "https://picsum.photos/seed/birthday/400/300"),
        ("Family",     "https://picsum.photos/seed/familyfun/400/300"),
        ("Travel",     "https://picsum.photos/seed/travel2024/400/300"),
        ("Restaurant", "https://picsum.photos/seed/restaurant/400/300"),
        ("Apartment",  "https://picsum.photos/seed/apartment/400/300"),
        ("Party",      "https://picsum.photos/seed/partynight/400/300"),
        ("Beach",      "https://picsum.photos/seed/beachday/400/300"),
        ("Hotel",      "https://picsum.photos/seed/hotel/400/300"),
        ("Gift",       "https://picsum.photos/seed/giftbox/400/300"),
        ("Vegas",      "https://picsum.photos/seed/vegas/400/300"),
        ("Concert",    "https://picsum.photos/seed/concert/400/300"),
        ("Graduation", "https://picsum.photos/seed/graduation/400/300"),
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(dummyPhotos, id: \.url) { photo in
                        let isSelected = selectedURLs.contains(photo.url)
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: photo.url)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Color.gray.opacity(0.2)
                                        .overlay(ProgressView().scaleEffect(0.6))
                                }
                            }
                            .frame(height: 100)
                            .clipped()
                            Text(photo.label)
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.45))
                        }
                        .cornerRadius(10)
                        .overlay(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 3)
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white, theme.primary)
                                        .padding(6)
                                }
                            }
                        )
                        .onTapGesture {
                            if isSelected {
                                selectedURLs.removeAll { $0 == photo.url }
                            } else {
                                selectedURLs.append(photo.url)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Photos")
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
