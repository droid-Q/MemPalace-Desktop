import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var palacePath: String = "~/.mempalace/palace"
    @State private var autoSave: Bool = true
    @State private var saveInterval: Int = 15
    @State private var showHiddenFiles: Bool = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("MemPalace CLI")
                        Spacer()
                        if memPalaceService.isInstalled {
                            Label("Installed", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Not Found", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }

                    if !memPalaceService.isInstalled {
                        Button("Install MemPalace") {
                            installMemPalace()
                        }
                    }
                }
            } header: {
                Text("Installation")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Palace Path")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("~/.mempalace/palace", text: $palacePath)
                            .textFieldStyle(.roundedBorder)
                        Button("Browse...") {
                            browsePalacePath()
                        }
                    }
                }

                Text("Where your memories are stored")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } header: {
                Text("Storage")
            }

            Section {
                Toggle("Auto-save with Claude Code hooks", isOn: $autoSave)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Save Interval")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("", selection: $saveInterval) {
                        Text("5 messages").tag(5)
                        Text("10 messages").tag(10)
                        Text("15 messages").tag(15)
                        Text("25 messages").tag(25)
                        Text("50 messages").tag(50)
                    }
                    .pickerStyle(.menu)
                }

                Text("How often to save memories during Claude Code sessions")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } header: {
                Text("Behavior")
            }

            Section {
                Button("Open Hooks Directory") {
                    openHooksDirectory()
                }

                Button("View Documentation") {
                    openDocs()
                }
            } header: {
                Text("Advanced")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Repair Palace") {
                        repairPalace()
                    }

                    Button("Export Data...") {
                        exportData()
                    }
                }
            } header: {
                Text("Maintenance")
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        palacePath = UserDefaults.standard.string(forKey: "palacePath") ?? "~/.mempalace/palace"
        autoSave = UserDefaults.standard.bool(forKey: "autoSave")
        saveInterval = UserDefaults.standard.integer(forKey: "saveInterval")
        if saveInterval == 0 { saveInterval = 15 }
    }

    private func browsePalacePath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            palacePath = url.path
            UserDefaults.standard.set(palacePath, forKey: "palacePath")
        }
    }

    private func installMemPalace() {
        if let url = URL(string: "https://github.com/MemPalace/mempalace") {
            NSWorkspace.shared.open(url)
        }
    }

    private func openHooksDirectory() {
        let path = "/Users/droid/Documents/git-repository/mempalace-repo/hooks"
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    private func openDocs() {
        if let url = URL(string: "https://mempalaceofficial.com") {
            NSWorkspace.shared.open(url)
        }
    }

    private func repairPalace() {
        memPalaceService.repair()
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "mempalace-export.json"
        if panel.runModal() == .OK, let url = panel.url {
            memPalaceService.export(to: url.path)
        }
    }
}
