//
//  WalletView.swift
//  SUSU
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var showContributeSheet = false
    @State private var showWithdrawSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                walletAmbientBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        walletBalanceCard
                        roundUpToggleCard
                        contributionChart
                        groupBreakdown
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("My Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.primary.opacity(0.18), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { showContributeSheet = true } label: {
                            Label("Contribute", systemImage: "plus.circle")
                        }
                        Button { showWithdrawSheet = true } label: {
                            Label("Withdraw", systemImage: "arrow.down.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(theme.primary)
                    }
                }
            }
            .navigationDestination(isPresented: $showContributeSheet) {
                ContributeSheetView(theme: theme)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $showWithdrawSheet) {
                WithdrawSheetView(theme: theme, balance: appState.currentUser.walletBalance)
                    .environmentObject(appState)
            }
        }
    }

    var walletAmbientBackground: some View {
        ZStack {
            Circle()
                .fill(theme.primary.opacity(0.13))
                .frame(width: 300, height: 300)
                .blur(radius: 45)
                .offset(x: -130, y: -280)
            Circle()
                .fill(theme.secondary.opacity(0.11))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 140, y: -180)
            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: 70, y: 210)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Wallet Balance Card

    var walletBalanceCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(colors: [theme.primary.opacity(0.34), theme.secondary.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(theme.primary.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: theme.primary.opacity(0.16), radius: 20, x: 0, y: 10)

            VStack(spacing: 8) {
                Text("Your Wallet Balance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Text(appState.currentUser.walletBalance.asCurrency)
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)

                HStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text(appState.currentUser.totalContributed.asCurrency)
                            .font(.subheadline).bold().foregroundColor(.white)
                        Text("Total In")
                            .font(.caption2).foregroundColor(.white.opacity(0.7))
                    }
                    Divider().frame(height: 30).background(.white.opacity(0.4))
                    VStack(spacing: 2) {
                        Text(appState.currentUser.totalDisbursed.asCurrency)
                            .font(.subheadline).bold().foregroundColor(.white)
                        Text("Total Out")
                            .font(.caption2).foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 4)

                HStack(spacing: 12) {
                    Button {
                        showContributeSheet = true
                    } label: {
                        Text("+ Contribute")
                            .font(.subheadline).bold()
                            .foregroundColor(theme.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                                .background(.white.opacity(0.92))
                            .cornerRadius(20)
                    }
                    Button {
                        showWithdrawSheet = true
                    } label: {
                        Text("Withdraw")
                            .font(.subheadline).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.22))
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 6)
            }
            .padding(24)
        }
    }

    // MARK: - Round-Up Toggle

    var roundUpToggleCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundColor(theme.secondary)
                    Text("Round-Up Savings")
                        .font(.subheadline).bold()
                }
                Text("Spare change from purchases goes to your wallet automatically.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: $appState.currentUser.roundUpEnabled)
                .tint(theme.primary)
        }
        .padding(16)
        .background(theme.cardBackground.opacity(0.84))
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(theme.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: theme.primary.opacity(0.1), radius: 12, x: 0, y: 6)
    }

    // MARK: - Contribution Chart (Bar)

    var contributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSection(title: "Monthly Contributions")
            HStack(alignment: .bottom, spacing: 10) {
                let months = ["Dec", "Jan", "Feb", "Mar", "Apr", "May"]
                let values = appState.currentUser.monthlyContributions
                let maxVal = values.max() ?? 1
                ForEach(Array(zip(months, values)), id: \.0) { month, val in
                    VStack(spacing: 4) {
                        Text("$\(Int(val))")
                            .font(.system(size: 9)).bold()
                            .foregroundColor(theme.primary)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(colors: [theme.primary, theme.secondary],
                                               startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: max(20, (val / maxVal) * 100))
                        Text(month)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)
        }
        .padding(16)
        .background(theme.cardBackground.opacity(0.84))
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(theme.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: theme.primary.opacity(0.1), radius: 12, x: 0, y: 6)
    }

    // MARK: - Group Breakdown

    var groupBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSection(title: "My Contribution by Group")
            ForEach(appState.groups) { group in
                HStack {
                    Text(group.emoji)
                        .font(.title3)
                    Text(group.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer()
                    let memberBalance = group.members.first(where: { $0.name.contains("You") })?.walletBalance ?? 0
                    Text(memberBalance.asCurrency)
                        .font(.subheadline).bold()
                        .foregroundColor(theme.primary)
                }
                .padding(.vertical, 4)
                if group.id != appState.groups.last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(theme.cardBackground.opacity(0.84))
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(theme.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: theme.primary.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Contribute Sheet

struct ContributeSheetView: View {
    let theme: AppTheme
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var selectedType = 0
    @State private var selectedGroupIndex = 0
    @State private var didContribute = false

    var parsedAmount: Double { Double(amount) ?? 0 }

    var body: some View {
        VStack(spacing: 20) {
            Text(parsedAmount > 0 ? parsedAmount.asCurrency : "$0.00")
                .font(.system(size: 52, weight: .black))
                .foregroundColor(parsedAmount > 0 ? theme.primary : .secondary)

            Picker("", selection: $selectedType) {
                Text("One-Time").tag(0)
                Text("Monthly").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if appState.groups.count > 1 {
                HStack {
                    Text("Group:")
                        .font(.subheadline).foregroundColor(.secondary)
                    Picker("Group", selection: $selectedGroupIndex) {
                        ForEach(appState.groups.indices, id: \.self) { i in
                            Text("\(appState.groups[i].emoji) \(appState.groups[i].name)").tag(i)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(theme.primary)
                }
                .padding(.horizontal)
            }

            NumberPad(value: $amount, theme: theme)

            if didContribute {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(theme.secondary)
                    Text("\(parsedAmount.asCurrency) contributed!")
                        .font(.subheadline).foregroundColor(theme.secondary)
                }
                .padding()
                .background(theme.secondary.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                guard parsedAmount > 0 else { return }
                let gid = appState.groups.indices.contains(selectedGroupIndex)
                    ? appState.groups[selectedGroupIndex].id
                    : appState.groups[0].id
                appState.contribute(amount: parsedAmount, toGroup: gid)
                withAnimation { didContribute = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
            } label: {
                Text(didContribute ? "Done!" : "Contribute")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(parsedAmount > 0 ? theme.primary : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            .disabled(parsedAmount <= 0 || didContribute)
        }
        .padding(.top)
        .padding(.bottom, 20)
        .navigationTitle("Contribute")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

// MARK: - Withdraw Sheet

struct WithdrawSheetView: View {
    let theme: AppTheme
    let balance: Double
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var didWithdraw = false

    var parsedAmount: Double { Double(amount) ?? 0 }
    var isOverLimit: Bool { parsedAmount > appState.currentUser.walletBalance }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Available: \(appState.currentUser.walletBalance.asCurrency)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(parsedAmount > 0 ? parsedAmount.asCurrency : "$0.00")
                    .font(.system(size: 52, weight: .black))
                    .foregroundColor(isOverLimit ? .red : (parsedAmount > 0 ? theme.primary : .secondary))
            }

            if isOverLimit {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                    Text("Exceeds your available balance.").font(.caption).foregroundColor(.red)
                }
                .transition(.opacity)
            }

            Text("Funds sent via ACH to your linked bank within 1-2 business days.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NumberPad(value: $amount, theme: theme)

            if didWithdraw {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(theme.secondary)
                    Text("Withdrawal of \(parsedAmount.asCurrency) initiated!")
                        .font(.subheadline).foregroundColor(theme.secondary)
                }
                .padding()
                .background(theme.secondary.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                guard parsedAmount > 0, !isOverLimit else { return }
                appState.withdraw(amount: parsedAmount)
                withAnimation { didWithdraw = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
            } label: {
                Text(didWithdraw ? "Done!" : "Withdraw Funds")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(parsedAmount > 0 && !isOverLimit ? theme.primary : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            .disabled(parsedAmount <= 0 || isOverLimit || didWithdraw)
        }
        .padding(.top)
        .padding(.bottom, 20)
        .navigationTitle("Withdraw")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

// MARK: - Number Pad

struct NumberPad: View {
    @Binding var value: String
    let theme: AppTheme
    let keys = [["1","2","3"],["4","5","6"],["7","8","9"],[".","0","⌫"]]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            Text(key)
                                .font(.title2).fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(theme.primary.opacity(0.07))
                                .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    func handleKey(_ key: String) {
        if key == "⌫" {
            if !value.isEmpty { value.removeLast() }
        } else if key == "." {
            if !value.contains(".") { value += "." }
        } else {
            if value.count < 8 { value += key }
        }
    }
}
