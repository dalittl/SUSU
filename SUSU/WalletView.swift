//
//  WalletView.swift
//  SUSU
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.theme) var theme
    @State private var roundUpEnabled = true
    @State private var showContributeSheet = false
    @State private var showWithdrawSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        walletBalanceCard
                        roundUpToggleCard
                        contributionChart
                        groupBreakdown
                        Spacer(minLength: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("My Wallet")
            .navigationBarTitleDisplayMode(.large)
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
            .sheet(isPresented: $showContributeSheet) {
                ContributeSheetView(theme: theme)
            }
            .sheet(isPresented: $showWithdrawSheet) {
                WithdrawSheetView(theme: theme, balance: appState.currentUser.walletBalance)
            }
        }
    }

    // MARK: - Wallet Balance Card

    var walletBalanceCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [theme.primary, theme.secondary],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: theme.primary.opacity(0.3), radius: 16, x: 0, y: 8)

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
                            .background(.white)
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
                            .background(.white.opacity(0.25))
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
            Toggle("", isOn: $roundUpEnabled)
                .tint(theme.primary)
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Contribution Chart (Bar)

    var contributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Monthly Contributions")
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
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Group Breakdown

    var groupBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "My Contribution by Group")
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
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Contribute Sheet

struct ContributeSheetView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var selectedType = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("$\(amount.isEmpty ? "0.00" : amount)")
                    .font(.system(size: 52, weight: .black))
                    .foregroundColor(theme.primary)

                Picker("", selection: $selectedType) {
                    Text("One-Time").tag(0)
                    Text("Monthly").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Numpad
                NumberPad(value: $amount, theme: theme)

                Button {
                    dismiss()
                } label: {
                    Text("Contribute")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.primary)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Withdraw Sheet

struct WithdrawSheetView: View {
    let theme: AppTheme
    let balance: Double
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Available: \(balance.asCurrency)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(amount.isEmpty ? "0.00" : amount)")
                        .font(.system(size: 52, weight: .black))
                        .foregroundColor(theme.primary)
                }

                Text("Funds will be sent via ACH to your linked bank within 1-2 business days.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                NumberPad(value: $amount, theme: theme)

                Button {
                    dismiss()
                } label: {
                    Text("Withdraw Funds")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.primary)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .navigationTitle("Withdraw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
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
