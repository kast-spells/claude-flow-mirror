# Code Navigation Guide - Claude-Flow

**Quick Reference for Finding Your Way Through the Codebase**

Version: 2.7.34 | Last Updated: 2025-11-18

---

## 📖 Purpose

This guide helps you quickly locate specific functionality in the claude-flow codebase. Use it as a **quick reference** when you need to find where something is implemented.

---

## 📂 Directory Structure Overview

```
claude-flow/
├── bin/                      # Executable binaries
│   └── claude-flow.js       # Main CLI entry point
├── src/                      # Source code (TypeScript)
│   ├── cli/                 # Command-line interface
│   ├── mcp/                 # MCP server implementation
│   ├── core/                # Core orchestration logic
│   ├── coordination/        # Swarm/hive coordination
│   ├── execution/           # Agent execution
│   ├── memory/              # Memory management
│   ├── neural/              # Neural components
│   ├── hooks/               # Hook system (legacy)
│   ├── services/            # Services (hooks, process mgmt)
│   ├── task/                # Task management
│   ├── workflows/           # Workflow automation
│   ├── agents/              # Agent definitions
│   ├── modes/               # SPARC modes
│   ├── config/              # Configuration management
│   ├── types/               # TypeScript type definitions
│   └── utils/               # Utility functions
├── tests/                    # Test suites
├── docs/                     # Documentation
├── examples/                 # Example projects
└── .claude-flow/            # Runtime directory (created at init)
```

---

## 🎯 Finding Functionality

### "I want to find..."

#### **CLI Commands**
**Location:** `src/cli/`

| What | File | Key Function/Class |
|------|------|-------------------|
| Main CLI entry | `src/cli/main.ts` | `main()` |
| CLI routing | `src/cli/simple-cli.ts` | `CLI` class |
| Command registry | `src/cli/commands/` | Individual command files |
| Agent commands | `src/cli/commands/agent.ts` | `AgentCommand` |
| Swarm commands | `src/cli/commands/swarm.ts` | `SwarmCommand` |
| Memory commands | `src/cli/commands/memory.ts` | `MemoryCommand` |
| SPARC commands | `src/cli/commands/sparc.ts` | `SparcCommand` |

**Example:** To understand how `claude-flow agent spawn` works:
1. Start: `src/cli/simple-cli.ts` (routing)
2. Then: `src/cli/commands/agent.ts` (command handler)
3. Finally: `src/execution/agent-executor.ts` (execution logic)

---

#### **MCP Server**
**Location:** `src/mcp/`

| What | File | Description |
|------|------|-------------|
| MCP server main | `src/mcp/server.ts` | Main server implementation |
| Tool registry | `src/mcp/tools/` | All MCP tool implementations |
| Tool schemas | `src/mcp/schemas/` | JSON Schema definitions |
| In-process server | `src/mcp/in-process-server.ts` | High-performance variant |

**Key Tools:**
- Agent management: `src/mcp/tools/agent-tools.ts`
- Task management: `src/mcp/tools/task-tools.ts`
- Memory operations: `src/mcp/tools/memory-tools.ts`
- System monitoring: `src/mcp/tools/monitoring-tools.ts`

---

#### **Orchestration & Coordination**
**Location:** `src/core/`, `src/coordination/`

| What | File | Lines | Description |
|------|------|-------|-------------|
| Main orchestrator | `src/core/orchestrator.ts` | 1,440 | Central coordinator |
| Swarm coordinator | `src/coordination/swarm-coordinator.ts` | 761 | Multi-agent coordination |
| Hive orchestrator | `src/coordination/hive-orchestrator.ts` | 400+ | Hive-mind coordination |
| Task decomposition | `src/task/index.ts` | 388 | Task breakdown logic |
| Advanced scheduler | `src/coordination/advanced-scheduler.ts` | 300+ | Priority queue scheduling |

**Flow:**
```
CLI Command
  → src/cli/simple-cli.ts
    → src/core/orchestrator.ts
      → src/coordination/swarm-coordinator.ts
        → src/execution/agent-executor.ts
```

---

#### **Agent Execution**
**Location:** `src/execution/`

| What | File | Description |
|------|------|-------------|
| Agent lifecycle | `src/execution/agent-executor.ts` | Spawn, run, terminate agents |
| Terminal pooling | `src/execution/terminal-pool.ts` | Pre-allocated terminals |
| Process management | `src/services/process.ts` | Subprocess handling |
| Agent profiles | `src/agents/` | Agent type definitions |

**Agent Spawn Flow:**
1. `AgentExecutor.spawnAgent()` - src/execution/agent-executor.ts
2. `TerminalPool.acquire()` - src/execution/terminal-pool.ts
3. `ProcessManager.spawn()` - src/services/process.ts
4. Hook execution: src/services/agentic-flow-hooks/

---

#### **Memory & State**
**Location:** `src/memory/`

| What | File | Description |
|------|------|-------------|
| Memory manager | `src/memory/manager.ts` (560 lines) | Main memory interface |
| SQLite backend | `src/memory/backends/sqlite.ts` | SQLite implementation |
| Markdown backend | `src/memory/backends/markdown.ts` | Markdown backup |
| Hybrid backend | `src/memory/backends/hybrid.ts` | Combined SQLite + Markdown |
| AgentDB adapter | `src/memory/agentdb-adapter.ts` | Vector database integration |
| ReasoningBank | `src/reasoningbank/` | Adaptive learning |

**Memory Operations:**
```typescript
// Store memory
MemoryManager.store(key, value, metadata)
  → HybridBackend.store()
    → SQLiteBackend.insert() + MarkdownBackend.append()

// Query memory
MemoryManager.query(query)
  → AgentDBAdapter.semanticSearch()
    → AgentDB vector search
```

---

#### **Hooks System**
**Location:** `src/services/agentic-flow-hooks/`, `src/hooks/` (legacy)

| What | File | Description |
|------|------|-------------|
| Hook registry | `src/services/agentic-flow-hooks/index.ts` | Main hook manager |
| Pattern matching | `src/services/agentic-flow-hooks/matcher.ts` | Pattern-based routing |
| Pre-task hooks | `src/services/agentic-flow-hooks/patterns/pre-task.ts` | Before task execution |
| Post-task hooks | `src/services/agentic-flow-hooks/patterns/post-task.ts` | After task completion |
| Edit hooks | `src/services/agentic-flow-hooks/patterns/post-edit.ts` | After file edits |
| LLM hooks | `src/services/agentic-flow-hooks/patterns/llm-hooks.ts` | LLM call interception |

**Hook Execution Flow:**
```
Operation triggered
  → HookManager.executeHooks('pre-<operation>')
    → Pattern matching
      → Hook execution (parallel for post-hooks)
        → HookManager.executeHooks('post-<operation>')
```

---

#### **SPARC Methodology**
**Location:** `src/modes/`

| What | File | Description |
|------|------|-------------|
| SPARC initialization | `src/modes/SparcInit.ts` (254 lines) | Mode setup |
| Specification phase | `src/modes/specification.ts` | Requirements gathering |
| Pseudocode phase | `src/modes/pseudocode.ts` | Algorithm design |
| Architecture phase | `src/modes/architecture.ts` | System design |
| Refinement phase | `src/modes/refinement.ts` | TDD implementation |
| Completion phase | `src/modes/completion.ts` | Integration |
| TDD workflow | `src/workflows/tdd-workflow.ts` | Red-Green-Refactor |

**SPARC Execution:**
```
claude-flow sparc tdd "feature"
  → src/cli/commands/sparc.ts
    → src/modes/SparcInit.ts
      → Phase execution (Spec → Pseudo → Arch → Refine → Complete)
        → src/workflows/tdd-workflow.ts (for Refinement)
```

---

#### **Neural Components**
**Location:** `src/neural/`

| What | File | Description |
|------|------|-------------|
| Neural manager | `src/neural/manager.ts` | Neural system coordinator |
| GNN analysis | `src/neural/gnn-analyzer.ts` | Graph neural network |
| Domain mapping | `src/neural/domain-mapper.ts` | Domain cohesion analysis |
| Pattern learning | `src/neural/pattern-learner.ts` | Pattern extraction |
| Training pipeline | `src/neural/training.ts` | Model training |

---

#### **Configuration**
**Location:** `src/config/`, `.claude-flow/config.json`

| What | File | Description |
|------|------|-------------|
| Config loader | `src/config/loader.ts` | Load and merge config |
| Config validator | `src/config/validator.ts` | JSON Schema validation |
| Default config | `src/config/defaults.ts` | Default values |
| Config schema | `src/config/schema.ts` | TypeScript types |

**Configuration Hierarchy:**
1. Defaults: `src/config/defaults.ts`
2. User config: `.claude-flow/config.json`
3. Environment variables: `process.env.*`
4. CLI arguments: Command-line flags

---

#### **External Integrations**
**Location:** `src/integration/`, `src/providers/`

| What | File | Description |
|------|------|-------------|
| GitHub integration | `src/integration/github/` | PR, issues, code review |
| Docker integration | `src/integration/docker/` | Container management |
| agentic-flow adapter | `src/providers/agentic-flow-adapter.ts` | Multi-provider AI |
| ruv-swarm adapter | `src/providers/ruv-swarm-adapter.ts` | Consensus protocols |
| flow-nexus adapter | `src/providers/flow-nexus-adapter.ts` | Cloud deployment |

---

## 🔍 Common Development Tasks

### "I want to add a new CLI command"

1. Create command file: `src/cli/commands/my-command.ts`
2. Implement command class extending base command
3. Register in `src/cli/simple-cli.ts`
4. Add tests in `tests/cli/commands/my-command.test.ts`

**Example:**
```typescript
// src/cli/commands/my-command.ts
import { Command } from '../base-command.js';

export class MyCommand extends Command {
  async execute(args: string[]): Promise<void> {
    // Implementation
  }
}

// src/cli/simple-cli.ts
import { MyCommand } from './commands/my-command.js';

this.commands.set('my-command', new MyCommand());
```

---

### "I want to add a new MCP tool"

1. Create tool file: `src/mcp/tools/my-tool.ts`
2. Define JSON schema for inputs
3. Implement tool handler function
4. Register in `src/mcp/server.ts`

**Example:**
```typescript
// src/mcp/tools/my-tool.ts
export const myToolSchema = {
  type: 'object',
  properties: {
    param: { type: 'string' }
  },
  required: ['param']
};

export async function handleMyTool(params: any): Promise<any> {
  // Implementation
}

// src/mcp/server.ts
import { handleMyTool, myToolSchema } from './tools/my-tool.js';

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    // ...existing tools,
    { name: 'my_tool', description: '...', inputSchema: myToolSchema }
  ]
}));
```

---

### "I want to add a custom hook"

1. Create hook file: `src/services/agentic-flow-hooks/patterns/my-hook.ts`
2. Implement hook handler
3. Register pattern in `src/services/agentic-flow-hooks/index.ts`

**Example:**
```typescript
// src/services/agentic-flow-hooks/patterns/my-hook.ts
export async function myHook(context: HookContext): Promise<void> {
  // Pre-processing
  await context.next();
  // Post-processing
}

// src/services/agentic-flow-hooks/index.ts
hookManager.registerPattern('my-hook', myHook);
```

---

### "I want to add a new agent type"

1. Create agent profile: `.claude/agents/my-agent.md`
2. Define capabilities and specialization
3. Agent auto-discovered by system

**Example:**
```markdown
<!-- .claude/agents/my-agent.md -->
---
name: my-agent
specialization: My specialized task
capabilities:
  - capability1
  - capability2
---

# My Agent

Description and system prompt for the agent...
```

---

## 🗺️ Code Flow Maps

### CLI Request Flow

```
bin/claude-flow.js (dispatcher)
  ↓
src/cli/main.ts (entry point)
  ↓
src/cli/simple-cli.ts (routing)
  ↓
src/cli/commands/*.ts (command handler)
  ↓
src/core/orchestrator.ts (orchestration)
  ↓
src/coordination/swarm-coordinator.ts (coordination)
  ↓
src/execution/agent-executor.ts (execution)
```

---

### MCP Tool Call Flow

```
MCP Client (Claude Desktop, etc.)
  ↓
src/mcp/server.ts (MCP server)
  ↓
src/mcp/tools/*.ts (tool handler)
  ↓
src/core/orchestrator.ts (business logic)
  ↓
Result returned via MCP protocol
```

---

### Memory Write Flow

```
Component calls MemoryManager.store()
  ↓
src/memory/manager.ts (interface)
  ↓
src/memory/backends/hybrid.ts (backend)
  ↓
├─ src/memory/backends/sqlite.ts (persistent)
└─ src/memory/backends/markdown.ts (backup)
  ↓
src/memory/agentdb-adapter.ts (vector indexing)
```

---

### Hook Execution Flow

```
Operation triggered (e.g., task start)
  ↓
src/services/agentic-flow-hooks/index.ts
  ↓
Pattern matching (src/services/agentic-flow-hooks/matcher.ts)
  ↓
├─ Pre-hooks (sequential)
│  ↓
│  Operation executes
│  ↓
└─ Post-hooks (parallel)
   ├─ Neural training
   ├─ Metrics collection
   ├─ Cache updates
   └─ Notifications
```

---

## 📝 File Naming Conventions

- **Commands:** `<noun>.ts` (e.g., `agent.ts`, `swarm.ts`)
- **Services:** `<noun>-<service>.ts` (e.g., `agent-executor.ts`)
- **Managers:** `<noun>-manager.ts` (e.g., `memory-manager.ts`)
- **Adapters:** `<system>-adapter.ts` (e.g., `agentdb-adapter.ts`)
- **Tests:** `<file-name>.test.ts` (mirrors source structure)
- **Types:** `<noun>.types.ts` or `types.ts` in directory
- **Utils:** `<function>.ts` (e.g., `logger.ts`, `validator.ts`)

---

## 🔎 Searching Tips

### Find by Functionality

```bash
# Find all agent-related files
find src -name "*agent*"

# Find all MCP tools
find src/mcp/tools -name "*.ts"

# Search for specific function
grep -r "spawnAgent" src/

# Find type definitions
grep -r "interface AgentConfig" src/
```

### Find by Pattern

```bash
# All command implementations
ls src/cli/commands/

# All MCP tool schemas
grep -r "Schema =" src/mcp/tools/

# All hook patterns
ls src/services/agentic-flow-hooks/patterns/

# All configuration files
find . -name "*.config.*" -o -name "tsconfig.json"
```

---

## 🎯 Key Files Quick Reference

### Most Important Files (Top 20)

| Rank | File | Lines | Purpose |
|------|------|-------|---------|
| 1 | `src/core/orchestrator.ts` | 1,440 | Central coordinator |
| 2 | `src/coordination/swarm-coordinator.ts` | 761 | Multi-agent coordination |
| 3 | `src/mcp/server.ts` | 647 | MCP protocol server |
| 4 | `src/memory/manager.ts` | 560 | Memory management |
| 5 | `src/coordination/hive-orchestrator.ts` | 400+ | Hive-mind coordination |
| 6 | `src/task/index.ts` | 388 | Task orchestration |
| 7 | `src/coordination/advanced-scheduler.ts` | 300+ | Task scheduling |
| 8 | `src/modes/SparcInit.ts` | 254 | SPARC initialization |
| 9 | `src/execution/agent-executor.ts` | 200+ | Agent execution |
| 10 | `src/services/process.ts` | 200+ | Process management |
| 11 | `src/cli/simple-cli.ts` | 150+ | CLI routing |
| 12 | `src/neural/gnn-analyzer.ts` | 150+ | Neural analysis |
| 13 | `src/memory/backends/hybrid.ts` | 150+ | Hybrid memory backend |
| 14 | `src/config/loader.ts` | 120+ | Configuration loading |
| 15 | `src/mcp/tools/agent-tools.ts` | 100+ | Agent MCP tools |
| 16 | `src/services/agentic-flow-hooks/index.ts` | 100+ | Hook system |
| 17 | `src/workflows/tdd-workflow.ts` | 100+ | TDD automation |
| 18 | `src/integration/github/pr-analyzer.ts` | 100+ | GitHub PR analysis |
| 19 | `src/execution/terminal-pool.ts` | 80+ | Terminal pooling |
| 20 | `bin/claude-flow.js` | 50+ | CLI entry point |

---

## 🧭 Navigation by Use Case

### Use Case: Understanding How Commands Work

1. Start: `bin/claude-flow.js` - See how CLI is invoked
2. Follow: `src/cli/main.ts` - Entry point
3. Then: `src/cli/simple-cli.ts` - Command routing
4. Finally: `src/cli/commands/<command>.ts` - Specific command

### Use Case: Understanding Agent Spawning

1. Start: `src/cli/commands/agent.ts` - Command handler
2. Follow: `src/core/orchestrator.ts` - Orchestration
3. Then: `src/coordination/swarm-coordinator.ts` - Coordination
4. Finally: `src/execution/agent-executor.ts` - Actual spawning

### Use Case: Understanding Memory System

1. Start: `src/memory/manager.ts` - Main interface
2. Follow: `src/memory/backends/hybrid.ts` - Backend implementation
3. Branches:
   - `src/memory/backends/sqlite.ts` - SQLite storage
   - `src/memory/backends/markdown.ts` - Markdown backup
   - `src/memory/agentdb-adapter.ts` - Vector search

### Use Case: Understanding MCP Tools

1. Start: `src/mcp/server.ts` - Server setup
2. Follow: `src/mcp/tools/<tool-category>.ts` - Tool implementations
3. Check: `src/mcp/schemas/` - Schema definitions

---

## 🔗 Cross-References

This navigation guide complements:

- **Architecture Overview** ([01-architecture-overview.md](./01-architecture-overview.md)) - System design
- **Component Deep-Dive** ([02-component-deep-dive.md](./02-component-deep-dive.md)) - Implementation details
- **Workflows** ([03-workflows-and-dataflows.md](./03-workflows-and-dataflows.md)) - Execution flows
- **API Reference** ([04-api-reference.md](./04-api-reference.md)) - API documentation

---

## 📞 Need Help?

If you can't find what you're looking for:

1. Search this guide for keywords
2. Check the [Executive Summary](./00-executive-summary.md) for high-level navigation
3. Consult the [Architecture Overview](./01-architecture-overview.md) for component locations
4. Use `grep` or IDE search to find specific code

**Happy Navigating! 🧭**
