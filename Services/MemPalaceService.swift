import Foundation
import Combine

class MemPalaceService: ObservableObject {
    static let shared = MemPalaceService()

    @Published var isInstalled: Bool = false
    @Published var palacePath: String = ""
    @Published var wings: [Wing] = []
    @Published var agents: [Agent] = []
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    private var processRunner = ProcessRunner()

    struct Wing: Identifiable, Codable, Hashable {
        let id: String
        let name: String
        let roomCount: Int
        let drawerCount: Int
    }

    struct Agent: Identifiable, Codable, Hashable {
        let id: String
        let name: String
        let wing: String
    }

    struct SearchResult: Identifiable, Codable {
        let id: String
        let content: String
        let wing: String
        let room: String
        let relevance: Double

        init(id: String = UUID().uuidString, content: String, wing: String, room: String, relevance: Double) {
            self.id = id
            self.content = content
            self.wing = wing
            self.room = room
            self.relevance = relevance
        }
    }

    func checkInstallation(completion: @escaping (Bool) -> Void) {
        runCommand("mempalace", arguments: ["status"]) { [weak self] output, error in
            DispatchQueue.main.async {
                let outputStr = output.trimmingCharacters(in: .whitespacesAndNewlines)
                // mempalace status 成功时会输出包含 "palace" 的信息
                self?.isInstalled = error == nil && !outputStr.isEmpty && outputStr.lowercased().contains("palace")
                completion(self?.isInstalled ?? false)
            }
        }
    }

    func getPalaceInfo() {
        runCommand("mempalace", arguments: ["stats", "--json"]) { [weak self] output, error in
            DispatchQueue.main.async {
                if let data = output.data(using: .utf8) {
                    // Parse stats output
                    self?.palacePath = "~/.mempalace/palace" // Default
                }
            }
        }
    }

    func listWings() {
        isLoading = true
        runCommand("mempalace", arguments: ["status"]) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.wings = self?.parseWingsFromStatus(output) ?? []
            }
        }
    }

    func search(query: String, scope: String? = nil) {
        isLoading = true
        var args = ["search", query, "--json"]
        if let scope = scope {
            args.append("--scope")
            args.append(scope)
        }

        runCommand("mempalace", arguments: args) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = output.data(using: .utf8) {
                    do {
                        // Try JSON parsing first
                        self?.searchResults = try JSONDecoder().decode([SearchResult].self, from: data)
                    } catch {
                        // Fallback to text results
                        self?.searchResults = self?.parseSearchFromText(output) ?? []
                    }
                }
                if let error = error {
                    self?.lastError = error
                }
            }
        }
    }

    func mine(path: String, mode: String = "auto", wing: String? = nil) {
        isLoading = true
        var args = ["mine", path]
        if mode == "convos" {
            args.append("--mode")
            args.append("convos")
        }
        if let wing = wing {
            args.append("--wing")
            args.append(wing)
        }

        runCommand("mempalace", arguments: args) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.lastError = error
                }
            }
        }
    }

    func wakeUp(scope: String? = nil) {
        isLoading = true
        var args = ["wake-up"]
        if let scope = scope {
            args.append("--scope")
            args.append(scope)
        }

        runCommand("mempalace", arguments: args) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }

    func listAgents() {
        runCommand("mempalace", arguments: ["list-agents", "--json"]) { [weak self] output, error in
            DispatchQueue.main.async {
                if let data = output.data(using: .utf8) {
                    do {
                        self?.agents = try JSONDecoder().decode([Agent].self, from: data)
                    } catch {
                        self?.agents = []
                    }
                }
            }
        }
    }

    func kgQuery(entity: String) {
        runCommand("mempalace", arguments: ["kg", "query", entity, "--json"]) { [weak self] output, error in
            DispatchQueue.main.async {
                // Parse KG results
            }
        }
    }

    func repair() {
        isLoading = true
        runCommand("mempalace", arguments: ["repair"]) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }

    func export(to path: String) {
        isLoading = true
        runCommand("mempalace", arguments: ["export", "--output", path]) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }

    func exportWing(name: String, format: String, to path: String) {
        isLoading = true
        runCommand("mempalace", arguments: ["export", "--wing", name, "--format", format, "--output", path]) { [weak self] output, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }

    // MARK: - Private

    private func runCommand(_ command: String, arguments: [String], completion: @escaping (String, String?) -> Void) {
        processRunner.run(command: command, arguments: arguments) { output, error in
            completion(output, error)
        }
    }

    private func parseWingsFromStatus(_ text: String) -> [Wing] {
        var wings: [Wing] = []
        var currentWingName: String = ""
        var currentWingRooms: Int = 0

        let lines = text.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Check for WING: header
            if trimmed.hasPrefix("WING:") {
                // Save previous wing if exists
                if !currentWingName.isEmpty {
                    wings.append(Wing(id: currentWingName, name: currentWingName, roomCount: currentWingRooms, drawerCount: 0))
                }
                currentWingName = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                currentWingRooms = 0
            }
            // Check for ROOM: line
            else if trimmed.hasPrefix("ROOM:") {
                currentWingRooms += 1
            }
        }

        // Don't forget the last wing
        if !currentWingName.isEmpty {
            wings.append(Wing(id: currentWingName, name: currentWingName, roomCount: currentWingRooms, drawerCount: 0))
        }

        return wings
    }

    private func parseSearchFromText(_ text: String) -> [SearchResult] {
        return text.components(separatedBy: "\n\n")
            .filter { !$0.isEmpty }
            .enumerated()
            .map { index, block in
                let lines = block.components(separatedBy: "\n")
                return SearchResult(
                    id: "\(index)",
                    content: lines.first ?? block,
                    wing: lines.count > 1 ? lines[1] : "",
                    room: lines.count > 2 ? lines[2] : "",
                    relevance: 0.8
                )
            }
    }
}
