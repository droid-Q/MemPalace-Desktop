import SwiftUI

struct PalaceView: View {
    @EnvironmentObject var memPalaceService: MemPalaceService
    @EnvironmentObject var appState: AppState
    @State private var selectedWing: MemPalaceService.Wing?
    @State private var showingWakeUpSheet: Bool = false
    @State private var showingSearchSheet: Bool = false
    @State private var showingTimelineSheet: Bool = false
    @State private var showingExportSheet: Bool = false
    @State private var sidebarWidth: CGFloat = 180

    private let minSidebarWidth: CGFloat = 150
    private let maxSidebarWidth: CGFloat = 350
    private let dividerWidth: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Wings list
                List(selection: $selectedWing) {
                    ForEach(memPalaceService.wings) { wing in
                        WingRow(wing: wing)
                            .tag(wing)
                    }
                }
                .listStyle(.sidebar)
                .frame(width: sidebarWidth)
                .clipped()

                // Draggable divider
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: dividerWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newWidth = sidebarWidth + value.translation.width
                                sidebarWidth = min(max(newWidth, minSidebarWidth), maxSidebarWidth)
                            }
                            .onEnded { _ in
                                UserDefaults.standard.set(sidebarWidth, forKey: "palaceSidebarWidth")
                            }
                    )
                    .onAppear {
                        if let saved = UserDefaults.standard.object(forKey: "palaceSidebarWidth") as? CGFloat {
                            sidebarWidth = saved
                        }
                    }

                // Detail view
                if let wing = selectedWing {
                    WingDetailView(wing: wing, onSearch: {
                        showingSearchSheet = true
                    }, onTimeline: {
                        showingTimelineSheet = true
                    }, onExport: {
                        showingExportSheet = true
                    })
                    .frame(minWidth: 400)
                } else {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "building.columns")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Select a wing to view details")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingWakeUpSheet = true
                } label: {
                    Label("Wake Up", systemImage: "sun.max")
                }

                Button {
                    memPalaceService.listWings()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showingWakeUpSheet) {
            WakeUpSheet()
        }
        .sheet(isPresented: $showingSearchSheet) {
            if let wing = selectedWing {
                SearchInWingSheet(wingName: wing.name)
            }
        }
        .sheet(isPresented: $showingTimelineSheet) {
            if let wing = selectedWing {
                TimelineSheet(wingName: wing.name)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let wing = selectedWing {
                ExportSheet(wingName: wing.name)
            }
        }
    }
}

struct WingRow: View {
    let wing: MemPalaceService.Wing

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "building.columns.fill")
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(wing.name)
                    .font(.body)
                Text("\(wing.roomCount) rooms")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WingDetailView: View {
    let wing: MemPalaceService.Wing
    @EnvironmentObject var memPalaceService: MemPalaceService
    let onSearch: () -> Void
    let onTimeline: () -> Void
    let onExport: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(wing.name)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 20) {
                        StatBox(title: "Rooms", value: "\(wing.roomCount)", icon: "door.left.hand.closed")
                        StatBox(title: "Drawers", value: "\(wing.drawerCount)", icon: "tray.full")
                    }
                }
                .padding()

                Divider()

                // Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Actions")
                        .font(.headline)

                    HStack(spacing: 12) {
                        ActionButton(title: "Search in Wing", icon: "magnifyingglass", action: onSearch)
                        ActionButton(title: "View Timeline", icon: "clock", action: onTimeline)
                        ActionButton(title: "Export", icon: "square.and.arrow.up", action: onExport)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search In Wing Sheet
struct SearchInWingSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    let wingName: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Search in \(wingName)")
                .font(.headline)

            HStack {
                TextField("Search query...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        performSearch()
                    }

                Button("Search") {
                    performSearch()
                }
                .disabled(searchText.isEmpty || isSearching)
            }

            if isSearching {
                ProgressView()
            }

            Button("Close") {
                dismiss()
            }
        }
        .padding(24)
        .frame(width: 450, height: 300)
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        memPalaceService.search(query: searchText, scope: wingName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSearching = false
            dismiss()
        }
    }
}

// MARK: - Timeline Sheet
struct TimelineSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var timelineData: [String] = []
    @State private var isLoading: Bool = false
    let wingName: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Timeline: \(wingName)")
                .font(.headline)

            if isLoading {
                ProgressView()
            } else if timelineData.isEmpty {
                Text("No timeline data available")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(timelineData, id: \.self) { item in
                            Text(item)
                                .font(.body)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)
            }

            Button("Close") {
                dismiss()
            }
        }
        .padding(24)
        .frame(width: 500, height: 500)
        .onAppear {
            loadTimeline()
        }
    }

    private func loadTimeline() {
        isLoading = true
        // TODO: Call mempalace timeline command when available
        // For now, simulate with sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            timelineData = [
                "2024-01-15: Wing created",
                "2024-01-20: 100 memories added",
                "2024-02-01: Major reorganization",
                "2024-02-15: 500 memories milestone"
            ]
            isLoading = false
        }
    }
}

// MARK: - Export Sheet
struct ExportSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var exportFormat: String = "json"
    @State private var isExporting: Bool = false
    @State private var exportPath: String = ""
    let wingName: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Export \(wingName)")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Format")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Format", selection: $exportFormat) {
                    Text("JSON").tag("json")
                    Text("Markdown").tag("md")
                    Text("Plain Text").tag("txt")
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Output Path")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    TextField("~/Exports/\(wingName).\(exportFormat)", text: $exportPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse...") {
                        browsePath()
                    }
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Button {
                    exportData()
                } label: {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Export")
                    }
                }
                .disabled(isExporting)
            }
        }
        .padding(24)
        .frame(width: 450)
    }

    private func browsePath() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(wingName).\(exportFormat)"
        if panel.runModal() == .OK, let url = panel.url {
            exportPath = url.path
        }
    }

    private func exportData() {
        isExporting = true
        let path = exportPath.isEmpty ? "~/Exports/\(wingName).\(exportFormat)" : exportPath
        memPalaceService.exportWing(name: wingName, format: exportFormat, to: path)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isExporting = false
            dismiss()
        }
    }
}

struct WakeUpSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var scope: String = ""
    @State private var isWaking: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Wake Up Memory")
                .font(.headline)

            Text("Load relevant context from your palace for this session")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                Text("Scope (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("wing:project-name or leave empty for all", text: $scope)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button {
                    wakeUp()
                } label: {
                    if isWaking {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Wake Up")
                    }
                }
                .disabled(isWaking)
            }
        }
        .padding(24)
        .frame(width: 350)
    }

    private func wakeUp() {
        isWaking = true
        let scopeParam = scope.isEmpty ? nil : scope
        memPalaceService.wakeUp(scope: scopeParam)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isWaking = false
            dismiss()
        }
    }
}
