import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

@MainActor
@Suite(.serialized)
struct AIDashboardModelTests {
    func makeStore() throws -> UsageStore {
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
        let store = try self.makeStore()
        let model = AIDashboardModel.make(store: store, now: Date())

        let claude = try #require(model.vendors.first(where: { $0.id == .claude }))
        #expect(claude.accounts.count == 1)
        #expect(claude.accounts.first?.label == "chaulb@icloud.com")
        #expect(claude.accounts.first?.detail == "chaulb@icloud.com's Organization")
    }
}
