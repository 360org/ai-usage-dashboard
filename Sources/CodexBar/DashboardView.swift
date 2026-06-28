import CodexBarCore
import SwiftUI

@MainActor
struct AIDashboardView: View {
    @Bindable var store: UsageStore
    @State private var selectedProvider: UsageProvider?
    @State private var selectedAccountID: String?
    let onActivateAccount: (UsageProvider, Int) -> Void

    private var model: AIDashboardModel {
        AIDashboardModel.make(store: self.store)
    }

    private var selectedVendor: AIDashboardModel.Vendor? {
        let vendors = self.model.vendors
        guard !vendors.isEmpty else { return nil }
        if let selectedProvider, let vendor = vendors.first(where: { $0.id == selectedProvider }) {
            return vendor
        }
        return vendors.first
    }

    var body: some View {
        NavigationSplitView {
            DashboardSidebar(
                model: self.model,
                selectedProvider: self.$selectedProvider,
                selectedAccountID: self.$selectedAccountID,
                onActivateAccount: self.onActivateAccount)
        } detail: {
            if let vendor = self.selectedVendor {
                DashboardDetail(vendor: vendor)
            } else {
                DashboardEmptyState()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 980, minHeight: 640)
        .background(Color(nsColor: .windowBackgroundColor))
        .task(id: self.model.vendors.first?.id) {
            if self.selectedProvider == nil {
                self.selectedProvider = self.model.vendors.first?.id
            }
            if self.selectedAccountID == nil {
                self.selectedAccountID = self.model.vendors.first?.accounts.first?.id
            }
        }
    }
}

@MainActor
private struct DashboardSidebar: View {
    let model: AIDashboardModel
    @Binding var selectedProvider: UsageProvider?
    @Binding var selectedAccountID: String?
    let onActivateAccount: (UsageProvider, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Usage Dashboard")
                    .font(.title2.weight(.semibold))
                Text("Accounts, vendors, limits, resets")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)

            DashboardSummaryGrid(summary: self.model.summary)
                .padding(.horizontal, 14)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(self.model.vendors) { vendor in
                        DashboardVendorGroup(
                            vendor: vendor,
                            selectedProvider: self.$selectedProvider,
                            selectedAccountID: self.$selectedAccountID,
                            onActivateAccount: self.onActivateAccount)
                    }
                }
            }
            .accessibilityLabel("AI vendors")
            .padding(.horizontal, 10)
        }
        .frame(minWidth: 280)
    }
}

private struct DashboardSummaryGrid: View {
    let summary: AIDashboardModel.Summary

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                DashboardMetric(title: "Accounts", value: "\(self.summary.accountCount)")
                DashboardMetric(title: "Vendors", value: "\(self.summary.vendorCount)")
            }
            GridRow {
                DashboardMetric(title: "Limits", value: "\(self.summary.modelLimitCount)")
                DashboardMetric(title: "Tight", value: "\(self.summary.constrainedWindowCount)")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(self.summary.accountCount) accounts, \(self.summary.vendorCount) vendors, " +
                "\(self.summary.modelLimitCount) limits")
    }
}

private struct DashboardMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(self.value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .monospacedDigit()
            Text(self.title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DashboardVendorGroup: View {
    let vendor: AIDashboardModel.Vendor
    @Binding var selectedProvider: UsageProvider?
    @Binding var selectedAccountID: String?
    let onActivateAccount: (UsageProvider, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                self.selectedProvider = self.vendor.id
                if self.selectedAccountID == nil {
                    self.selectedAccountID = self.vendor.accounts.first?.id
                }
            } label: {
                HStack(spacing: 10) {
                    Circle()
                        .fill(self.vendor.brandSwiftUIColor)
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(self.vendor.name)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        Text("\(self.vendor.accounts.count) accounts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    Text("\(self.vendor.accounts.count)")
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    self.selectedProvider == self.vendor.id ? self.vendor.brandSwiftUIColor.opacity(0.18) : .clear,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(self.vendor.accounts.enumerated()), id: \.element.id) { index, account in
                    DashboardAccountRow(
                        vendor: self.vendor,
                        account: account,
                        isSelected: self.selectedAccountID == account.id)
                    {
                        self.selectedProvider = self.vendor.id
                        self.selectedAccountID = account.id
                        self.onActivateAccount(self.vendor.id, index)
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quaternary.opacity(0.35)))
    }
}

private struct DashboardAccountRow: View {
    let vendor: AIDashboardModel.Vendor
    let account: AIDashboardModel.Account
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: self.isSelected ? "checkmark.circle.fill" : "person.crop.circle")
                    .foregroundStyle(self.isSelected ? self.vendor.brandSwiftUIColor : .secondary)
                    .imageScale(.medium)
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.account.label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    if let detail = self.account.detail {
                        Text(detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                self.isSelected ? self.vendor.brandSwiftUIColor.opacity(0.16) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(self.account.detail ?? self.account.label)
        .accessibilityLabel(self.account.label)
    }
}

@MainActor
private struct DashboardDetail: View {
    let vendor: AIDashboardModel.Vendor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                self.header
                DashboardLimitOverview(vendor: self.vendor)
                DashboardAccountsSection(vendor: self.vendor)
                DashboardLimitsSection(vendor: self.vendor)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            LinearGradient(
                colors: [
                    self.vendor.brandSwiftUIColor.opacity(0.10),
                    Color(nsColor: .windowBackgroundColor),
                ],
                startPoint: .topLeading,
                endPoint: .center))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(self.vendor.brandSwiftUIColor)
                        .frame(width: 14, height: 14)
                    Text(self.vendor.name)
                        .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                }
                Text(self.vendor.sourceLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            DashboardStatusPill(tone: self.vendor.statusTone, text: self.vendor.statusLabel)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DashboardLimitOverview: View {
    let vendor: AIDashboardModel.Vendor

    var body: some View {
        HStack(spacing: 12) {
            DashboardHeroMetric(title: "Accounts", value: "\(self.vendor.accounts.count)")
            DashboardHeroMetric(title: "Context windows", value: "\(self.count(scope: .context))")
            DashboardHeroMetric(title: "Weekly limits", value: "\(self.count(scope: .weekly))")
            DashboardHeroMetric(title: "Monthly limits", value: "\(self.count(scope: .monthly))")
        }
    }

    private func count(scope: AIDashboardModel.Scope) -> Int {
        self.vendor.windows.count { $0.scope == scope }
    }
}

private struct DashboardHeroMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(self.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(self.value)
                .font(.title.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DashboardAccountsSection: View {
    let vendor: AIDashboardModel.Vendor

    var body: some View {
        DashboardSection(title: "Accounts") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 10)], spacing: 10) {
                ForEach(self.vendor.accounts) { account in
                    HStack(spacing: 8) {
                        Image(systemName: account.isActive ? "person.crop.circle.fill" : "person.crop.circle")
                            .foregroundStyle(self.vendor.brandSwiftUIColor)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(account.label)
                            if let detail = account.detail {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

private struct DashboardLimitsSection: View {
    let vendor: AIDashboardModel.Vendor

    var body: some View {
        DashboardSection(title: "Limits") {
            if self.vendor.windows.isEmpty {
                DashboardInlineEmptyState(text: self.vendor.error ?? "No limits have been loaded for this vendor yet.")
            } else {
                VStack(spacing: 10) {
                    ForEach(self.vendor.windows) { window in
                        DashboardLimitRow(window: window, color: self.vendor.brandSwiftUIColor)
                    }
                }
            }
        }
    }
}

private struct DashboardLimitRow: View {
    let window: AIDashboardModel.LimitWindow
    let color: Color

    private var progress: Double {
        max(0, min(1, self.window.usedPercent / 100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(self.window.title)
                            .font(.headline)
                        Text(self.window.scope.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.quaternary, in: Capsule())
                    }
                    Text(self.resetText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(self.window.usageKnown ? "\(Int(self.window.remainingPercent.rounded()))%" : "Unknown")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                    Text(self.window.usageKnown ? "remaining" : "usage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(self.fillColor)
                        .frame(width: max(8, proxy.size.width * self.progress))
                }
            }
            .frame(height: 8)
            .accessibilityLabel("\(self.window.title), \(Int(self.window.usedPercent.rounded())) percent used")
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var fillColor: Color {
        if !self.window.usageKnown { return .secondary.opacity(0.5) }
        if self.window.remainingPercent <= 10 { return .red }
        if self.window.remainingPercent <= 20 { return .orange }
        return self.color
    }

    private var resetText: String {
        if let resetDescription = self.window.resetDescription, !resetDescription.isEmpty {
            return resetDescription
        }
        if let resetsAt = self.window.resetsAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return "Resets \(formatter.localizedString(for: resetsAt, relativeTo: Date()))"
        }
        return "Reset time unavailable"
    }
}

private struct DashboardStatusPill: View {
    let tone: AIDashboardModel.Tone
    let text: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: self.symbolName)
            Text(self.text)
        }
        .font(.callout.weight(.medium))
        .foregroundStyle(self.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(self.color.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        switch self.tone {
        case .good: .green
        case .warning: .orange
        case .critical: .red
        case .neutral: .secondary
        }
    }

    private var symbolName: String {
        switch self.tone {
        case .good: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .critical: "xmark.octagon.fill"
        case .neutral: "circle.dashed"
        }
    }
}

private struct DashboardSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(self.title)
                .font(.title3.weight(.semibold))
            self.content
        }
        .accessibilityElement(children: .contain)
    }
}

private struct DashboardInlineEmptyState: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .foregroundStyle(.secondary)
            Text(self.text)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DashboardEmptyState: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text("No AI vendors enabled")
                .font(.title3.weight(.semibold))
            Text("Enable providers in Settings to populate the dashboard.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AIDashboardModel.Vendor {
    var brandSwiftUIColor: Color {
        Color(red: self.brandColor.red, green: self.brandColor.green, blue: self.brandColor.blue)
    }
}
