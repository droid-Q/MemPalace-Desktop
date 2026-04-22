import SwiftUI

struct SearchView: View {
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var searchText: String = ""
    @State private var selectedScope: String = ""
    @State private var isSearching: Bool = false
    @State private var showingMineSheet: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search memories...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            performSearch()
                        }
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(10)

                Button("Search") {
                    performSearch()
                }
                .keyboardShortcut(.return)

                Button {
                    showingMineSheet = true
                } label: {
                    Label("Mine", systemImage: "plus.circle")
                }
            }
            .padding()

            Divider()

            // Results
            if isSearching {
                Spacer()
                ProgressIndicator()
                Spacer()
            } else if memPalaceService.searchResults.isEmpty {
                EmptySearchView()
            } else {
                SearchResultsList(results: memPalaceService.searchResults)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingMineSheet) {
            MineDirectorySheet()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newSearch)) { _ in
            searchText = ""
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        let scope = selectedScope.isEmpty ? nil : selectedScope
        memPalaceService.search(query: searchText, scope: scope)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSearching = false
        }
    }
}

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "brain")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Search Your Memory Palace")
                .font(.title2)
                .fontWeight(.medium)
            Text("Find past conversations, decisions, and project context")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchResultsList: View {
    let results: [MemPalaceService.SearchResult]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(results) { result in
                    SearchResultRow(result: result)
                }
            }
            .padding()
        }
    }
}

struct SearchResultRow: View {
    let result: MemPalaceService.SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(result.wing, systemImage: "building.columns")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.0f%%", result.relevance * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(4)
            }

            Text(result.content)
                .font(.body)
                .lineLimit(4)
                .foregroundStyle(.primary)

            HStack {
                Label(result.room, systemImage: "door.left.hand.closed")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(8)
    }
}

struct MineDirectorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var selectedPath: String = ""
    @State private var mode: String = "auto"
    @State private var wing: String = ""
    @State private var isMining: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Mine Directory")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Directory Path")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    TextField("~/Projects/MyApp", text: $selectedPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse...") {
                        browseDirectory()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Mode")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Mode", selection: $mode) {
                    Text("Auto").tag("auto")
                    Text("Conversations").tag("convos")
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Wing (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("project-name", text: $wing)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button {
                    mineDirectory()
                } label: {
                    if isMining {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Mine")
                    }
                }
                .disabled(selectedPath.isEmpty || isMining)
            }
        }
        .padding(24)
        .frame(width: 450)
    }

    private func browseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            selectedPath = url.path
        }
    }

    private func mineDirectory() {
        isMining = true
        let wingParam = wing.isEmpty ? nil : wing
        memPalaceService.mine(path: selectedPath, mode: mode, wing: wingParam)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isMining = false
            dismiss()
        }
    }
}

struct ProgressIndicator: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
