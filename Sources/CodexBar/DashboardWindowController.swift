import AppKit
import CodexBarCore
import SwiftUI

@MainActor
final class DashboardWindowController: NSWindowController, NSWindowDelegate {
    init(
        store: UsageStore,
        onActivateAccount: @escaping (UsageProvider, Int) -> Void)
    {
        let hostingController = NSHostingController(
            rootView: AIDashboardView(
                store: store,
                onActivateAccount: onActivateAccount))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "AI Usage Dashboard"
        window.setContentSize(NSSize(width: 1180, height: 760))
        window.minSize = NSSize(width: 980, height: 640)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        self.window?.centerIfNeeded()
        self.showWindow(nil)
        self.window?.makeKeyAndOrderFront(nil)
    }
}

extension NSWindow {
    func centerIfNeeded() {
        guard !self.isVisible else { return }
        self.center()
    }
}
