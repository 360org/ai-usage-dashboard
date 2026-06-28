import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

@MainActor
@Suite(.serialized)
struct AIDashboardModelTests {
    func makeClaudeStore() throws -> UsageStore {
        let suite = "AIDashboardModelTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)

        let settings = SettingsStore(
            userDefaults: defaults,
            configStore: testConfigStore(suiteName: suite),
            zaiTokenStore: NoopZaiTokenStore(),
            syntheticTokenStore: NoopSyntheticTokenStore())
        settings.providerDetectionCompleted = true

        let claudeMetadata = try #require(ProviderRegistry.shared.metadata[.claude])
        try settings.setProviderEnabled(provider: .claude, metadata: claudeMetadata, enabled: true)

        let store = UsageStore(
            fetcher: UsageFetcher(),
            browserDetection: BrowserDetection(cacheTTL: 0),
            settings: settings)
        store._setSnapshotForTesting(
            UsageSnapshot(
                primary: RateWindow(
                    usedPercent: 35,
                    windowMinutes: 300,
                    resetsAt: Date().addingTimeInterval(1800),
                    resetDescription: nil),
                secondary: RateWindow(
                    usedPercent: 7,
                    windowMinutes: 10080,
                    resetsAt: Date().addingTimeInterval(3600),
                    resetDescription: nil),
                tertiary: nil,
                updatedAt: Date(),
                identity: ProviderIdentitySnapshot(
                    providerID: .claude,
                    accountEmail: "chaulb@icloud.com",
                    accountOrganization: "chaulb@icloud.com's Organization",
                    loginMethod: "web")),
            provider: .claude)
        return store
    }

    @Test
    func `claude identity renders as one dashboard account`() throws {
        let store = try self.makeClaudeStore()
        let model = AIDashboardModel.make(store: store, now: Date())

        let claude = try #require(model.vendors.first(where: { $0.id == .claude }))
        #expect(claude.accounts.count == 1)
        #expect(claude.accounts.first?.label == "chaulb@icloud.com")
        #expect(claude.accounts.first?.detail == "chaulb@icloud.com's Organization")
    }

    @Test
    func `antigravity extra windows render as dashboard model rows`() throws {
        let suite = "AIDashboardModelTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)

        let settings = SettingsStore(
            userDefaults: defaults,
            configStore: testConfigStore(suiteName: suite),
            zaiTokenStore: NoopZaiTokenStore(),
            syntheticTokenStore: NoopSyntheticTokenStore())
        settings.providerDetectionCompleted = true

        let antigravityMetadata = try #require(ProviderRegistry.shared.metadata[.antigravity])
        try settings.setProviderEnabled(provider: .antigravity, metadata: antigravityMetadata, enabled: true)

        let store = UsageStore(
            fetcher: UsageFetcher(),
            browserDetection: BrowserDetection(cacheTTL: 0),
            settings: settings)
        store._setSnapshotForTesting(
            UsageSnapshot(
                primary: RateWindow(
                    usedPercent: 11,
                    windowMinutes: 300,
                    resetsAt: Date().addingTimeInterval(1800),
                    resetDescription: "in 30m"),
                secondary: RateWindow(
                    usedPercent: 22,
                    windowMinutes: 10080,
                    resetsAt: Date().addingTimeInterval(7200),
                    resetDescription: "in 2h"),
                tertiary: nil,
                extraRateWindows: [
                    NamedRateWindow(
                        id: "gemini-3-5-flash-high",
                        title: "Gemini 3.5 Flash (High)",
                        window: RateWindow(
                            usedPercent: 0,
                            windowMinutes: 1000,
                            resetsAt: Date().addingTimeInterval(18000),
                            resetDescription: "in 5h"),
                        usageKnown: true),
                    NamedRateWindow(
                        id: "claude-sonnet-4-6-thinking",
                        title: "Claude Sonnet 4.6 (Thinking)",
                        window: RateWindow(
                            usedPercent: 18,
                            windowMinutes: 1000,
                            resetsAt: Date().addingTimeInterval(18000),
                            resetDescription: "in 5h"),
                        usageKnown: true),
                ],
                updatedAt: Date()),
            provider: .antigravity)

        let model = AIDashboardModel.make(store: store, now: Date())
        let antigravity = try #require(model.vendors.first(where: { $0.id == .antigravity }))
        #expect(antigravity.windows.count == 4)
        #expect(antigravity.windows.map(\.title).contains("Gemini 3.5 Flash (High)"))
        #expect(antigravity.windows.map(\.title).contains("Claude Sonnet 4.6 (Thinking)"))
    }
}
