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
        let accountNames: [String]
        let windows: [LimitWindow]
        let updatedAt: Date?
        let error: String?
        let brandColor: ProviderColor
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
        let providers = store.enabledProvidersForDisplay().filter {
            store.isEnabled($0) || store.snapshot(for: $0) != nil
        }
        let vendors = providers.map { provider in
            Self.vendor(provider: provider, store: store, now: now)
        }
        let accountCount = Set(vendors.flatMap(\.accountNames)).count
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
            accountNames: Self.accountNames(provider: provider, store: store, snapshot: snapshot),
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

    private static func accountNames(
        provider: UsageProvider,
        store: UsageStore,
        snapshot: UsageSnapshot?)
        -> [String]
    {
        var names: [String] = []
        if let identity = snapshot?.identity(for: provider) {
            if let email = identity.accountEmail, !email.isEmpty {
                names.append(email)
            }
            if let organization = identity.accountOrganization, !organization.isEmpty {
                names.append(organization)
            }
        }
        for account in store.accountSnapshots[provider] ?? [] {
            names.append(account.account.displayName)
        }
        if provider == .codex {
            for account in store.codexAccountSnapshots {
                names.append(account.account.menuDisplayName)
            }
        }
        if names.isEmpty {
            return [L("Default account")]
        }
        var seen = Set<String>()
        return names.filter { seen.insert($0).inserted }
    }

    private static func tone(status: ProviderStatusIndicator?, error: String?, windows: [LimitWindow]) -> Tone {
        if status == .critical || status == .major || error != nil { return .critical }
        if status?.hasIssue == true || windows.contains(where: \.isConstrained) { return .warning }
        if !windows.isEmpty { return .good }
        return .neutral
    }
}
