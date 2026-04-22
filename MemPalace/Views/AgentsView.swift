import SwiftUI

struct AgentsView: View {
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var selectedAgent: MemPalaceService.Agent?

    var body: some View {
        HSplitView {
            // Agents list
            List(selection: $selectedAgent) {
                if memPalaceService.agents.isEmpty {
                    Text("No agents found")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(memPalaceService.agents) { agent in
                        AgentRow(agent: agent)
                            .tag(agent)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            .onAppear {
                memPalaceService.listAgents()
            }

            // Detail view
            if let agent = selectedAgent {
                AgentDetailView(agent: agent)
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "person.3")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Select an agent to view details")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    memPalaceService.listAgents()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
    }
}

struct AgentRow: View {
    let agent: MemPalaceService.Agent

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 32, height: 32)
                Text(String(agent.name.prefix(1)))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(.body)
                Text(agent.wing)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AgentDetailView: View {
    let agent: MemPalaceService.Agent
    @EnvironmentObject var memPalaceService: MemPalaceService
    @State private var agentMemory: [MemPalaceService.SearchResult] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 64, height: 64)
                            Text(String(agent.name.prefix(1)))
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(agent.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Label(agent.wing, systemImage: "building.columns")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text("Agent memories and diary entries")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()

                Divider()

                // Search agent's memories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Memories")
                        .font(.headline)

                    Button {
                        searchAgentMemories()
                    } label: {
                        Label("Load Memories", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)

                    if !agentMemory.isEmpty {
                        ForEach(agentMemory) { memory in
                            MemoryCard(memory: memory)
                        }
                    }
                }
                .padding()

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func searchAgentMemories() {
        memPalaceService.search(query: "agent:\(agent.name)", scope: "wing:\(agent.wing)")
        // In real implementation, filter results for this agent
    }
}

struct MemoryCard: View {
    let memory: MemPalaceService.SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(memory.content)
                .font(.body)
                .lineLimit(4)

            HStack {
                Label(memory.room, systemImage: "door.left.hand.closed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.0f%% match", memory.relevance * 100))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(8)
    }
}
