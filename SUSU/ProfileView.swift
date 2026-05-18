//
//  ProfileView.swift
//  SUSU
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.theme) var theme

    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true
    @State private var showBankLink = false
    @State private var showDebitCard = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showSportsbookSignup = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileHeader
                        yearInReview
                        themeSection
                        settingsSection
                        legalSection
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showBankLink) {
                BankLinkView(theme: theme)
            }
            .navigationDestination(isPresented: $showDebitCard) {
                DebitCardView(theme: theme)
            }
            .navigationDestination(isPresented: $showSportsbookSignup) {
                SportsSignupView(theme: theme)
            }
            .sheet(isPresented: $showPrivacy) { LegalContentView(title: "Privacy Policy", isTerms: false) }
            .sheet(isPresented: $showTerms) { LegalContentView(title: "Terms of Service", isTerms: true) }
        }
    }

    // MARK: - Profile Header

    var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [theme.primary, theme.secondary],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)
                    .shadow(color: theme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
                Text("DL")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
            }

            Text("Dante Little")
                .font(.title2).bold()

            Text("Group Owner · Plus Member")
                .font(.caption)
                .foregroundColor(theme.primary)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(theme.primary.opacity(0.1))
                .cornerRadius(10)

            HStack(spacing: 0) {
                statItem(value: "\(appState.groups.count)", label: "Groups")
                Divider().frame(height: 30)
                statItem(value: appState.currentUser.totalContributed.asCurrency, label: "Contributed")
                Divider().frame(height: 30)
                statItem(value: appState.currentUser.totalDisbursed.asCurrency, label: "Disbursed")
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
        }
    }

    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.subheadline).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Year In Review

    var yearInReview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [theme.secondary.opacity(0.85), theme.primary],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: theme.primary.opacity(0.2), radius: 8, x: 0, y: 4)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎉 2026 In Review")
                        .font(.headline).bold().foregroundColor(.white)
                    Text("Your family pooled $4,200 and supported 14 family moments.")
                        .font(.subheadline).foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(18)
        }
    }

    // MARK: - Theme Section

    var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSection(title: "App Appearance")
            Text("Choose a color palette")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(AppTheme.themes) { t in
                    ThemeChip(appTheme: t, isSelected: themeManager.current.id == t.id) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            themeManager.current = t
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Settings Section

    var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsToggleRow(icon: "bell.badge.fill", label: "Push Notifications",
                              color: theme.primary, isOn: $notificationsEnabled)
            Divider().padding(.leading, 52)
            SettingsToggleRow(icon: "faceid", label: "Face ID / Biometric",
                              color: theme.secondary, isOn: $biometricEnabled)
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "link", label: "Linked Bank Account",
                           detail: "Chase ****4821", color: theme.accent) { showBankLink = true }
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "creditcard.fill", label: "SUSU Debit Card",
                           detail: "Plus Feature", color: theme.primary) { showDebitCard = true }
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "person.text.rectangle.fill", label: "Finance Sign-Up Demo",
                           detail: "Simple onboarding", color: theme.secondary) { showSportsbookSignup = true }
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Legal Section

    var legalSection: some View {
        VStack(spacing: 0) {
            SettingsNavRow(icon: "doc.text.fill", label: "Privacy Policy", detail: "", color: .secondary) { showPrivacy = true }
            Divider().padding(.leading, 52)
            SettingsNavRow(icon: "checkmark.shield.fill", label: "Terms of Service", detail: "", color: .secondary) { showTerms = true }
            Divider().padding(.leading, 52)
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 28)
                    .padding(.leading, 14)
                Text("SUSU v1.0.0")
                    .font(.subheadline)
                Spacer()
                Text("FDIC Insured")
                    .font(.caption2).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                    .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
        }
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Theme Chip

struct ThemeChip: View {
    let appTheme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [appTheme.primary, appTheme.secondary],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 44)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white, lineWidth: 3)
                        Image(systemName: "checkmark")
                            .font(.subheadline).bold()
                            .foregroundColor(.white)
                    }
                }
                Text(appTheme.name)
                    .font(.caption).fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? appTheme.primary : .secondary)
            }
        }
    }
}

// MARK: - Settings Rows

struct SettingsToggleRow: View {
    let icon: String
    let label: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
                .padding(.leading, 14)
            Text(label).font(.subheadline)
            Spacer()
            Toggle("", isOn: $isOn).tint(color)
                .padding(.trailing, 14)
        }
        .padding(.vertical, 12)
    }
}

struct SettingsNavRow: View {
    let icon: String
    let label: String
    let detail: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button { action?() } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 28)
                    .padding(.leading, 14)
                Text(label).font(.subheadline).foregroundColor(.primary)
                Spacer()
                if !detail.isEmpty {
                    Text(detail).font(.caption).foregroundColor(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption).foregroundColor(.secondary)
                    .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Finance Signup View

struct SportsSignupView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var email = ""
    @State private var phone = ""
    @State private var address1 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var ssnLast4 = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var securityQuestion = "What was your first pet's name?"
    @State private var securityAnswer = ""
    @State private var referralCode = ""

    @State private var agreedToTerms = false
    @State private var confirmedAge = false
    @State private var allowedGeo = false
    @State private var receiveOffers = true

    var canSubmit: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        !address1.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zip.isEmpty &&
        ssnLast4.count == 4 &&
        !username.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword &&
        !securityAnswer.isEmpty &&
        agreedToTerms && confirmedAge && allowedGeo
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                identitySection
                contactSection
                addressSection
                accountSection
                verificationSection
                consentSection

                Button {
        .navigationTitle("Open Account")
                } label: {
                    Text("Create Account")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(canSubmit ? theme.primary : Color.gray.opacity(0.4))
                        .cornerRadius(14)
                }
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(colors: [theme.primary, theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: "banknote.fill").foregroundColor(.white).font(.subheadline))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open your account")
                        .font(.headline)
                    Text("Quick, clear steps with plain language.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text("This demo asks for the same basics a finance app would usually need: who you are, how to reach you, where you live, and how to protect your account.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .padding(16)
        .background(theme.cardBackground.opacity(0.86))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: theme.primary.opacity(0.08), radius: 10, x: 0, y: 4)
            }
        }
    }
        formCard(title: "Identity", detail: "Basic personal info") {
            textField("Legal first name", text: $firstName)
            textField("Legal last name", text: $lastName)
            DatePicker("Date of birth", selection: $dateOfBirth, displayedComponents: .date)
                .font(.subheadline)
            textField("Tax ID last 4", text: $ssnLast4, keyboard: .numberPad, helper: "Use the last 4 digits only.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        formCard(title: "Contact", detail: "How we can reach you") {
            textField("Email address", text: $email, keyboard: .emailAddress)
            textField("Phone number", text: $phone, keyboard: .phonePad)
    }

    var identitySection: some View {
        formCard(title: "Identity") {
        formCard(title: "Home address", detail: "Where your account is linked") {
            textField("Street address", text: $address1)
            textField("City", text: $city)
                .font(.subheadline)
                textField("State", text: $state)
                textField("ZIP code", text: $zip, keyboard: .numberPad)
    }

    var contactSection: some View {
        formCard(title: "Contact") {
            textField("Email", text: $email, keyboard: .emailAddress)
        formCard(title: "Account", detail: "Login info") {
            textField("Username", text: $username)
            secureField("Password", text: $password, helper: "Use 8 or more characters.")
            secureField("Confirm password", text: $confirmPassword)
            textField("Referral code (optional)", text: $referralCode)
            }
        }
    }

        formCard(title: "Security", detail: "Helps protect your account") {
            Picker("Security question", selection: $securityQuestion) {
                Text("What was your first pet's name?").tag("What was your first pet's name?")
                Text("What city were you born in?").tag("What city were you born in?")
                Text("What was your first school?").tag("What was your first school?")
                .background(theme.primary.opacity(0.06))
                .cornerRadius(10)
            SecureField("Confirm Password", text: $confirmPassword)
                .padding(12)
            textField("Security answer", text: $securityAnswer)
                .cornerRadius(10)
            textField("Referral Code (Optional)", text: $referralCode)
        }
    }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upload government ID")
                        .font(.subheadline)
                    Text("Front and back")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
        formCard(title: "Security") {
                Text("Required")
                Text("What was your first pet's name?").tag("What was your first pet's name?")
                Text("What city were you born in?").tag("What city were you born in?")
                Text("What was your first school?").tag("What was your first school?")
            }
            .pickerStyle(.menu)
            .tint(theme.primary)

            textField("Security Answer", text: $securityAnswer)

            HStack(spacing: 10) {
        formCard(title: "Consent", detail: "A few final checks") {
            Toggle("I confirm I’m old enough to open this account", isOn: $confirmedAge)
                Text("Upload Government ID (front/back)")
            Toggle("Allow location checks", isOn: $allowedGeo)
                Spacer()
            Toggle("Accept the terms and privacy policy", isOn: $agreedToTerms)
                    .font(.caption2)
            Toggle("Send helpful product updates", isOn: $receiveOffers)
            }
            .padding(12)
            .background(theme.primary.opacity(0.06))
            .cornerRadius(10)
    func formCard<Content: View>(title: String, detail: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {

    var consentSection: some View {
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        formCard(title: "Consent") {
            Toggle("I am 21+ and eligible to play", isOn: $confirmedAge)
                .tint(theme.primary)
        .padding(16)
        .background(theme.cardBackground.opacity(0.86))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: theme.primary.opacity(0.07), radius: 10, x: 0, y: 4)
                .tint(theme.primary)
            Toggle("Receive promos and odds alerts", isOn: $receiveOffers)
    func textField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default, helper: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(title, text: text)
    }

    func formCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
            .padding(12)
            .background(theme.primary.opacity(0.06))
            .cornerRadius(10)
            if let helper {
                Text(helper)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    func secureField(_ title: String, text: Binding<String>, helper: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            SecureField(title, text: text)
                .padding(12)
                .background(theme.primary.opacity(0.06))
                .cornerRadius(10)
            if let helper {
                Text(helper)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(theme.cardBackground)
        .cornerRadius(14)
    }

    func textField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(title, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(12)
            .background(theme.primary.opacity(0.06))
            .cornerRadius(10)
    }
}

// MARK: - Bank Link View

struct BankLinkView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary)

            Text("Linked Accounts")
                .font(.title2).bold()

            HStack(spacing: 14) {
                Image(systemName: "creditcard.fill")
                    .font(.title2).foregroundColor(theme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chase Bank").font(.subheadline).bold()
                    Text("Checking ****4821").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("Active")
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(6)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: theme.primary.opacity(0.07), radius: 6, x: 0, y: 3)
            .padding(.horizontal)

            Button {} label: {
                Label("Add Another Account", systemImage: "plus.circle")
                    .font(.subheadline).bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.primary.opacity(0.1))
                    .foregroundColor(theme.primary)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Text("Connected via Plaid. Your bank credentials are never stored by SUSU.")
                .font(.caption).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
        }
        .padding(.top)
        .navigationTitle("Bank Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }.foregroundColor(theme.primary)
            }
        }
    }
}

// MARK: - Debit Card View

struct DebitCardView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [theme.primary, theme.secondary],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 200)
                        .shadow(color: theme.primary.opacity(0.3), radius: 16, x: 0, y: 8)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SUSU").font(.headline).bold().foregroundColor(.white)
                            Spacer()
                            Image(systemName: "creditcard.fill").font(.title2).foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Text("•••• •••• •••• ????")
                            .font(.title3).bold().foregroundColor(.white.opacity(0.85))
                        HStack {
                            Text("Dante Little").font(.caption).foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("PLUS ONLY")
                                .font(.caption2).bold()
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(.white.opacity(0.2)).foregroundColor(.white).cornerRadius(6)
                        }
                    }
                    .padding(22)
                }
                .padding(.horizontal).padding(.top)

                VStack(spacing: 8) {
                    Text("Upgrade to SUSU Plus").font(.title3).bold()
                    Text("Get a SUSU debit card for instant spending from approved disbursements. $4.99/month per group.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }

                VStack(spacing: 10) {
                    FeatureRow(icon: "creditcard.fill", text: "Physical & virtual debit card", color: theme.primary)
                    FeatureRow(icon: "bolt.fill", text: "Instant disbursement spending", color: theme.secondary)
                    FeatureRow(icon: "chart.bar.fill", text: "Year-end tax & gifting report", color: theme.accent)
                    FeatureRow(icon: "person.3.fill", text: "Unlimited group members", color: theme.primary)
                }
                .padding(.horizontal)

                Button { dismiss() } label: {
                    Text("Upgrade to Plus — $4.99/mo")
                        .font(.headline).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(theme.primary).cornerRadius(16).padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("SUSU Debit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }.foregroundColor(theme.primary)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(color).frame(width: 24)
            Text(text).font(.subheadline)
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundColor(color)
        }
        .padding(12)
        .background(color.opacity(0.07))
        .cornerRadius(10)
    }
}

// MARK: - Legal Content View

struct LegalContentView: View {
    let title: String
    let isTerms: Bool
    @Environment(\.dismiss) var dismiss

    var content: String {
        isTerms ? """
        Terms of Service — SUSU App
        Last updated: May 17, 2026

        1. Acceptance of Terms
        By using SUSU, you agree to these Terms of Service. If you do not agree, do not use the app.

        2. Eligibility
        You must be 18 years or older and a US resident to use SUSU. All members must complete KYC identity verification.

        3. Financial Services
        SUSU is a technology platform. Banking services are provided by our partner bank (FDIC-insured). Your individual wallet funds are FDIC-insured up to $250,000.

        4. Group Rules
        Group owners set their own trustee approval rules. SUSU is not responsible for disputes between group members. All disbursements require trustee approval per your group agreement.

        5. Withdrawals
        You may withdraw your own wallet contributions at any time. Withdrawals are processed via ACH and typically arrive in 1–2 business days.

        6. Round-Ups
        Round-up contributions are pulled from your linked bank account. You may disable round-ups at any time in your wallet settings.

        7. Prohibited Use
        You may not use SUSU for illegal purposes, money laundering, fraud, or to fund prohibited activities as defined by US law.

        8. Limitation of Liability
        SUSU's liability is limited to the amount in your wallet at the time of any dispute.

        9. Changes
        We may update these terms at any time. Continued use of SUSU after changes constitutes acceptance.

        Contact: support@susu.app
        """ : """
        Privacy Policy — SUSU App
        Last updated: May 17, 2026

        1. Information We Collect
        We collect: name, email, phone number, government-issued ID (for KYC), bank account details (via Plaid), and transaction history.

        2. How We Use Your Information
        We use your data to: provide banking services, verify identity (KYC/AML), process transactions, send notifications, and improve the product.

        3. Data Sharing
        We share data with: our partner bank (for FDIC wallets and ACH), Plaid (bank linking), Persona/Alloy (identity verification), and as required by law.

        We never sell your personal information to third parties for marketing.

        4. Data Security
        All data is encrypted in transit (TLS 1.3) and at rest (AES-256). We follow SOC 2 Type II practices and conduct regular security audits.

        5. Your Rights
        You may request access to, correction of, or deletion of your personal data by contacting privacy@susu.app. Certain data must be retained for legal and regulatory compliance.

        6. Cookies & Analytics
        We use anonymized analytics to improve the app. No cross-app tracking. You can opt out in app settings.

        7. Children
        SUSU is not intended for users under 18. We do not knowingly collect data from minors.

        Contact: privacy@susu.app
        """
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
