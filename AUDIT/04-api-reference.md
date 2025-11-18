# API Reference Documentation

**Version:** 2.7.34
**Status:** Comprehensive API documentation extracted from source code
**Last Updated:** 2025-11-18

---

## Table of Contents

1. [CLI API](#1-cli-api)
2. [MCP Tools API](#2-mcp-tools-api)
3. [JavaScript/TypeScript API](#3-javascripttypescript-api)
4. [Configuration API](#4-configuration-api)
5. [Extension Points](#5-extension-points)
6. [Error Codes](#6-error-codes)
7. [Migration Guide](#7-migration-guide)

---

## 1. CLI API

The CLI provides the primary interface for interacting with claude-flow. All commands follow the pattern:

```bash
npx claude-flow@alpha <command> [subcommand] [options]
```

### 1.1 Core Commands

#### `init` - Project Initialization

Initialize Claude Code integration and SPARC environment.

**Usage:**
```bash
claude-flow init [--force] [--minimal] [--sparc]
```

**Options:**
- `--force` - Overwrite existing files
- `--minimal` - Minimal setup without templates
- `--sparc` - Full SPARC methodology setup (recommended)

**Examples:**
```bash
# Recommended: Full SPARC setup
npx claude-flow@alpha init --sparc

# Force overwrite with SPARC
claude-flow init --sparc --force

# Minimal setup only
claude-flow init --minimal
```

**Output:**
- Creates `.claude/` directory structure
- Installs `.roomodes` file with 17 SPARC modes
- Generates `CLAUDE.md` with project instructions
- Sets up agent templates

**Exit Codes:**
- `0` - Success
- `1` - General error
- `2` - File conflict (use --force)

---

#### `start` - System Launch

Start the claude-flow orchestration system.

**Usage:**
```bash
claude-flow start [--daemon] [--port <port>] [--verbose] [--ui] [--web]
```

**Options:**
- `--daemon` - Run as background service
- `--port <port>` - MCP server port (default: 8080)
- `--verbose` - Detailed logging
- `--ui` - Launch terminal UI
- `--web` - Launch web UI

**Examples:**
```bash
# Interactive mode
claude-flow start

# Background daemon with custom port
claude-flow start --daemon --port 9000

# With web UI
claude-flow start --web --port 3000
```

**Process Management:**
- PID stored in `.swarm/claude-flow.pid`
- Logs in `.swarm/logs/`
- Stop with `pkill -f claude-flow` or web UI

---

#### `agent` - Agent Management

Manage AI agents with multi-provider support and ReasoningBank memory.

**Usage:**
```bash
claude-flow agent <subcommand> [options]
```

**Subcommands:**

##### `run` - Execute Agent

```bash
claude-flow agent run <agent-type> "<task>" [--optimize] [--provider <name>]
```

**Options:**
- `--optimize` - Use model optimization (85-98% cost savings)
- `--provider <name>` - anthropic, openrouter, onnx, gemini
- `--model <name>` - Specific model to use
- `--memory` - Enable ReasoningBank memory

**Example:**
```bash
# Execute with optimization
claude-flow agent run coder "Build REST API" --optimize

# Specific provider
claude-flow agent run researcher "Analyze data" --provider openrouter
```

##### `agents` - List Agents

```bash
claude-flow agent agents [--filter <type>]
```

Lists all 66+ available agent types.

##### `memory` - Memory Management

```bash
# Initialize ReasoningBank
claude-flow agent memory init

# Query memory
claude-flow agent memory query --search "REST API"

# Export memory
claude-flow agent memory export --format json
```

##### `config` - Configuration

```bash
# Interactive wizard
claude-flow agent config wizard

# Set API key
claude-flow agent config set ANTHROPIC_API_KEY sk-ant-xxx

# Show config
claude-flow agent config show
```

##### `mcp` - MCP Server

```bash
# Start MCP server
claude-flow agent mcp start --daemon

# Check status
claude-flow agent mcp status

# List tools
claude-flow agent mcp tools
```

---

#### `proxy` - OpenRouter Proxy

Cost-saving proxy server for 85-98% savings.

**Usage:**
```bash
claude-flow proxy <subcommand> [options]
```

**Subcommands:**

```bash
# Start proxy
claude-flow proxy start --daemon --port 8080

# Check status
claude-flow proxy status --verbose

# View logs
claude-flow proxy logs --follow

# Stop proxy
claude-flow proxy stop
```

**Configuration:**
```bash
# Set OpenRouter API key
claude-flow agent config set OPENROUTER_API_KEY sk-or-xxx

# Configure Claude Code to use proxy
export ANTHROPIC_BASE_URL=http://localhost:8080
```

**Cost Savings:**
- Claude 3.5 Sonnet: $3.00 → $0.30/M tokens (90%)
- Claude 3 Opus: $15.00 → $2.25/M tokens (85%)
- DeepSeek R1: Free (100%)

---

#### `swarm` - Swarm Coordination

Multi-agent swarm coordination system.

**Usage:**
```bash
claude-flow swarm "<objective>" [options]
```

**Options:**
- `--strategy <type>` - research, development, analysis
- `--max-agents <n>` - Maximum agents (default: 8)
- `--parallel` - Parallel execution
- `--ui` - Launch monitoring UI
- `--background` - Run in background

**Examples:**
```bash
# Development swarm
claude-flow swarm "Build REST API" --strategy development

# Research with UI
claude-flow swarm "Cloud architecture analysis" --strategy research --ui

# Background processing
claude-flow swarm "Analyze data" --background --max-agents 12
```

---

#### `hive-mind` - Advanced Swarm Intelligence

Queen-led collective intelligence system.

**Usage:**
```bash
claude-flow hive-mind <subcommand> [options]
```

**Subcommands:**

```bash
# Initialize hive mind
claude-flow hive-mind init

# Interactive wizard
claude-flow hive-mind wizard

# Spawn swarm
claude-flow hive-mind spawn "Build microservices"

# Check status
claude-flow hive-mind status

# View consensus decisions
claude-flow hive-mind consensus

# Performance metrics
claude-flow hive-mind metrics

# Optimize database
claude-flow hive-mind-optimize --auto
```

**Features:**
- Queen-led coordination (Strategic, Tactical, Adaptive)
- Specialized workers (Researcher, Coder, Analyst, Tester)
- Collective memory and consensus building
- SQLite-backed persistence
- MCP tool integration (87+ operations)

---

#### `sparc` - SPARC Methodology

Systematic TDD with SPARC methodology.

**Usage:**
```bash
claude-flow sparc [subcommand] [options]
```

**Subcommands:**

```bash
# List modes
claude-flow sparc modes

# Run specific mode
claude-flow sparc run <mode> "<task>"

# TDD workflow
claude-flow sparc tdd "<feature>"

# Mode details
claude-flow sparc info <mode>

# Batch execution
claude-flow sparc batch <modes> "<task>"

# Pipeline processing
claude-flow sparc pipeline "<task>"
```

**Available Modes:**
- `spec-pseudocode` - Requirements + Algorithm design
- `architect` - System architecture
- `code` - Implementation
- `tdd` - Test-driven development
- `debug` - Debugging
- `security` - Security analysis
- `integration` - Integration

**Example:**
```bash
# Full TDD workflow
claude-flow sparc tdd "User authentication feature"

# Specific mode
claude-flow sparc run architect "Design microservices"

# Batch modes
claude-flow sparc batch spec-pseudocode,architect,code "Build API"
```

---

#### `hooks` - Lifecycle Events

Execute lifecycle hooks for automation.

**Usage:**
```bash
claude-flow hooks <hook-type> [options]
```

**Hook Types:**

##### Pre-Task Hook
```bash
claude-flow hooks pre-task --description "<task>" --task-id <id>
```

##### Post-Task Hook
```bash
claude-flow hooks post-task --task-id <id> --analyze-performance --generate-insights
```

##### Pre-Edit Hook
```bash
claude-flow hooks pre-edit --file <path> --backup
```

##### Post-Edit Hook
```bash
claude-flow hooks post-edit --file <path> --memory-key <key>
```

##### Session Hooks
```bash
# Session start
claude-flow hooks session-start --session-id <id>

# Session restore
claude-flow hooks session-restore --session-id <id>

# Session end
claude-flow hooks session-end --export-metrics --generate-summary
```

##### Notification Hook
```bash
claude-flow hooks notification --message "<text>" --level info
```

**Options:**
- `--task-id <id>` - Task identifier
- `--file <path>` - File path for edit hooks
- `--session-id <id>` - Session identifier
- `--analyze-performance` - Run performance analysis
- `--generate-insights` - Generate insights
- `--export-metrics` - Export metrics
- `--memory-key <key>` - Memory storage key

---

#### `memory` - Memory Management

Unified memory system operations.

**Usage:**
```bash
claude-flow memory <subcommand> [options]
```

**Subcommands:**

```bash
# Store memory
claude-flow memory store <key> "<value>"

# Query memory
claude-flow memory query <search-term>

# Statistics
claude-flow memory stats

# Export
claude-flow memory export <file.json>

# Import
claude-flow memory import <file.json>

# Cleanup
claude-flow memory cleanup --days 30

# Consolidate stores
claude-flow memory-consolidate execute --force
```

---

#### `github` - GitHub Automation

GitHub workflow automation with 6 specialized modes.

**Usage:**
```bash
claude-flow github <mode> "<objective>" [options]
```

**Modes:**

```bash
# PR Management
claude-flow github pr-manager "Create feature PR with tests"

# GitHub Coordinator
claude-flow github gh-coordinator "Setup CI/CD pipeline" --auto-approve

# Release Management
claude-flow github release-manager "Prepare v2.0.0 release"

# Repository Architecture
claude-flow github repo-architect "Optimize repo structure"

# Issue Tracking
claude-flow github issue-tracker "Analyze roadmap issues"

# Sync Coordinator
claude-flow github sync-coordinator "Sync package versions"
```

**Options:**
- `--auto-approve` - Auto-approve changes
- `--draft` - Create draft PRs
- `--reviewers <list>` - Comma-separated reviewers

---

#### `verification` - Truth Enforcement

Verification and truth scoring system.

**Usage:**
```bash
claude-flow verify <subcommand> [options]
```

**Subcommands:**

```bash
# System status
claude-flow verify status

# Run checks
claude-flow verify check --taskId <id>

# Validate results
claude-flow verify validate --taskId <id>

# Configuration
claude-flow verify config

# Cleanup
claude-flow verify cleanup --force

# Truth telemetry
claude-flow truth --taskId <id>

# Truth report
claude-flow truth --report --threshold 0.95
```

**Metrics:**
- Truth accuracy rate (target: >95%)
- Human intervention rate (target: <10%)
- Integration success (target: >90%)
- Rollback frequency (target: <5%)

---

### 1.2 Advanced Commands

#### `mcp` - MCP Server Management

```bash
# Start server
claude-flow mcp start --port 8080

# Status
claude-flow mcp status

# List tools
claude-flow mcp tools --verbose

# Authentication setup
claude-flow mcp auth setup
```

#### `monitor` - Real-time Monitoring

```bash
# Start monitor
claude-flow monitor

# Watch mode
claude-flow monitor --watch --interval 1000

# JSON output
claude-flow monitor --format json
```

#### `config` - Configuration Management

```bash
# Initialize
claude-flow config init

# Set value
claude-flow config set terminal.poolSize 15

# Get value
claude-flow config get orchestrator.maxConcurrentTasks

# Validate
claude-flow config validate
```

#### `status` - System Status

```bash
# Basic status
claude-flow status

# Verbose
claude-flow status --verbose

# JSON format
claude-flow status --json
```

---

## 2. MCP Tools API

The MCP (Model Context Protocol) server exposes 30+ tools for agent coordination. All tools follow JSON-RPC 2.0 protocol.

### 2.1 Tool Categories

1. **Agent Management** (5 tools)
2. **Task Management** (6 tools)
3. **Memory Management** (5 tools)
4. **System Monitoring** (3 tools)
5. **Configuration** (3 tools)
6. **Workflow** (3 tools)
7. **Terminal** (3 tools)
8. **Query Control** (2 tools)

---

### 2.2 Agent Management Tools

#### `agents/spawn` - Spawn Agent

Create a new agent instance.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "type": {
      "type": "string",
      "description": "Agent type (loaded from .claude/agents/)"
    },
    "name": {
      "type": "string",
      "description": "Display name"
    },
    "capabilities": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Agent capabilities"
    },
    "systemPrompt": {
      "type": "string",
      "description": "Custom system prompt"
    },
    "maxConcurrentTasks": {
      "type": "number",
      "default": 3
    },
    "priority": {
      "type": "number",
      "default": 5,
      "description": "1-10"
    },
    "environment": {
      "type": "object"
    },
    "workingDirectory": {
      "type": "string"
    }
  },
  "required": ["type", "name"]
}
```

**Response:**
```json
{
  "agentId": "agent_1731928123456_abc123",
  "sessionId": "session_xyz789",
  "profile": { /* AgentProfile */ },
  "status": "spawned",
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

**Example:**
```json
{
  "type": "coder",
  "name": "API Developer",
  "capabilities": ["typescript", "rest-api", "testing"],
  "maxConcurrentTasks": 5,
  "priority": 8
}
```

---

#### `agents/spawn_parallel` - Parallel Agent Spawning

Spawn multiple agents concurrently (10-20x faster).

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "agents": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": { "type": "string" },
          "name": { "type": "string" },
          "capabilities": {
            "type": "array",
            "items": { "type": "string" }
          },
          "priority": {
            "type": "string",
            "enum": ["low", "medium", "high", "critical"],
            "default": "medium"
          }
        },
        "required": ["type", "name"]
      }
    },
    "maxConcurrency": {
      "type": "number",
      "default": 5
    },
    "batchSize": {
      "type": "number",
      "default": 3
    }
  },
  "required": ["agents"]
}
```

**Response:**
```json
{
  "success": true,
  "agentsSpawned": 5,
  "sessions": [
    {
      "agentId": "agent_123",
      "sessionId": "session_xyz",
      "status": "active"
    }
  ],
  "performance": {
    "totalTime": 1234,
    "averageTimePerAgent": 246,
    "speedupVsSequential": "~15x"
  },
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

#### `agents/list` - List Agents

List all active agents.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "includeTerminated": {
      "type": "boolean",
      "default": false
    },
    "filterByType": {
      "type": "string"
    }
  }
}
```

**Response:**
```json
{
  "agents": [
    {
      "id": "agent_123",
      "name": "API Developer",
      "type": "coder",
      "status": "active",
      "activeTasks": 2
    }
  ],
  "count": 1,
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

#### `agents/terminate` - Terminate Agent

Terminate a specific agent.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "agentId": {
      "type": "string",
      "description": "Agent ID to terminate"
    },
    "reason": {
      "type": "string"
    },
    "graceful": {
      "type": "boolean",
      "default": true
    }
  },
  "required": ["agentId"]
}
```

---

#### `agents/info` - Get Agent Info

Get detailed agent information.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "agentId": {
      "type": "string"
    }
  },
  "required": ["agentId"]
}
```

**Response:**
```json
{
  "agent": {
    "id": "agent_123",
    "name": "API Developer",
    "type": "coder",
    "capabilities": ["typescript", "rest-api"],
    "status": "active",
    "activeTasks": 2,
    "completedTasks": 15,
    "uptime": 3600000,
    "memoryUsage": { /* ... */ }
  },
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

### 2.3 Task Management Tools

#### `tasks/create` - Create Task

Create a new task for execution.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "type": { "type": "string" },
    "description": { "type": "string" },
    "priority": {
      "type": "number",
      "default": 5
    },
    "dependencies": {
      "type": "array",
      "items": { "type": "string" }
    },
    "assignToAgent": { "type": "string" },
    "assignToAgentType": { "type": "string" },
    "input": { "type": "object" },
    "timeout": { "type": "number" }
  },
  "required": ["type", "description"]
}
```

**Response:**
```json
{
  "taskId": "task_456",
  "task": {
    "id": "task_456",
    "type": "implementation",
    "description": "Build REST API",
    "status": "pending",
    "priority": 5
  },
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

#### `tasks/list` - List Tasks

List tasks with filtering.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["pending", "queued", "assigned", "running", "completed", "failed", "cancelled"]
    },
    "agentId": { "type": "string" },
    "type": { "type": "string" },
    "limit": {
      "type": "number",
      "default": 50
    },
    "offset": {
      "type": "number",
      "default": 0
    }
  }
}
```

---

#### `tasks/status` - Task Status

Get detailed task status.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "taskId": { "type": "string" }
  },
  "required": ["taskId"]
}
```

---

#### `tasks/cancel` - Cancel Task

Cancel a running task.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "taskId": { "type": "string" },
    "reason": { "type": "string" }
  },
  "required": ["taskId"]
}
```

---

#### `tasks/assign` - Assign Task

Assign task to agent.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "taskId": { "type": "string" },
    "agentId": { "type": "string" }
  },
  "required": ["taskId", "agentId"]
}
```

---

### 2.4 Memory Management Tools

#### `memory/query` - Query Memory

Query agent memory with filters.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "agentId": { "type": "string" },
    "sessionId": { "type": "string" },
    "type": {
      "type": "string",
      "enum": ["observation", "insight", "decision", "artifact", "error"]
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" }
    },
    "search": { "type": "string" },
    "startTime": {
      "type": "string",
      "format": "date-time"
    },
    "endTime": {
      "type": "string",
      "format": "date-time"
    },
    "limit": {
      "type": "number",
      "default": 50
    },
    "offset": {
      "type": "number",
      "default": 0
    }
  }
}
```

**Response:**
```json
{
  "entries": [
    {
      "id": "mem_123",
      "agentId": "agent_456",
      "type": "insight",
      "content": "REST API patterns identified",
      "timestamp": "2025-11-18T10:00:00.000Z",
      "tags": ["api", "architecture"]
    }
  ],
  "count": 1,
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

#### `memory/store` - Store Memory

Store a new memory entry.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "agentId": { "type": "string" },
    "sessionId": { "type": "string" },
    "type": {
      "type": "string",
      "enum": ["observation", "insight", "decision", "artifact", "error"]
    },
    "content": { "type": "string" },
    "context": { "type": "object" },
    "tags": {
      "type": "array",
      "items": { "type": "string" }
    },
    "parentId": { "type": "string" }
  },
  "required": ["agentId", "sessionId", "type", "content"]
}
```

---

#### `memory/delete` - Delete Memory

Delete a memory entry.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "entryId": { "type": "string" }
  },
  "required": ["entryId"]
}
```

---

#### `memory/export` - Export Memory

Export memory to file.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "format": {
      "type": "string",
      "enum": ["json", "csv", "markdown"],
      "default": "json"
    },
    "agentId": { "type": "string" },
    "sessionId": { "type": "string" },
    "startTime": { "type": "string", "format": "date-time" },
    "endTime": { "type": "string", "format": "date-time" }
  }
}
```

---

#### `memory/import` - Import Memory

Import memory from file.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "filePath": { "type": "string" },
    "format": {
      "type": "string",
      "enum": ["json", "csv"],
      "default": "json"
    },
    "mergeStrategy": {
      "type": "string",
      "enum": ["skip", "overwrite", "version"],
      "default": "skip"
    }
  },
  "required": ["filePath"]
}
```

---

### 2.5 System Monitoring Tools

#### `system/status` - System Status

Get comprehensive system status.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {}
}
```

**Response:**
```json
{
  "uptime": 3600000,
  "agents": {
    "total": 5,
    "active": 3,
    "idle": 2
  },
  "tasks": {
    "total": 20,
    "pending": 2,
    "running": 5,
    "completed": 13
  },
  "memory": {
    "used": 123456789,
    "total": 1073741824
  },
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

---

#### `system/metrics` - System Metrics

Get performance metrics.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "timeRange": {
      "type": "string",
      "enum": ["1h", "6h", "24h", "7d"],
      "default": "1h"
    }
  }
}
```

---

#### `system/health` - Health Check

Perform comprehensive health check.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "deep": {
      "type": "boolean",
      "default": false,
      "description": "Deep health check with component tests"
    }
  }
}
```

---

### 2.6 Configuration Tools

#### `config/get` - Get Configuration

Get current system configuration.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "section": {
      "type": "string",
      "enum": ["orchestrator", "terminal", "memory", "coordination", "mcp", "logging"]
    }
  }
}
```

---

#### `config/update` - Update Configuration

Update system configuration.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "section": {
      "type": "string",
      "enum": ["orchestrator", "terminal", "memory", "coordination", "mcp", "logging"]
    },
    "config": { "type": "object" },
    "restart": {
      "type": "boolean",
      "default": false
    }
  },
  "required": ["section", "config"]
}
```

---

#### `config/validate` - Validate Configuration

Validate a configuration object.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "config": { "type": "object" }
  },
  "required": ["config"]
}
```

---

### 2.7 Workflow Tools

#### `workflow/execute` - Execute Workflow

Execute a workflow from file or definition.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "filePath": { "type": "string" },
    "workflow": { "type": "object" },
    "parameters": { "type": "object" }
  }
}
```

---

#### `workflow/create` - Create Workflow

Create a new workflow definition.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "description": { "type": "string" },
    "tasks": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "type": { "type": "string" },
          "description": { "type": "string" },
          "dependencies": {
            "type": "array",
            "items": { "type": "string" }
          },
          "assignTo": { "type": "string" }
        },
        "required": ["id", "type", "description"]
      }
    },
    "savePath": { "type": "string" }
  },
  "required": ["name", "tasks"]
}
```

---

#### `workflow/list` - List Workflows

List available workflows.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "directory": { "type": "string" }
  }
}
```

---

### 2.8 Terminal Tools

#### `terminal/execute` - Execute Command

Execute command in terminal.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "command": { "type": "string" },
    "args": {
      "type": "array",
      "items": { "type": "string" }
    },
    "cwd": { "type": "string" },
    "env": { "type": "object" },
    "timeout": {
      "type": "number",
      "default": 30000
    },
    "terminalId": { "type": "string" }
  },
  "required": ["command"]
}
```

---

#### `terminal/list` - List Terminals

List all terminal sessions.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "includeIdle": {
      "type": "boolean",
      "default": true
    }
  }
}
```

---

#### `terminal/create` - Create Terminal

Create a new terminal session.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "cwd": { "type": "string" },
    "env": { "type": "object" },
    "shell": { "type": "string" }
  }
}
```

---

### 2.9 Query Control Tools

#### `query/control` - Control Query

Real-time query control (pause, resume, terminate).

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "action": {
      "type": "string",
      "enum": ["pause", "resume", "terminate", "change_model", "change_permissions", "execute_command"]
    },
    "queryId": { "type": "string" },
    "model": {
      "type": "string",
      "enum": ["claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229"]
    },
    "permissionMode": {
      "type": "string",
      "enum": ["default", "acceptEdits", "bypassPermissions", "plan"]
    },
    "command": { "type": "string" }
  },
  "required": ["action", "queryId"]
}
```

---

#### `query/list` - List Queries

List all active queries.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "includeHistory": {
      "type": "boolean",
      "default": false
    }
  }
}
```

---

## 3. JavaScript/TypeScript API

The TypeScript API provides programmatic access to claude-flow functionality.

### 3.1 Core Interfaces

#### `Config` Interface

System configuration interface.

```typescript
interface Config {
  env: 'development' | 'production' | 'test';
  logLevel: 'debug' | 'info' | 'warn' | 'error';
  enableMetrics?: boolean;
  orchestrator?: OrchestratorConfig;
  logging?: LoggingConfig;
  terminal?: TerminalConfig;
  memory?: MemoryConfig;
  coordination?: CoordinationConfig;
  mcp?: MCPConfig;
}
```

---

#### `AgentProfile` Interface

Agent configuration profile.

```typescript
interface AgentProfile {
  id: string;
  name: string;
  type: 'coordinator' | 'researcher' | 'implementer' | 'analyst' | 'custom';
  capabilities: string[];
  systemPrompt?: string;
  maxConcurrentTasks: number;
  priority?: number;
  environment?: Record<string, string>;
  workingDirectory?: string;
  shell?: string;
  metadata?: Record<string, unknown>;
}
```

---

#### `Task` Interface

Task definition.

```typescript
interface Task {
  id: string;
  type: string;
  description: string;
  priority: number;
  dependencies: string[];
  assignedAgent?: string;
  status: TaskStatus;
  input: Record<string, unknown>;
  output?: Record<string, unknown>;
  error?: Error;
  createdAt: Date;
  startedAt?: Date;
  completedAt?: Date;
  metadata?: Record<string, unknown>;
}

type TaskStatus =
  | 'pending'
  | 'queued'
  | 'assigned'
  | 'running'
  | 'completed'
  | 'failed'
  | 'cancelled';
```

---

#### `MemoryEntry` Interface

Memory entry structure.

```typescript
interface MemoryEntry {
  id: string;
  agentId: string;
  sessionId: string;
  type: 'observation' | 'insight' | 'decision' | 'artifact' | 'error';
  content: string;
  context: Record<string, unknown>;
  timestamp: Date;
  tags: string[];
  version: number;
  parentId?: string;
  metadata?: Record<string, unknown>;
}
```

---

### 3.2 Event System

#### `SystemEvents` Enum

System event types.

```typescript
enum SystemEvents {
  // Agent events
  AGENT_SPAWNED = 'agent:spawned',
  AGENT_TERMINATED = 'agent:terminated',
  AGENT_ERROR = 'agent:error',
  AGENT_IDLE = 'agent:idle',
  AGENT_ACTIVE = 'agent:active',

  // Task events
  TASK_CREATED = 'task:created',
  TASK_ASSIGNED = 'task:assigned',
  TASK_STARTED = 'task:started',
  TASK_COMPLETED = 'task:completed',
  TASK_FAILED = 'task:failed',
  TASK_CANCELLED = 'task:cancelled',

  // Memory events
  MEMORY_CREATED = 'memory:created',
  MEMORY_UPDATED = 'memory:updated',
  MEMORY_DELETED = 'memory:deleted',

  // System events
  SYSTEM_READY = 'system:ready',
  SYSTEM_SHUTDOWN = 'system:shutdown',
  SYSTEM_ERROR = 'system:error',
}
```

#### Event Listeners

```typescript
// Subscribe to events
eventBus.on(SystemEvents.AGENT_SPAWNED, (event) => {
  console.log('Agent spawned:', event.agentId);
});

// Emit events
eventBus.emit(SystemEvents.TASK_COMPLETED, {
  taskId: 'task_123',
  result: { /* ... */ }
});
```

---

### 3.3 Core Classes

#### `CLI` Class

Main CLI handler.

```typescript
import { CLI } from './cli-core.js';

const cli = new CLI('claude-flow', 'AI Agent Orchestration');

// Register command
cli.command('mycommand', async (args, flags) => {
  console.log('Command executed');
});

// Run CLI
await cli.run();
```

---

#### `MCPServer` Class

MCP server implementation.

```typescript
import { MCPServer } from './mcp/server.js';

const server = new MCPServer(
  config,
  eventBus,
  logger,
  orchestrator
);

// Start server
await server.start();

// Register tool
server.registerTool({
  name: 'my-tool',
  description: 'Custom tool',
  inputSchema: { /* ... */ },
  handler: async (input, context) => {
    return { result: 'success' };
  }
});

// Stop server
await server.stop();
```

---

#### `ToolRegistry` Class

Tool registry for MCP tools.

```typescript
import { ToolRegistry } from './mcp/tools.js';

const registry = new ToolRegistry(logger);

// Register tool
registry.register(tool, capability);

// Execute tool
const result = await registry.executeTool('tool-name', input, context);

// Get metrics
const metrics = registry.getToolMetrics('tool-name');

// Discover tools
const tools = registry.discoverTools({
  category: 'swarm',
  tags: ['orchestration']
});
```

---

### 3.4 Utility Functions

#### Type Guards

```typescript
import { isTask, isAgentProfile, isMemoryEntry } from './utils/type-guards.js';

if (isTask(data)) {
  console.log('Task ID:', data.id);
}
```

#### Error Handling

```typescript
import { MCPError, MCPMethodNotFoundError } from './utils/errors.js';

throw new MCPError('Operation failed', { code: 'ERR_OPERATION' });
```

---

## 4. Configuration API

Configuration files define system behavior and can be programmatically modified.

### 4.1 Configuration Files

#### `.claude-flow/config.json`

Main configuration file.

```json
{
  "env": "development",
  "logLevel": "info",
  "enableMetrics": true,
  "orchestrator": {
    "maxConcurrentAgents": 8,
    "taskQueueSize": 100,
    "healthCheckInterval": 30000,
    "shutdownTimeout": 5000,
    "persistSessions": true,
    "dataDir": ".swarm"
  },
  "terminal": {
    "type": "auto",
    "poolSize": 10,
    "recycleAfter": 100,
    "healthCheckInterval": 60000,
    "commandTimeout": 30000
  },
  "memory": {
    "backend": "sqlite",
    "cacheSizeMB": 100,
    "syncInterval": 5000,
    "conflictResolution": "last-write",
    "retentionDays": 90,
    "sqlitePath": ".swarm/memory.db"
  },
  "coordination": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "deadlockDetection": true,
    "resourceTimeout": 30000
  },
  "mcp": {
    "enabled": true,
    "port": 8080,
    "transport": "stdio",
    "auth": {
      "enabled": false,
      "method": "token"
    }
  },
  "logging": {
    "level": "info",
    "format": "text",
    "destination": "both",
    "file": {
      "path": ".swarm/logs/claude-flow.log",
      "maxSize": 10485760,
      "maxFiles": 5
    }
  }
}
```

---

#### `.roomodes` File

SPARC mode definitions.

```yaml
# Specification & Pseudocode Mode
spec-pseudocode:
  description: Requirements analysis and algorithm design
  systemPrompt: |
    Analyze requirements and create detailed pseudocode.

# Architecture Mode
architect:
  description: System architecture and design
  systemPrompt: |
    Design scalable system architecture.

# Code Implementation Mode
code:
  description: Implementation mode
  systemPrompt: |
    Implement clean, tested code.

# TDD Mode
tdd:
  description: Test-driven development
  systemPrompt: |
    Write tests first, then implementation.
```

---

#### `CLAUDE.md` File

AI-readable project instructions.

```markdown
# Claude Code Configuration

## Project Overview
[Project description]

## Development Workflow
- SPARC methodology enabled
- TDD approach required
- Code review before merge

## File Organization
- /src - Source code
- /tests - Test files
- /docs - Documentation

## Agent Coordination
- Use hooks for synchronization
- Store context in memory
- Report progress via notifications
```

---

### 4.2 Environment Variables

#### Core Variables

```bash
# API Keys
ANTHROPIC_API_KEY=sk-ant-xxx
OPENROUTER_API_KEY=sk-or-xxx

# Proxy Configuration
ANTHROPIC_BASE_URL=http://localhost:8080

# System Configuration
CLAUDE_FLOW_ENV=production
CLAUDE_FLOW_LOG_LEVEL=info
CLAUDE_FLOW_DATA_DIR=/path/to/.swarm

# MCP Configuration
CLAUDE_FLOW_MCP_PORT=8080
CLAUDE_FLOW_MCP_TRANSPORT=stdio

# Memory Configuration
CLAUDE_FLOW_MEMORY_BACKEND=sqlite
CLAUDE_FLOW_MEMORY_PATH=/path/to/memory.db
```

---

### 4.3 Runtime Configuration

#### Programmatic Configuration

```typescript
import { loadConfig, updateConfig, validateConfig } from './config/index.js';

// Load config
const config = await loadConfig();

// Update section
await updateConfig('orchestrator', {
  maxConcurrentAgents: 12
});

// Validate
const validation = await validateConfig(config);
if (!validation.valid) {
  console.error('Invalid config:', validation.errors);
}
```

---

## 5. Extension Points

claude-flow provides multiple extension points for customization.

### 5.1 Custom Agents

Create custom agent types.

**Location:** `.claude/agents/<agent-name>.md`

```markdown
---
name: custom-agent
description: Custom specialized agent
capabilities:
  - custom-task-1
  - custom-task-2
priority: 7
---

# System Prompt

You are a specialized agent for [task].

## Responsibilities
- [Responsibility 1]
- [Responsibility 2]

## Tools Available
- [Tool 1]
- [Tool 2]
```

**Usage:**
```bash
claude-flow agent run custom-agent "Execute custom task"
```

---

### 5.2 Custom MCP Tools

Register custom MCP tools.

```typescript
import { MCPTool } from './utils/types.js';

const customTool: MCPTool = {
  name: 'custom/my-tool',
  description: 'Custom tool for specific task',
  inputSchema: {
    type: 'object',
    properties: {
      input: { type: 'string' }
    },
    required: ['input']
  },
  handler: async (input, context) => {
    // Tool implementation
    return {
      result: 'success',
      data: processInput(input)
    };
  }
};

// Register tool
server.registerTool(customTool);
```

---

### 5.3 Custom Hooks

Create custom lifecycle hooks.

**Location:** `.claude/hooks/<hook-name>.sh`

```bash
#!/bin/bash

# Pre-task hook example
# Called before task execution

TASK_ID=$1
DESCRIPTION=$2

echo "Pre-task: $TASK_ID - $DESCRIPTION"

# Custom logic
# - Validate environment
# - Setup resources
# - Log to external system

exit 0
```

**Register Hook:**
```json
{
  "hooks": {
    "pre-task": ".claude/hooks/pre-task.sh",
    "post-task": ".claude/hooks/post-task.sh"
  }
}
```

---

### 5.4 Custom Commands

Add custom CLI commands.

```javascript
import { registerCommand } from './cli/command-registry.js';

registerCommand('my-command', {
  handler: async (args, flags) => {
    console.log('Custom command executed');
    // Implementation
  },
  description: 'My custom command',
  usage: 'my-command [options]',
  examples: [
    'my-command --flag value'
  ]
});
```

---

### 5.5 Plugin System

Create plugins for extended functionality.

```typescript
// plugin.ts
export interface Plugin {
  name: string;
  version: string;
  initialize: (context: PluginContext) => Promise<void>;
  shutdown?: () => Promise<void>;
}

export const myPlugin: Plugin = {
  name: 'my-plugin',
  version: '1.0.0',

  async initialize(context) {
    // Register tools
    context.registerTool(customTool);

    // Register event listeners
    context.eventBus.on('task:completed', handleTaskComplete);
  },

  async shutdown() {
    // Cleanup
  }
};
```

**Load Plugin:**
```typescript
import { loadPlugin } from './plugin-loader.js';
import { myPlugin } from './plugins/my-plugin.js';

await loadPlugin(myPlugin);
```

---

## 6. Error Codes

Standard error codes used throughout the system.

### 6.1 CLI Error Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | General error |
| 2 | File conflict |
| 3 | Invalid configuration |
| 4 | Permission denied |
| 5 | Dependency missing |
| 10 | Agent error |
| 11 | Task error |
| 12 | Memory error |
| 20 | MCP error |
| 21 | Tool not found |
| 22 | Invalid input |
| 30 | Network error |
| 31 | Timeout |

---

### 6.2 MCP Error Codes

Standard JSON-RPC error codes:

| Code | Meaning |
|------|---------|
| -32700 | Parse error |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |
| -32000 to -32099 | Server error |

---

### 6.3 Custom Error Classes

```typescript
import { MCPError } from './utils/errors.js';

class AgentSpawnError extends MCPError {
  constructor(message: string, data?: any) {
    super(message, { code: 'ERR_AGENT_SPAWN', ...data });
  }
}

class MemoryStorageError extends MCPError {
  constructor(message: string, data?: any) {
    super(message, { code: 'ERR_MEMORY_STORAGE', ...data });
  }
}
```

---

## 7. Migration Guide

### 7.1 Version 2.6.x → 2.7.x

**Breaking Changes:**
- MCP protocol upgraded to 2025-11 specification
- Progressive disclosure for tool schemas
- New authentication methods

**Migration Steps:**

1. Update package:
```bash
npm install claude-flow@alpha
```

2. Update config file:
```json
{
  "mcp": {
    "protocol": "2025-11",
    "progressive": true
  }
}
```

3. Update tool registrations:
```typescript
// Old
registry.register(tool);

// New
registry.register(tool, {
  version: '1.0.0',
  supportedProtocolVersions: [{ major: 2024, minor: 11, patch: 5 }]
});
```

---

### 7.2 API Compatibility

**Maintained:**
- Core CLI commands
- Agent types
- Memory API
- Event system

**Changed:**
- MCP tool schemas (now include capability metadata)
- Configuration structure (new sections added)
- Hook execution (new hook types)

**Deprecated:**
- Legacy memory backend 'json' (use 'sqlite')
- Old terminal type 'legacy' (use 'auto')

---

### 7.3 Data Migration

Migrate legacy data:

```bash
# Migrate memory stores
claude-flow memory-consolidate execute --force

# Migrate configuration
claude-flow config migrate --from 2.6 --to 2.7

# Backup before migration
cp -r .swarm .swarm.backup
```

---

## Appendix A: Tool Schema Reference

Complete tool schemas available at:
- Source: `/src/mcp/claude-flow-tools.ts`
- Documentation: `/docs/mcp-tools.md`

---

## Appendix B: Type Definitions

Complete TypeScript definitions:
- Core types: `/src/utils/types.ts`
- Interfaces: `/src/types/interfaces.ts`
- MCP types: `/src/types/mcp.d.ts`

---

## Appendix C: Examples

### Complete Agent Workflow

```bash
# 1. Initialize project
claude-flow init --sparc

# 2. Start system
claude-flow start --daemon

# 3. Spawn agents
claude-flow agent run coder "Build REST API" --optimize

# 4. Monitor progress
claude-flow monitor --watch

# 5. Query memory
claude-flow memory query "API design"

# 6. Export results
claude-flow memory export results.json
```

### MCP Tool Integration

```typescript
import { MCPServer } from 'claude-flow/mcp';

const server = new MCPServer(config, eventBus, logger);

// Start server
await server.start();

// Use tool
const result = await server.executeTool('agents/spawn', {
  type: 'coder',
  name: 'API Developer',
  capabilities: ['typescript', 'rest-api']
});

console.log('Agent spawned:', result.agentId);
```

---

## Appendix D: Performance Benchmarks

### Agent Spawning

- Sequential: ~750ms per agent
- Parallel: ~50-75ms per agent (10-15x faster)
- Batch (5 agents): ~375ms total

### Memory Operations

- Store: ~5-10ms
- Query: ~10-20ms
- Export (1000 entries): ~100ms

### MCP Tool Execution

- Simple tools: ~10-50ms
- Complex tools: ~100-500ms
- Network tools: ~200-2000ms

---

**End of API Reference Documentation**

For additional help:
- GitHub: https://github.com/ruvnet/claude-flow
- Issues: https://github.com/ruvnet/claude-flow/issues
- Documentation: https://github.com/ruvnet/claude-flow/docs
