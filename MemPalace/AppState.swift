import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var selectedTab: AppTab = .search
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = "Ready"

    enum AppTab: String, CaseIterable, Hashable {
        case search = "Search"
        case palace = "Palace"
        case agents = "Agents"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .search: return "magnifyingglass"
            case .palace: return "building.columns"
            case .agents: return "person.3"
            case .settings: return "gearshape"
            }
        }
    }
}
