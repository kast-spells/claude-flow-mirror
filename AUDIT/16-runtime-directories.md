# Runtime Directories Documentation

## Executive Summary

This document comprehensively documents all runtime directories created by claude-flow during initialization and operation. These directories store critical runtime state, configuration, databases, and coordination data for swarm operations.

**Last Updated:** 2025-01-18
**Version:** 2.7.34

---

## Table of Contents

1. [Directory Overview](#directory-overview)
2. [.claude-flow/ Directory](#claude-flow-directory)
3. [.swarm/ Directory](#swarm-directory)
4. [.claude/ Directory](#claude-directory)
5. [.hive-mind/ Directory](#hive-mind-directory)
6. [.ruv-swarm/ Directory](#ruv-swarm-directory)
7. [Other Runtime Directories](#other-runtime-directories)
8. [Security & Permissions](#security--permissions)
9. [Maintenance & Operations](#maintenance--operations)
10. [Troubleshooting](#troubleshooting)

---

## Directory Overview

### Directory Tree

```
project-root/
├── .claude-flow/           # Core runtime data (DB, config, metrics)
│   ├── database.sqlite     # SQLite database (primary)
│   ├── database.json       # JSON fallback database
│   ├── config.json         # Configuration file
│   ├── token-usage.json    # Token tracking data
│   ├── monitoring.config.json  # Monitoring configuration
│   ├── env-setup.sh        # Environment setup script
│   ├── metrics/            # Performance metrics
│   │   ├── system-metrics.json
│   │   └── task-metrics.json
│   ├── logs/               # Application logs
│   └── hooks-state.json    # Hooks configuration state
│
├── .swarm/                 # Swarm coordination and memory
│   ├── memory.db           # SQLite database for ReasoningBank
│   ├── memory.db-journal   # SQLite journal file
│   ├── memory.db-wal       # SQLite write-ahead log
│   └── session-*.json      # Session state files
│
├── .claude/                # Claude Code integration
│   ├── settings.json       # Main settings
│   ├── settings.local.json # Local overrides (gitignored)
│   ├── statusline-command.sh  # Status line script
│   ├── agents/             # Agent definitions
│   │   ├── core/           # Core agents (coder, reviewer, tester, etc.)
│   │   ├── swarm/          # Swarm coordination agents
│   │   ├── reasoning/      # Reasoning agents
│   │   └── flow-nexus/     # Flow Nexus agents
│   ├── commands/           # Slash commands
│   │   ├── core/
│   │   ├── swarm/
│   │   ├── sparc/
│   │   └── flow-nexus/
│   ├── checkpoints/        # Git checkpoint data
│   │   ├── *.json          # Checkpoint metadata
│   │   └── summary-*.md    # Session summaries
│   ├── helpers/            # Helper scripts
│   │   ├── setup-mcp.sh
│   │   ├── github-setup.sh
│   │   ├── checkpoint-manager.sh
│   │   └── standard-checkpoint-hooks.sh
│   └── logs/               # Command logs
│
├── .hive-mind/             # Hive-mind swarm system
│   ├── hive.db             # SQLite database
│   ├── hive.db-journal     # SQLite journal
│   ├── hive.db-wal         # SQLite WAL
│   ├── config.json         # Hive-mind configuration
│   └── sessions/           # Session data
│
├── .ruv-swarm/             # Ruv-swarm coordination (optional)
│   ├── consensus.db        # Consensus data
│   ├── topology.json       # Network topology
│   └── state-sync.json     # State synchronization
│
├── memory/                 # Memory system (gitignored)
│   ├── claude-flow-data.json
│   ├── memory-store.json
│   ├── agents/
│   │   └── README.md
│   └── sessions/
│       └── README.md
│
└── coordination/           # Coordination data (gitignored)
    ├── memory_bank/
    ├── subtasks/
    └── orchestration/
```

---

## .claude-flow/ Directory

### Purpose

The `.claude-flow/` directory is the **primary runtime directory** for claude-flow. It stores the core database, configuration, metrics, and state information for all swarm operations.

### Creation

**When:** Created during `init` command or first swarm execution
**Location:** `{project-root}/.claude-flow/`
**Code Reference:** `src/core/DatabaseManager.ts:35-38`, `src/cli/simple-commands/init/index.js:1219-1221`

```javascript
const baseDir = path.join(process.cwd(), '.claude-flow');
await fs.ensureDir(baseDir);
```

### Directory Structure

```
.claude-flow/
├── database.sqlite          # Primary SQLite database
├── database.json            # JSON fallback database
├── config.json              # Configuration settings
├── token-usage.json         # Token usage tracking
├── monitoring.config.json   # Monitoring configuration
├── env-setup.sh             # Shell environment setup
├── hooks-state.json         # Hooks enabled/disabled state
├── session-state.json       # Current session state
├── swarm-config.json        # Swarm topology configuration
├── metrics/
│   ├── system-metrics.json  # System performance metrics
│   └── task-metrics.json    # Task execution metrics
└── logs/
    └── *.log                # Application logs
```

### File Descriptions

#### database.sqlite

**Format:** SQLite 3 database
**Purpose:** Primary persistent storage for agents, tasks, and memory
**Schema:** See `src/core/DatabaseManager.ts`

```sql
-- Example tables (SQLiteProvider)
CREATE TABLE storage (
  namespace TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  created_at INTEGER,
  updated_at INTEGER,
  PRIMARY KEY (namespace, key)
);
CREATE INDEX idx_storage_namespace ON storage(namespace);
CREATE INDEX idx_storage_created_at ON storage(created_at);
```

**Fallback:** If SQLite is unavailable (e.g., npx mode), falls back to `database.json`

#### database.json

**Format:** JSON
**Purpose:** Fallback storage when SQLite is unavailable
**Structure:**

```json
{
  "default": {
    "key1": "value1",
    "key2": "value2"
  },
  "agents": { ... },
  "tasks": { ... }
}
```

#### config.json

**Format:** JSON
**Purpose:** Core configuration settings
**Structure:** See `src/core/ConfigManager.ts:10-90`

```json
{
  "mode": "standard",
  "topology": "mesh",
  "maxAgents": 8,
  "strategy": "balanced",
  "database": {
    "type": "sqlite",
    "path": ".claude-flow/database.sqlite"
  },
  "debug": false,
  "logLevel": "info",
  "mcpServers": [ ... ],
  "github": { ... },
  "neural": { ... },
  "hiveMind": { ... }
}
```

#### token-usage.json

**Format:** JSON
**Purpose:** Track Claude API token usage
**Structure:**

```json
{
  "total": 12500,
  "input": 8000,
  "output": 4500,
  "byAgent": {
    "coder-1": 3000,
    "reviewer-1": 2500
  },
  "lastUpdated": "2025-01-18T12:00:00Z"
}
```

#### monitoring.config.json

**Format:** JSON
**Purpose:** Monitoring and telemetry configuration
**Structure:**

```json
{
  "enabled": true,
  "telemetry": {
    "claudeCode": {
      "env": "CLAUDE_CODE_ENABLE_TELEMETRY",
      "value": "1"
    }
  },
  "tracking": {
    "tokens": true,
    "costs": true,
    "agents": true,
    "sessions": true
  },
  "storage": {
    "location": ".claude-flow/token-usage.json",
    "format": "json",
    "rotation": "monthly"
  }
}
```

#### swarm-config.json

**Format:** JSON
**Purpose:** Swarm topology and agent profiles
**Structure:**

```json
{
  "defaultStrategy": "balanced",
  "topology": "mesh",
  "agentProfiles": [
    {
      "type": "coder",
      "capabilities": ["python", "javascript"],
      "maxConcurrent": 3
    }
  ]
}
```

#### metrics/system-metrics.json

**Format:** JSON array
**Purpose:** System performance metrics over time
**Structure:**

```json
[
  {
    "timestamp": "2025-01-18T12:00:00Z",
    "memoryUsagePercent": 45.2,
    "cpuLoad": 0.32,
    "activeAgents": 5,
    "activeTasks": 12
  }
]
```

#### metrics/task-metrics.json

**Format:** JSON array
**Purpose:** Task execution performance
**Structure:**

```json
[
  {
    "taskId": "task-123",
    "duration": 125.5,
    "success": true,
    "agentType": "coder",
    "timestamp": "2025-01-18T12:00:00Z"
  }
]
```

### Lifecycle

**Created:** First `init` command or swarm execution
**Updated:** Continuously during operation
**Cleaned:** Manually via `cleanup` commands
**Persistence:** Permanent (gitignored)

### Security

**Permissions:** User read/write only (`chmod 700`)
**Sensitive Data:** API keys stored in `config.json` (should use env vars instead)
**Gitignored:** Yes (via `.gitignore`)

---

## .swarm/ Directory

### Purpose

The `.swarm/` directory stores **swarm coordination data** and the **ReasoningBank memory database**. It's the central coordination point for multi-agent swarms.

### Creation

**When:** First swarm operation or memory initialization
**Location:** `{project-root}/.swarm/`
**Code Reference:** `src/cli/simple-commands/init/index.js:1536-1539`

```javascript
const standardDirs = ['.swarm', ...];
for (const dir of standardDirs) {
  await fs.mkdir(`${workingDir}/${dir}`, { recursive: true });
}
```

### Directory Structure

```
.swarm/
├── memory.db            # SQLite database (ReasoningBank)
├── memory.db-journal    # SQLite journal file
├── memory.db-wal        # SQLite write-ahead log
├── session-*.json       # Session state snapshots
└── coordination/        # Coordination data (future)
```

### File Descriptions

#### memory.db

**Format:** SQLite 3 database
**Purpose:** ReasoningBank adaptive memory system
**Size:** Grows with usage (typically 1-100 MB)
**Schema:** See `src/reasoningbank/` and AgentDB integration

```sql
-- ReasoningBank Tables
CREATE TABLE memories (
  id TEXT PRIMARY KEY,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  namespace TEXT,
  confidence REAL,
  usage_count INTEGER,
  created_at DATETIME,
  updated_at DATETIME
);

CREATE TABLE patterns (
  id TEXT PRIMARY KEY,
  type TEXT,
  pattern_data TEXT,
  confidence REAL
);

CREATE TABLE trajectories (
  id TEXT PRIMARY KEY,
  agent_id TEXT,
  trajectory_data TEXT,
  verdict TEXT,
  timestamp DATETIME
);

-- Plus embedding tables for semantic search
```

**Initialization:**
- Created by `memory init --reasoningbank`
- Or auto-created on first memory operation
- Uses better-sqlite3 (local install) or fallback to JSON (npx mode)

#### memory.db-journal & memory.db-wal

**Format:** SQLite auxiliary files
**Purpose:** Transaction logging and write-ahead logging
**Lifecycle:** Created/deleted automatically by SQLite
**Size:** Temporary, usually small (< 1 MB)

#### session-*.json

**Format:** JSON
**Purpose:** Session state snapshots for recovery
**Structure:**

```json
{
  "sessionId": "session-1234567890-abc",
  "swarmId": "swarm-abc123",
  "active": true,
  "agents": [ ... ],
  "tasks": [ ... ],
  "timestamp": "2025-01-18T12:00:00Z"
}
```

### Lifecycle

**Created:** First swarm spawn or memory operation
**Updated:** Every memory operation, session state change
**Cleaned:** Manual cleanup or session end
**Persistence:** Long-term (gitignored)

### Security

**Permissions:** User read/write (`chmod 700`)
**Sensitive Data:** Memory may contain API keys (use `--redact` flag)
**Backup:** Should be backed up regularly
**Gitignored:** Yes

---

## .claude/ Directory

### Purpose

The `.claude/` directory stores **Claude Code integration files**, including agent definitions, slash commands, hooks, and settings.

### Creation

**When:** `init` command
**Location:** `{project-root}/.claude/`
**Code Reference:** `src/cli/simple-commands/init/index.js:1366-1374`

```javascript
const claudeDir = `${workingDir}/.claude`;
await fs.mkdir(claudeDir, { recursive: true });
await fs.mkdir(`${claudeDir}/commands`, { recursive: true });
await fs.mkdir(`${claudeDir}/helpers`, { recursive: true });
await fs.mkdir(`${claudeDir}/checkpoints`, { recursive: true });
```

### Directory Structure

```
.claude/
├── settings.json              # Main Claude Code settings
├── settings.local.json        # Local overrides (gitignored)
├── statusline-command.sh      # Custom statusline script
├── agents/                    # Agent definitions (64 agents)
│   ├── core/
│   │   ├── coder.md
│   │   ├── reviewer.md
│   │   ├── tester.md
│   │   ├── planner.md
│   │   └── researcher.md
│   ├── swarm/
│   │   ├── coordinator.md
│   │   ├── mesh-coordinator.md
│   │   └── hierarchical-coordinator.md
│   ├── reasoning/
│   │   ├── goal-planner.md
│   │   └── sublinear-goal-planner.md
│   └── flow-nexus/
│       └── *.md
├── commands/                  # Slash commands
│   ├── core/
│   ├── swarm/
│   ├── sparc/
│   └── flow-nexus/
├── checkpoints/               # Git checkpoint system
│   ├── 1756224544.json
│   └── summary-session-*.md
├── helpers/                   # Helper scripts
│   ├── setup-mcp.sh
│   ├── github-setup.sh
│   ├── checkpoint-manager.sh
│   └── standard-checkpoint-hooks.sh
└── logs/                      # Command execution logs
```

### File Descriptions

#### settings.json

**Format:** JSON
**Purpose:** Claude Code configuration with hooks
**Structure:**

```json
{
  "statusline": {
    "command": [".claude/statusline-command.sh"]
  },
  "hooks": {
    "pre-task": ["npx claude-flow@alpha hooks pre-task --description {{description}}"],
    "post-task": ["npx claude-flow@alpha hooks post-task --task-id {{task_id}}"],
    "post-edit": ["npx claude-flow@alpha hooks post-edit --file {{file}} --memory-key swarm/{{agent}}/{{step}}"]
  },
  "gitCheckpoints": {
    "enabled": true,
    "autoCommit": true
  }
}
```

#### settings.local.json

**Format:** JSON
**Purpose:** Local permissions and overrides
**Structure:**

```json
{
  "permissions": {
    "allow": ["mcp__ruv-swarm", "mcp__claude-flow@alpha"],
    "deny": []
  }
}
```

**Gitignored:** Yes (local-only configuration)

#### statusline-command.sh

**Format:** Bash script
**Purpose:** Custom statusline showing swarm metrics
**Features:**
- Displays swarm topology
- Shows agent count
- Memory/CPU usage
- Active tasks
- Success rate and streak

**Code Reference:** `src/cli/simple-commands/init/index.js:152-329`

#### agents/*.md

**Format:** Markdown with YAML frontmatter
**Purpose:** Agent role definitions
**Structure:**

```markdown
---
name: "Coder Agent"
type: "coder"
capabilities: ["coding", "debugging", "refactoring"]
---

# Coder Agent

## Role
Expert software developer...

## Capabilities
- Write clean, efficient code
- Debug complex issues
- Refactor for maintainability

## Best Practices
- Test-driven development
- Code review integration
- Documentation
```

**Total Agents:** 64 specialized agents across categories

#### commands/*.md

**Format:** Markdown
**Purpose:** Slash command definitions
**Structure:**

```markdown
# /sparc-tdd

Execute SPARC TDD workflow...

## Usage
/sparc-tdd "Build authentication system"

## Parameters
- objective: The feature to build (required)
- coverage: Test coverage target (default: 80%)
```

#### checkpoints/*.json

**Format:** JSON
**Purpose:** Git checkpoint metadata
**Structure:**

```json
{
  "checkpoint_id": 1756224544,
  "commit_hash": "abc123...",
  "timestamp": "2025-01-18T12:00:00Z",
  "description": "Pre-task checkpoint",
  "files_changed": ["src/app.js", "tests/app.test.js"]
}
```

#### helpers/*.sh

**Format:** Bash scripts
**Purpose:** Utility scripts for setup and automation
**Examples:**
- `setup-mcp.sh`: Configure MCP servers
- `github-setup.sh`: GitHub integration setup
- `checkpoint-manager.sh`: Manage checkpoints
- `standard-checkpoint-hooks.sh`: Standard hook patterns

### Lifecycle

**Created:** `init` command
**Updated:** Adding/modifying agents, commands, hooks
**Cleaned:** Manual (agent definitions persist)
**Persistence:** Long-term (partially gitignored)

### Security

**Permissions:** Mixed (scripts: 755, configs: 644)
**Sensitive Data:** Minimal (settings.local.json gitignored)
**Gitignored:** `settings.local.json`, `logs/`

---

## .hive-mind/ Directory

### Purpose

The `.hive-mind/` directory stores **hive-mind swarm system data**, including the queen-worker coordination database and configuration.

### Creation

**When:** `hive-mind init` command
**Location:** `{project-root}/.hive-mind/`
**Code Reference:** `src/cli/simple-commands/hive-mind.js:127-130`

```javascript
const hiveMindDir = path.join(cwd(), '.hive-mind');
if (!existsSync(hiveMindDir)) {
  mkdirSync(hiveMindDir, { recursive: true });
}
```

### Directory Structure

```
.hive-mind/
├── hive.db              # SQLite database
├── hive.db-journal      # SQLite journal
├── hive.db-wal          # SQLite WAL
├── config.json          # Configuration
└── sessions/            # Session data
```

### File Descriptions

#### hive.db

**Format:** SQLite 3 database
**Purpose:** Queen-led swarm coordination
**Schema:** See `src/cli/simple-commands/hive-mind.js:136-201`

```sql
CREATE TABLE swarms (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  objective TEXT,
  status TEXT DEFAULT 'active',
  queen_type TEXT DEFAULT 'strategic',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE agents (
  id TEXT PRIMARY KEY,
  swarm_id TEXT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  role TEXT,
  status TEXT DEFAULT 'idle',
  capabilities TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (swarm_id) REFERENCES swarms(id)
);

CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  swarm_id TEXT,
  agent_id TEXT,
  description TEXT,
  status TEXT DEFAULT 'pending',
  priority INTEGER DEFAULT 5,
  result TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME,
  FOREIGN KEY (swarm_id) REFERENCES swarms(id),
  FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE TABLE collective_memory (
  id TEXT PRIMARY KEY,
  swarm_id TEXT,
  key TEXT NOT NULL,
  value TEXT,
  type TEXT DEFAULT 'knowledge',
  confidence REAL DEFAULT 1.0,
  created_by TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  accessed_at DATETIME,
  access_count INTEGER DEFAULT 0,
  FOREIGN KEY (swarm_id) REFERENCES swarms(id)
);

CREATE TABLE consensus_decisions (
  id TEXT PRIMARY KEY,
  swarm_id TEXT,
  topic TEXT NOT NULL,
  decision TEXT,
  votes TEXT,
  algorithm TEXT DEFAULT 'majority',
  confidence REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (swarm_id) REFERENCES swarms(id)
);
```

#### config.json

**Format:** JSON
**Purpose:** Hive-mind configuration
**Structure:**

```json
{
  "version": "2.0.0",
  "initialized": "2025-01-18T12:00:00Z",
  "defaults": {
    "queenType": "strategic",
    "maxWorkers": 8,
    "consensusAlgorithm": "majority",
    "memorySize": 100,
    "autoScale": true,
    "encryption": false
  },
  "mcpTools": {
    "enabled": true,
    "parallel": true,
    "timeout": 60000
  }
}
```

### Lifecycle

**Created:** `hive-mind init`
**Updated:** Each hive-mind spawn operation
**Cleaned:** Manual or session end
**Persistence:** Long-term (gitignored)

### Security

**Permissions:** User read/write (`chmod 700`)
**Sensitive Data:** Task results may contain sensitive info
**Gitignored:** Yes

---

## .ruv-swarm/ Directory

### Purpose

The `.ruv-swarm/` directory stores **ruv-swarm coordination data**, including consensus algorithms and state synchronization.

**Note:** This directory is created by the optional `ruv-swarm` MCP server, not core claude-flow.

### Creation

**When:** ruv-swarm MCP server initialization
**Location:** `{project-root}/.ruv-swarm/`
**Optional:** Yes (requires ruv-swarm MCP server)

### Directory Structure

```
.ruv-swarm/
├── consensus.db         # Consensus data
├── topology.json        # Network topology
└── state-sync.json      # State synchronization
```

### File Descriptions

#### consensus.db

**Format:** SQLite 3
**Purpose:** Byzantine/Raft consensus data
**Schema:** Implementation-specific

#### topology.json

**Format:** JSON
**Purpose:** Network topology and peer discovery
**Structure:**

```json
{
  "nodes": [
    {"id": "node-1", "address": "localhost:5000"},
    {"id": "node-2", "address": "localhost:5001"}
  ],
  "edges": [
    {"from": "node-1", "to": "node-2"}
  ]
}
```

#### state-sync.json

**Format:** JSON
**Purpose:** State synchronization across nodes
**Structure:**

```json
{
  "lastSync": "2025-01-18T12:00:00Z",
  "version": 123,
  "checksum": "abc123..."
}
```

### Lifecycle

**Created:** ruv-swarm initialization
**Updated:** Consensus operations
**Cleaned:** Manual
**Persistence:** Long-term (gitignored)

### Security

**Permissions:** User read/write (`chmod 700`)
**Sensitive Data:** Consensus state
**Gitignored:** Yes

---

## Other Runtime Directories

### memory/

**Purpose:** Legacy JSON-based memory storage
**Location:** `{project-root}/memory/`
**Gitignored:** Yes

```
memory/
├── claude-flow-data.json
├── memory-store.json
├── agents/
│   └── README.md
└── sessions/
    └── README.md
```

### coordination/

**Purpose:** Coordination data storage
**Location:** `{project-root}/coordination/`
**Gitignored:** Yes

```
coordination/
├── memory_bank/
├── subtasks/
└── orchestration/
```

### Home Directory (~/.claude/)

**Purpose:** Global Claude Code settings
**Location:** `~/.claude/`
**Created By:** Claude Code CLI

```
~/.claude/
└── statusline-command.sh  # Copied from project .claude/
```

---

## Security & Permissions

### Recommended Permissions

| Directory | Permissions | Owner | Group |
|-----------|-------------|-------|-------|
| `.claude-flow/` | `700` | user | user |
| `.swarm/` | `700` | user | user |
| `.claude/` | `755` | user | user |
| `.hive-mind/` | `700` | user | user |
| `.ruv-swarm/` | `700` | user | user |
| `memory/` | `700` | user | user |
| `coordination/` | `700` | user | user |

### Scripts Permissions

```bash
# Make helper scripts executable
chmod 755 .claude/helpers/*.sh
chmod 755 .claude/statusline-command.sh
```

### Sensitive Data Protection

1. **API Keys:**
   - NEVER store in config files
   - Use environment variables
   - Use `.env` files (gitignored)

2. **Memory Redaction:**
   ```bash
   # Use --redact flag when storing sensitive data
   npx claude-flow memory store api_key "sk-ant-..." --redact
   ```

3. **Database Encryption:**
   - SQLite databases are NOT encrypted by default
   - Use `--encryption` flag for sensitive data
   - Consider SQLCipher for encrypted databases

### Gitignore Entries

**From:** `src/cli/simple-commands/init/gitignore-updater.js:11-38`

```gitignore
# Claude Flow generated files
.claude/settings.local.json
.mcp.json
claude-flow.config.json
.swarm/
.hive-mind/
.claude-flow/
memory/
coordination/
memory/claude-flow-data.json
memory/sessions/*
!memory/sessions/README.md
memory/agents/*
!memory/agents/README.md
coordination/memory_bank/*
coordination/subtasks/*
coordination/orchestration/*
*.db
*.db-journal
*.db-wal
*.sqlite
*.sqlite-journal
*.sqlite-wal
claude-flow
hive-mind-prompt-*.txt
```

---

## Maintenance & Operations

### Backup

#### Recommended Backup Strategy

```bash
# Backup all runtime data
tar -czf claude-flow-backup-$(date +%Y%m%d).tar.gz \
  .claude-flow/ \
  .swarm/ \
  .claude/ \
  .hive-mind/ \
  .ruv-swarm/ \
  memory/ \
  coordination/

# Exclude large log files
tar --exclude='*.log' --exclude='*.db-wal' \
  -czf claude-flow-backup-$(date +%Y%m%d).tar.gz \
  .claude-flow/ .swarm/ .claude/ .hive-mind/
```

#### Critical Files to Backup

- `.swarm/memory.db` (ReasoningBank data)
- `.hive-mind/hive.db` (Swarm coordination)
- `.claude-flow/database.sqlite` (Core data)
- `.claude/agents/` (Custom agents)
- `.claude/commands/` (Custom commands)

### Restore

```bash
# Restore from backup
tar -xzf claude-flow-backup-20250118.tar.gz

# Verify database integrity
sqlite3 .swarm/memory.db "PRAGMA integrity_check;"
sqlite3 .hive-mind/hive.db "PRAGMA integrity_check;"
sqlite3 .claude-flow/database.sqlite "PRAGMA integrity_check;"
```

### Cleanup

#### Safe Cleanup Commands

```bash
# Clean old logs (keep last 7 days)
find .claude-flow/logs/ -name "*.log" -mtime +7 -delete

# Clean WAL files (if database is idle)
rm .swarm/memory.db-wal
rm .hive-mind/hive.db-wal

# Clean old checkpoints (keep last 30)
cd .claude/checkpoints/
ls -t *.json | tail -n +31 | xargs rm

# Clean temporary session files
rm .swarm/session-*.json
```

#### Database Vacuum

```bash
# Reclaim space from deleted records
sqlite3 .swarm/memory.db "VACUUM;"
sqlite3 .hive-mind/hive.db "VACUUM;"
sqlite3 .claude-flow/database.sqlite "VACUUM;"
```

### Migration

#### Moving Between Machines

```bash
# Export on source machine
npx claude-flow memory export memory-export.json
tar -czf claude-flow-portable.tar.gz \
  memory-export.json \
  .claude/agents/ \
  .claude/commands/ \
  .claude-flow/config.json

# Import on destination machine
npx claude-flow init
tar -xzf claude-flow-portable.tar.gz
npx claude-flow memory import memory-export.json
```

#### Upgrading Versions

```bash
# Before upgrade: backup everything
tar -czf pre-upgrade-backup.tar.gz .claude-flow/ .swarm/ .claude/

# After upgrade: check compatibility
npx claude-flow status
npx claude-flow memory stats

# If issues: rollback
rm -rf .claude-flow/ .swarm/
tar -xzf pre-upgrade-backup.tar.gz
```

---

## Troubleshooting

### Common Issues

#### 1. Database Locked Error

**Symptom:**
```
Error: database is locked
```

**Solution:**
```bash
# Check for lock files
ls -la .swarm/memory.db-*

# Remove stale WAL/journal files (only if no processes running)
rm .swarm/memory.db-wal
rm .swarm/memory.db-journal

# Check for zombie processes
ps aux | grep claude-flow
```

#### 2. Permission Denied

**Symptom:**
```
Error: EACCES: permission denied
```

**Solution:**
```bash
# Fix directory permissions
chmod -R 700 .claude-flow/
chmod -R 700 .swarm/
chmod -R 700 .hive-mind/

# Fix script permissions
chmod 755 .claude/helpers/*.sh
```

#### 3. Disk Space Issues

**Symptom:**
```
Error: ENOSPC: no space left on device
```

**Solution:**
```bash
# Check disk usage
du -sh .claude-flow/ .swarm/ .hive-mind/

# Find large files
find . -type f -size +100M

# Clean up logs
find .claude-flow/logs/ -name "*.log" -mtime +7 -delete

# Vacuum databases
sqlite3 .swarm/memory.db "VACUUM;"
```

#### 4. Corrupted Database

**Symptom:**
```
Error: database disk image is malformed
```

**Solution:**
```bash
# Check integrity
sqlite3 .swarm/memory.db "PRAGMA integrity_check;"

# Attempt recovery
sqlite3 .swarm/memory.db ".recover" > memory-recovered.sql
mv .swarm/memory.db .swarm/memory.db.corrupt
sqlite3 .swarm/memory.db < memory-recovered.sql

# Restore from backup if recovery fails
cp backup/memory.db .swarm/memory.db
```

#### 5. Missing Dependencies (npx mode)

**Symptom:**
```
Error: Cannot find module 'better-sqlite3'
```

**Solution:**
```bash
# Install locally instead of using npx
npm install -g claude-flow@alpha

# Or use JSON fallback (automatic in npx mode)
# Just run commands normally - fallback is automatic
```

### Diagnostic Commands

```bash
# Check system status
npx claude-flow status

# Verify database integrity
sqlite3 .swarm/memory.db "PRAGMA integrity_check;"
sqlite3 .hive-mind/hive.db "PRAGMA integrity_check;"

# Check memory stats
npx claude-flow memory stats

# List all swarms
npx claude-flow hive-mind sessions

# Check file permissions
ls -la .claude-flow/
ls -la .swarm/
ls -la .hive-mind/

# Check disk usage
du -sh .claude-flow/ .swarm/ .hive-mind/ memory/
```

### Log Analysis

```bash
# View recent logs
tail -f .claude-flow/logs/latest.log

# Search for errors
grep -r "Error:" .claude-flow/logs/

# Check session logs
ls -la .claude/checkpoints/
cat .claude/checkpoints/summary-session-*.md
```

---

## Inspection Commands

### Quick Reference

```bash
# List all runtime directories
ls -la | grep "^\."

# Show directory sizes
du -sh .claude-flow/ .swarm/ .claude/ .hive-mind/ memory/

# Count files in each directory
find .claude-flow/ -type f | wc -l
find .swarm/ -type f | wc -l
find .claude/ -type f | wc -l

# Show database info
sqlite3 .swarm/memory.db "SELECT name FROM sqlite_master WHERE type='table';"
sqlite3 .hive-mind/hive.db "SELECT name FROM sqlite_master WHERE type='table';"

# Show recent activity
find .claude-flow/ -type f -mtime -1
find .swarm/ -type f -mtime -1

# Check configuration
cat .claude-flow/config.json | jq
cat .hive-mind/config.json | jq
cat .claude/settings.json | jq
```

### Advanced Inspection

```bash
# Export database schema
sqlite3 .swarm/memory.db .schema > schema-memory.sql
sqlite3 .hive-mind/hive.db .schema > schema-hive.sql

# Count records in each table
sqlite3 .swarm/memory.db "SELECT COUNT(*) FROM memories;"
sqlite3 .hive-mind/hive.db "SELECT COUNT(*) FROM swarms;"
sqlite3 .hive-mind/hive.db "SELECT COUNT(*) FROM agents;"

# Show memory usage by namespace
sqlite3 .swarm/memory.db "SELECT namespace, COUNT(*) FROM memories GROUP BY namespace;"

# Show active swarms
sqlite3 .hive-mind/hive.db "SELECT id, name, status, created_at FROM swarms WHERE status='active';"

# Analyze checkpoint history
ls -ltr .claude/checkpoints/*.json | tail -10
```

---

## Summary

### Directory Quick Reference

| Directory | Primary Use | Database | Size | Gitignored |
|-----------|-------------|----------|------|------------|
| `.claude-flow/` | Core runtime | SQLite/JSON | 10-50 MB | Yes |
| `.swarm/` | Memory & coordination | SQLite | 1-100 MB | Yes |
| `.claude/` | Claude Code integration | N/A | 5-20 MB | Partial |
| `.hive-mind/` | Hive-mind system | SQLite | 5-50 MB | Yes |
| `.ruv-swarm/` | Consensus (optional) | SQLite | 5-20 MB | Yes |
| `memory/` | Legacy storage | JSON | 1-10 MB | Yes |
| `coordination/` | Coordination data | JSON | 1-10 MB | Yes |

### Key Takeaways

1. **Primary Storage:** `.claude-flow/database.sqlite` and `.swarm/memory.db`
2. **Configuration:** `.claude-flow/config.json`, `.claude/settings.json`, `.hive-mind/config.json`
3. **Gitignore:** All runtime directories are gitignored (except `.claude/agents` and `.claude/commands`)
4. **Backup Priority:** Focus on `.swarm/memory.db` and `.hive-mind/hive.db`
5. **Cleanup:** Safe to delete logs and WAL files when idle
6. **Migration:** Use export/import commands for portability

---

## See Also

- [Architecture Overview](01-architecture-overview.md)
- [Data Models & Integration](05-data-models-and-integration.md)
- [Troubleshooting Cookbook](12-troubleshooting-cookbook.md)
- [Performance Analysis](11-performance-analysis.md)

---

**Document Metadata:**
- **Created:** 2025-01-18
- **Last Updated:** 2025-01-18
- **Version:** 1.0.0
- **Author:** Research Agent
- **Status:** Complete
