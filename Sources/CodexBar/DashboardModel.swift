import CodexBarCore
import Foundation
import SwiftUI

@MainActor
struct AIDashboardModel: Equatable {
    struct Summary: Equatable {
        let accountCount: Int
        let vendorCount: Int
        let modelLimitCount: Int
        let constrainedWindowCount: Int
    }

    struct Vendor: Equatable, Identifiable {
        let id: UsageProvider
        let name: String
        let sourceLabel: String
        let statusLabel: String
        let statusTone: Tone
        let accounts: [Account]
        let windows: [LimitWindow]
        let updatedAt: Date?
        let error: String?
        let brandColor: ProviderColor
    }

    struct Account: Equatable, Identifiable {
        let id: String
        let label: String
        let detail: String?
        let isActive: Bool
    }

    struct LimitWindow: Equatable, Identifiable {
        let id: String
        let title: String
        let scope: Scope
        let usedPercent: Double
        let remainingPercent: Double
        let resetsAt: Date?
        let resetDescription: String?
        let usageKnown: Bool

        var isConstrained: Bool {
            self.usageKnown && self.remainingPercent <= 20
        }
    }

    enum Scope: String, Equatable, CaseIterable {
        case context = "Context"
        case hourly = "Hour"
        case session = "Session"
        case daily = "Day"
        case weekly = "Week"
        case monthly = "Month"
        case model = "Model"
        case credits = "Credits"
        case other = "Other"
    }

    enum Tone: Equatable {
        case good
        case warning
        case critical
        case neutral
    }

    let summary: Summary
    let vendors: [Vendor]

    static func make(store: UsageStore, now: Date = Date()) -> AIDashboardModel {
        let providers = Self.providers(store: store)
        let vendors = providers.map { provider in
            Self.vendor(provider: provider, store: store, now: now)
        }
        let accountCount = vendors.reduce(0) { $0 + $1.accounts.count }
        let modelLimitCount = vendors.reduce(0) { $0 + $1.windows.count }
        let constrainedWindowCount = vendors.reduce(0) { count, vendor in
            count + vendor.windows.filter(\.isConstrained).count
        }
        return AIDashboardModel(
            summary: Summary(
                accountCount: accountCount,
                vendorCount: vendors.count,
                modelLimitCount: modelLimitCount,
                constrainedWindowCount: constrainedWindowCount),
            vendors: vendors)
    }

    private static func providers(store: UsageStore) -> [UsageProvider] {
        let settingsProviders = store.settings.tokenAccountsByProvider.keys
        let snapshottedProviders = store.enabledProvidersForDisplay().filter {
            store.isEnabled($0) || store.snapshot(for: $0) != nil
        }
        let combined = Array(Set(settingsProviders).union(snapshottedProviders))
        return combined.sorted {
            store.metadata(for: $0).displayName.localizedCaseInsensitiveCompare(store.metadata(for: $1).displayName)
                == .orderedAscending
        }
    }

    private static func vendor(provider: UsageProvider, store: UsageStore, now: Date) -> Vendor {
        let metadata = store.metadata(for: provider)
        let descriptor = ProviderDescriptorRegistry.descriptor(for: provider)
        let snapshot = store.snapshot(for: provider)
        let error = store.userFacingError(for: provider)
        let status = store.status(for: provider)
        let windows = Self.limitWindows(
            provider: provider,
            metadata: metadata,
            snapshot: snapshot,
            now: now)
        return Vendor(
            id: provider,
            name: metadata.displayName,
            sourceLabel: store.sourceLabel(for: provider),
            statusLabel: status?.indicator.label ?? (error == nil ? L("Ready") : L("Needs attention")),
            statusTone: Self.tone(status: status?.indicator, error: error, windows: windows),
            accounts: Self.accounts(provider: provider, store: store, snapshot: snapshot),
            windows: windows,
            updatedAt: snapshot?.updatedAt,
            error: error,
            brandColor: descriptor.branding.color)
    }

    private static func limitWindows(
        provider: UsageProvider,
        metadata: ProviderMetadata,
        snapshot: UsageSnapshot?,
        now: Date)
        -> [LimitWindow]
    {
        guard let snapshot else { return [] }
        var windows: [LimitWindow] = []
        func append(_ id: String, title: String, window: RateWindow?, usageKnown: Bool = true) {
            guard let window else { return }
            windows.append(LimitWindow(
                id: id,
                title: title,
                scope: Self.scope(title: title, window: window, provider: provider),
                usedPercent: window.usedPercent,
                remainingPercent: window.remainingPercent,
                resetsAt: window.resetsAt,
                resetDescription: window.resetDescription,
                usageKnown: usageKnown))
        }

        let primaryLabel = provider == .grok
            ? GrokProviderDescriptor.primaryLabel(window: snapshot.primary, now: now) ?? metadata.sessionLabel
            : metadata.sessionLabel
        append("primary", title: L(primaryLabel), window: snapshot.primary)
        append("secondary", title: L(metadata.weeklyLabel), window: snapshot.secondary)
        if metadata.supportsOpus {
            append("tertiary", title: metadata.opusLabel.map(L) ?? L("Sonnet"), window: snapshot.tertiary)
        } else {
            append("tertiary", title: L("Monthly"), window: snapshot.tertiary)
        }
        for extra in snapshot.extraRateWindows ?? [] {
            append("extra-\(extra.id)", title: extra.title, window: extra.window, usageKnown: extra.usageKnown)
        }
        return windows
    }

    private static func scope(title: String, window: RateWindow, provider: UsageProvider) -> Scope {
        let normalized = title.lowercased()
        if normalized.contains("context") { return .context }
        if normalized.contains("hour") || window.windowMinutes == 60 { return .hourly }
        if normalized.contains("week") || window.windowMinutes == 10080 { return .weekly }
        if normalized.contains("month") || (window.windowMinutes ?? 0) >= 40000 { return .monthly }
        if normalized.contains("day") || window.windowMinutes == 1440 { return .daily }
        if normalized.contains("credit") { return .credits }
        if normalized.contains("model") || provider == .factory { return .model }
        if normalized.contains("session") || window.windowMinutes == 300 { return .session }
        return .other
    }

    private static func accounts(
        provider: UsageProvider,
        store: UsageStore,
        snapshot: UsageSnapshot?)
        -> [Account]
    {
        let data = store.settings.tokenAccountsData(for: provider)
        if let data {
            let activeIndex = data.clampedActiveIndex()
            return data.accounts.enumerated().map { index, account in
                let isActive = index == activeIndex
                return Account(
                    id: account.id.uuidString,
                    label: account.displayName,
                    detail: Self.accountDetail(for: account, provider: provider, snapshot: snapshot),
                    isActive: isActive)
            }
        }

        var accounts: [Account] = []
        if let identityAccount = Self.identityAccount(provider: provider, snapshot: snapshot) {
            accounts.append(identityAccount)
        }
        if provider == .codex {
            for account in store.codexAccountSnapshots {
                accounts.append(
                    Account(
                        id: account.id,
                        label: account.account.menuDisplayName,
                        detail: account.sourceLabel,
                        isActive: true))
            }
        }
        if accounts.isEmpty {
            return [Account(
                id: "\(provider.rawValue)-default",
                label: L("Default account"),
                detail: nil,
                isActive: true)]
        }
        var seen = Set<String>()
        return accounts.filter { seen.insert($0.label).inserted }
    }

    private static func identityAccount(provider: UsageProvider, snapshot: UsageSnapshot?) -> Account? {
        guard let identity = snapshot?.identity(for: provider) else { return nil }

        let email = identity.accountEmail?.trimmingCharacters(in: .whitespacesAndNewlines)
        let organization = identity.accountOrganization?.trimmingCharacters(in: .whitespacesAndNewlines)
        let loginMethod = identity.loginMethod?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let email, !email.isEmpty {
            let detail = organization?.isEmpty == false && organization != email ? organization : loginMethod
            return Account(
                id: "\(provider.rawValue)-identity",
                label: email,
                detail: detail,
                isActive: true)
        }

        if let organization, !organization.isEmpty {
            return Account(
                id: "\(provider.rawValue)-identity",
                label: organization,
                detail: loginMethod,
                isActive: true)
        }

        return nil
    }

    private static func accountDetail(
        for account: ProviderTokenAccount,
        provider: UsageProvider,
        snapshot: UsageSnapshot?)
        -> String?
    {
        if let scope = account.sanitizedUsageScope {
            return scope
        }
        if let organization = account.sanitizedOrganizationID {
            return organization
        }
        if let workspace = account.sanitizedWorkspaceID {
            return workspace
        }
        if let identity = snapshot?.identity(for: provider), let email = identity.accountEmail, email == account.label {
            return identity.accountOrganization
        }
        return nil
    }

    private static func tone(status: ProviderStatusIndicator?, error: String?, windows: [LimitWindow]) -> Tone {
        if status == .critical || status == .major || error != nil { return .critical }
        if status?.hasIssue == true || windows.contains(where: \.isConstrained) { return .warning }
        if !windows.isEmpty { return .good }
        return .neutral
    }
}
