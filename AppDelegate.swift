import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
            .environmentObject(MemPalaceService.shared)
            .environmentObject(AppState.shared)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.setFrameAutosaveName("MemPalace Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = "MemPalace"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .visible
        window.minSize = NSSize(width: 700, height: 500)
        window.makeKeyAndOrderFront(nil)

        // Setup menu
        setupMainMenu()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func showInstallationAlert() {
        let alert = NSAlert()
        alert.messageText = "MemPalace Not Found"
        alert.informativeText = "MemPalace CLI is not installed. Would you like to install it?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "https://github.com/MemPalace/mempalace") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About MemPalace", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit MemPalace", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "New Search", action: #selector(newSearch), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Mine Directory...", action: #selector(mineDirectory), keyEquivalent: "m")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")

        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // View menu
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu
        viewMenu.addItem(withTitle: "Refresh", action: #selector(refresh), keyEquivalent: "r")

        // Help menu
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        helpMenu.addItem(withTitle: "MemPalace Help", action: #selector(showHelp), keyEquivalent: "?")

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc func newSearch() {
        NotificationCenter.default.post(name: .newSearch, object: nil)
    }

    @objc func mineDirectory() {
        NotificationCenter.default.post(name: .mineDirectory, object: nil)
    }

    @objc func refresh() {
        NotificationCenter.default.post(name: .refreshData, object: nil)
    }

    @objc func showHelp() {
        if let url = URL(string: "https://mempalaceofficial.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

extension Notification.Name {
    static let newSearch = Notification.Name("newSearch")
    static let mineDirectory = Notification.Name("mineDirectory")
    static let refreshData = Notification.Name("refreshData")
}
