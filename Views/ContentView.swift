import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var memPalaceService: MemPalaceService

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DetailView()
        }
        .frame(minWidth: 700, minHeight: 500)
        .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
            refreshData()
        }
        .task {
            checkAndLoadData()
        }
    }

    private func checkAndLoadData() {
        memPalaceService.checkInstallation { installed in
            if installed {
                memPalaceService.getPalaceInfo()
                memPalaceService.listWings()
            }
        }
    }

    private func refreshData() {
        memPalaceService.listWings()
        memPalaceService.listAgents()
    }
}

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(selection: $appState.selectedTab) {
            Section("Memory") {
                Label("Search", systemImage: "magnifyingglass")
                    .tag(AppState.AppTab.search)
                Label("Palace", systemImage: "building.columns")
                    .tag(AppState.AppTab.palace)
            }

            Section("Agents") {
                Label("Agents", systemImage: "person.3")
                    .tag(AppState.AppTab.agents)
            }

            Section("System") {
                Label("Settings", systemImage: "gearshape")
                    .tag(AppState.AppTab.settings)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }
}

struct DetailView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.selectedTab {
            case .search:
                SearchView()
            case .palace:
                PalaceView()
            case .agents:
                AgentsView()
            case .settings:
                SettingsView()
            }
        }
    }
}
