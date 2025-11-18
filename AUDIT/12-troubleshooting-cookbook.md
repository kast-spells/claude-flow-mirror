# Claude-Flow Troubleshooting Cookbook

**Version:** 2.0.0
**Last Updated:** 2025-11-18
**Maintainer:** Claude-Flow Team

## Table of Contents

1. [Installation and Setup Issues](#1-installation-and-setup-issues)
2. [Agent Issues](#2-agent-issues)
3. [Memory Issues](#3-memory-issues)
4. [MCP Server Issues](#4-mcp-server-issues)
5. [Swarm Coordination Issues](#5-swarm-coordination-issues)
6. [Performance Issues](#6-performance-issues)
7. [Integration Issues](#7-integration-issues)
8. [Hook Issues](#8-hook-issues)
9. [Common Error Messages](#9-common-error-messages)
10. [Debugging Workflows](#10-debugging-workflows)

---

## 1. Installation and Setup Issues

### Problem: Dependencies Not Installing

**Symptoms:**
- `npm install` fails with module errors
- Missing native dependencies (better-sqlite3, tree-sitter)
- Build failures during installation

**Root Cause:**
- Missing system-level dependencies
- Incompatible Node.js version
- Platform-specific build tools not installed
- Network/proxy issues blocking downloads

**Solution:**

```bash
# 1. Verify Node.js version (requires 18+)
node --version

# 2. Install build tools by platform
# macOS:
xcode-select --install

# Ubuntu/Debian:
sudo apt-get install build-essential python3

# Windows:
npm install --global windows-build-tools

# 3. Clean install
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# 4. If better-sqlite3 fails, use pre-built binaries
npm install better-sqlite3 --build-from-source=false

# 5. Check for ARM64 compatibility (Apple Silicon)
node scripts/install-arm64.js
```

**Prevention:**
- Use Node.js 18+ LTS version
- Keep system build tools updated
- Use `.nvmrc` file for version consistency
- Document platform-specific requirements

**Related Issues:**
- [Build Failures](#problem-build-failures)
- [Permission Issues](#problem-permission-issues)

---

### Problem: Build Failures

**Symptoms:**
- TypeScript compilation errors
- Module resolution failures
- `npm run build` exits with errors

**Root Cause:**
- TypeScript version mismatch
- Missing type definitions
- Circular dependencies
- Outdated build cache

**Solution:**

```bash
# 1. Clean build artifacts
rm -rf dist dist-cjs dist-esm .tsbuildinfo

# 2. Verify TypeScript version
npm list typescript

# 3. Rebuild with fresh cache
npm run build:clean
npm run build

# 4. Check for circular dependencies
npx madge --circular --extensions ts,js src/

# 5. Validate tsconfig settings
npx tsc --noEmit --listFiles

# 6. Fix common issues
# Update imports to use .js extensions (ESM requirement)
# Ensure all exports are properly typed
```

**Prevention:**
- Pin TypeScript version in package.json
- Use `"type": "module"` for ESM
- Enable strict type checking
- Run `npm run typecheck` in CI/CD

**Related Issues:**
- [Configuration Errors](#problem-configuration-errors)

---

### Problem: Configuration Errors

**Symptoms:**
- "Configuration file not found" errors
- Invalid YAML/JSON syntax errors
- Missing required configuration fields

**Root Cause:**
- Missing `.claude-flow/config.yml`
- Malformed configuration syntax
- Environment variables not set
- File permissions preventing reads

**Solution:**

```bash
# 1. Initialize configuration
npx claude-flow init

# 2. Validate configuration file
npx claude-flow config validate

# 3. Check file exists and is readable
ls -la .claude-flow/config.yml
cat .claude-flow/config.yml

# 4. Use default configuration as template
cp node_modules/claude-flow/config/default.yml .claude-flow/config.yml

# 5. Set required environment variables
export ANTHROPIC_API_KEY="your-api-key"
export CLAUDE_FLOW_LOG_LEVEL="info"

# 6. Fix YAML syntax
# Use online YAML validator or:
npx js-yaml .claude-flow/config.yml
```

**Configuration Template:**

```yaml
# .claude-flow/config.yml
version: "2.0.0"

agents:
  maxConcurrent: 10
  defaultTimeout: 300000

swarm:
  topology: "adaptive"
  consensusThreshold: 0.7

memory:
  provider: "sqlite"
  path: ".swarm/memory.db"

logging:
  level: "info"
  format: "json"
```

**Prevention:**
- Use `claude-flow init` for initial setup
- Version control configuration templates
- Validate configuration in pre-commit hooks
- Document all required fields

---

### Problem: Permission Issues

**Symptoms:**
- "EACCES: permission denied" errors
- Cannot write to `.swarm/` directory
- Hook execution fails with permission errors

**Root Cause:**
- Insufficient file system permissions
- Running with wrong user account
- SELinux/AppArmor restrictions
- File ownership conflicts

**Solution:**

```bash
# 1. Check current permissions
ls -la .swarm/

# 2. Fix ownership (replace USER with your username)
sudo chown -R $USER:$USER .swarm/
sudo chown -R $USER:$USER .claude-flow/

# 3. Set proper permissions
chmod -R 755 .swarm/
chmod -R 755 .claude-flow/
chmod +x hooks/*

# 4. On Windows, run as Administrator or adjust ACLs
# Right-click → Properties → Security → Edit

# 5. For Docker/container environments
# Use proper user mapping in docker-compose.yml:
services:
  claude-flow:
    user: "${UID}:${GID}"
    volumes:
      - ./.swarm:/app/.swarm:rw
```

**Prevention:**
- Run as non-root user
- Use proper user/group in containers
- Document required permissions
- Add `.swarm/` to `.gitignore` but track structure

---

## 2. Agent Issues

### Problem: Agent Won't Spawn

**Symptoms:**
- "Failed to spawn agent" errors
- Agent stuck in "spawning" status
- No response from agent creation

**Root Cause:**
- Maximum concurrent agents reached
- Invalid agent profile configuration
- Resource constraints (CPU/memory)
- Missing required agent dependencies

**Solution:**

```bash
# 1. Check current agent count
npx claude-flow agent list
npx claude-flow swarm status

# 2. Check agent configuration
npx claude-flow config validate

# 3. Increase max concurrent agents (if appropriate)
# Edit .claude-flow/config.yml:
agents:
  maxConcurrent: 20  # Increase from default 10

# 4. Check system resources
npx claude-flow diagnostics
npx claude-flow health-check

# 5. Terminate hung agents
npx claude-flow agent terminate <agent-id>
npx claude-flow swarm reset

# 6. Check logs for detailed errors
tail -f .swarm/logs/agent-*.log
```

**Code Example - Proper Agent Spawning:**

```typescript
// ✅ Correct approach
const agent = await orchestrator.spawnAgent({
  id: 'coder-01',
  type: 'coder',
  role: 'developer',
  maxConcurrentTasks: 5,
  priority: 50,
  capabilities: ['typescript', 'react'],
  config: {
    timeout: 300000,
    retries: 3
  }
});

// ❌ Common mistakes
// Missing required fields
const badAgent = await orchestrator.spawnAgent({ type: 'coder' });

// Invalid configuration
const invalidAgent = await orchestrator.spawnAgent({
  id: 'test',
  type: 'unknown-type',  // Type not registered
  maxConcurrentTasks: 0  // Must be >= 1
});
```

**Prevention:**
- Monitor agent count vs. `maxConcurrent` limit
- Set appropriate timeout values
- Implement graceful agent shutdown
- Use agent pools for high-load scenarios

**Related Issues:**
- [Agent Crashes](#problem-agent-crashes)
- [Resource Contention](#problem-resource-contention)

---

### Problem: Agent Crashes

**Symptoms:**
- Agent terminates unexpectedly
- "Agent failed" events in logs
- Incomplete task execution
- Status changes to "error" or "terminated"

**Root Cause:**
- Unhandled exceptions in agent code
- Memory exhaustion (heap overflow)
- API rate limiting/timeout
- Infinite loops or recursion

**Solution:**

```bash
# 1. Check agent error logs
cat .swarm/logs/agent-<agent-id>.log | grep ERROR

# 2. Enable debug logging
export CLAUDE_FLOW_LOG_LEVEL=debug
npx claude-flow agent spawn coder --debug

# 3. Check memory usage
npx claude-flow diagnostics --detailed

# 4. Review crash reports
ls .swarm/crashes/
cat .swarm/crashes/agent-<agent-id>-<timestamp>.json

# 5. Restart with error recovery
npx claude-flow agent spawn coder --auto-restart --max-retries 3

# 6. Run health check on crashed agent type
npx claude-flow health-check --component agentManager
```

**Crash Analysis Script:**

```bash
#!/bin/bash
# analyze-agent-crash.sh

AGENT_ID=$1

echo "=== Agent Crash Analysis ==="
echo "Agent ID: $AGENT_ID"
echo ""

echo "Last 50 log entries:"
tail -50 .swarm/logs/agent-$AGENT_ID.log

echo -e "\n=== Error Summary ==="
grep -i "error\|exception\|fatal" .swarm/logs/agent-$AGENT_ID.log | tail -10

echo -e "\n=== Memory Usage Before Crash ==="
grep "memory" .swarm/logs/agent-$AGENT_ID.log | tail -5

echo -e "\n=== Stack Trace ==="
if [ -f ".swarm/crashes/agent-$AGENT_ID-*.json" ]; then
  cat .swarm/crashes/agent-$AGENT_ID-*.json | jq '.stack'
fi
```

**Prevention:**
- Implement proper error boundaries
- Set memory limits per agent
- Add timeout protection for long operations
- Use circuit breakers for external API calls
- Monitor agent health continuously

---

### Problem: Agent Hangs/Timeouts

**Symptoms:**
- Agent stops responding
- Tasks never complete
- Timeout errors after waiting period
- No heartbeat from agent

**Root Cause:**
- Deadlock in agent code
- Waiting for unavailable resources
- Network request hangs
- Infinite wait on promise

**Solution:**

```bash
# 1. Check agent status and last heartbeat
npx claude-flow agent status <agent-id>

# 2. Force terminate hung agent
npx claude-flow agent terminate <agent-id> --force

# 3. Check what agent is waiting for
npx claude-flow agent inspect <agent-id> --show-stack

# 4. Adjust timeout settings
# Edit .claude-flow/config.yml:
agents:
  defaultTimeout: 600000  # 10 minutes
  heartbeatInterval: 5000  # 5 seconds
  heartbeatTimeout: 30000  # 30 seconds

# 5. Enable timeout debugging
export CLAUDE_FLOW_DEBUG_TIMEOUTS=true
npx claude-flow agent spawn coder
```

**Timeout Configuration Example:**

```typescript
// Set task-level timeout
const result = await agent.executeTask({
  id: 'task-1',
  description: 'Long running task',
  timeout: 600000,  // 10 minutes
  onTimeout: async () => {
    // Cleanup logic
    await cleanup();
    throw new Error('Task timed out');
  }
});

// Set operation-level timeout with Promise.race
const result = await Promise.race([
  agent.doWork(),
  new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Operation timeout')), 30000)
  )
]);
```

**Prevention:**
- Always set timeouts on async operations
- Implement heartbeat mechanism
- Use watchdog timers
- Add progress reporting for long tasks
- Implement graceful timeout handling

---

### Problem: Agent Communication Failures

**Symptoms:**
- Agents can't send/receive messages
- Event bus errors
- "Message delivery failed" logs
- Swarm coordination breaks down

**Root Cause:**
- Event bus not initialized
- Message queue overflow
- Network partition in distributed setup
- Serialization errors for complex objects

**Solution:**

```bash
# 1. Verify event bus status
npx claude-flow diagnostics --component eventBus

# 2. Check message queue health
npx claude-flow swarm status --show-queues

# 3. Restart event bus
npx claude-flow swarm restart --component event-bus

# 4. Clear message queue if stuck
npx claude-flow swarm reset-queue

# 5. Enable message debugging
export CLAUDE_FLOW_DEBUG_EVENTS=true
npx claude-flow swarm start --verbose
```

**Event Bus Debugging:**

```typescript
// Enable event tracing
import { EventBus } from './core/event-bus.js';

const eventBus = EventBus.getInstance();

// Log all events
eventBus.onAny((event, data) => {
  console.log(`[EVENT] ${event}:`, JSON.stringify(data, null, 2));
});

// Monitor specific events
eventBus.on('agent:message:failed', (error) => {
  console.error('Message delivery failed:', error);
  // Retry logic
  eventBus.emit('agent:message:retry', error.message);
});

// Check listener count (detect memory leaks)
console.log('Event listeners:', eventBus.listenerCount());
```

**Prevention:**
- Use message acknowledgment patterns
- Implement retry with exponential backoff
- Set maximum message queue size
- Use dead-letter queues for failed messages
- Monitor event bus metrics

---

## 3. Memory Issues

### Problem: Memory Leaks

**Symptoms:**
- Steadily increasing memory usage
- Process crashes with "Heap out of memory"
- Performance degradation over time
- System becomes unresponsive

**Root Cause:**
- Event listeners not removed
- Large objects retained in closures
- Cache not bounded
- Database connections not closed

**Solution:**

```bash
# 1. Generate heap snapshot
node --expose-gc --inspect your-app.js
# Then in Chrome DevTools: Memory → Take heap snapshot

# 2. Use built-in memory profiling
npx clinic doctor -- npx claude-flow swarm start

# 3. Check for memory leaks
npx claude-flow diagnostics --check-memory-leaks

# 4. Enable memory monitoring
export NODE_OPTIONS="--max-old-space-size=4096 --trace-gc"
npx claude-flow swarm start --monitor-memory

# 5. Force garbage collection periodically
node --expose-gc index.js
```

**Memory Leak Detection:**

```typescript
// Memory monitoring example
import { MemoryMonitor } from './monitoring/memory-monitor.js';

const monitor = new MemoryMonitor({
  interval: 10000,  // Check every 10 seconds
  threshold: 0.9,   // Alert at 90% heap usage
  leakThreshold: 1.5 // Alert if 50% growth over baseline
});

monitor.on('leak-detected', (metrics) => {
  console.error('Memory leak detected!', metrics);
  // Take heap snapshot
  monitor.takeHeapSnapshot(`leak-${Date.now()}.heapsnapshot`);
  // Alert
  eventBus.emit('health:alert', {
    type: 'memory_leak',
    severity: 'high',
    metrics
  });
});

monitor.start();
```

**Common Memory Leak Patterns:**

```typescript
// ❌ BAD: Event listener not removed
class Agent {
  constructor() {
    eventBus.on('task', this.handleTask.bind(this));
  }
  // No cleanup on destroy!
}

// ✅ GOOD: Proper cleanup
class Agent {
  private handler: Function;

  constructor() {
    this.handler = this.handleTask.bind(this);
    eventBus.on('task', this.handler);
  }

  destroy() {
    eventBus.off('task', this.handler);
  }
}

// ❌ BAD: Unbounded cache
const cache = new Map();
cache.set(key, largeObject);  // Never cleared!

// ✅ GOOD: LRU cache with size limit
import LRU from 'lru-cache';
const cache = new LRU({
  max: 1000,
  maxSize: 50 * 1024 * 1024,  // 50MB
  sizeCalculation: (value) => JSON.stringify(value).length
});
```

**Prevention:**
- Use WeakMap/WeakSet for object caching
- Implement proper cleanup in destroy methods
- Set bounds on all caches and queues
- Monitor heap usage continuously
- Use connection pooling with limits

**Related Issues:**
- [Performance Issues](#6-performance-issues)
- [Database Connection Failures](#problem-database-connection-failures)

---

### Problem: Database Connection Failures

**Symptoms:**
- "SQLITE_CANTOPEN" errors
- "Database is locked" errors
- Connection timeout errors
- Too many open connections

**Root Cause:**
- Database file permissions incorrect
- Concurrent writes exceeding SQLite limits
- Database file corrupted
- Connection pool exhausted

**Solution:**

```bash
# 1. Check database file permissions
ls -la .swarm/memory.db
chmod 666 .swarm/memory.db

# 2. Verify database integrity
sqlite3 .swarm/memory.db "PRAGMA integrity_check;"

# 3. Check for locks
lsof | grep memory.db

# 4. Fix corrupted database
# Backup first!
cp .swarm/memory.db .swarm/memory.db.backup
sqlite3 .swarm/memory.db "VACUUM;"

# 5. Rebuild database from scratch
mv .swarm/memory.db .swarm/memory.db.old
npx claude-flow memory init

# 6. Adjust connection settings
# Edit config:
memory:
  provider: "sqlite"
  path: ".swarm/memory.db"
  options:
    maxConnections: 10
    busyTimeout: 5000
    journalMode: "WAL"  # Better concurrent access
```

**SQLite Configuration for Better Concurrency:**

```typescript
import Database from 'better-sqlite3';

const db = new Database('.swarm/memory.db', {
  timeout: 5000,  // Wait up to 5s for locks
  verbose: console.log  // Debug mode
});

// Enable WAL mode for better concurrency
db.pragma('journal_mode = WAL');
db.pragma('busy_timeout = 5000');
db.pragma('cache_size = -64000');  // 64MB cache

// Use prepared statements for performance
const insert = db.prepare('INSERT INTO memories (key, value) VALUES (?, ?)');
const insertMany = db.transaction((memories) => {
  for (const memory of memories) {
    insert.run(memory.key, memory.value);
  }
});
```

**Handling Database Locks:**

```typescript
import { retry } from './utils/retry.js';

async function executeWithRetry(fn: () => any, maxRetries = 3) {
  return retry(fn, {
    retries: maxRetries,
    onRetry: (err, attempt) => {
      if (err.code === 'SQLITE_BUSY') {
        console.log(`Database locked, retry ${attempt}/${maxRetries}`);
      }
    },
    retryIf: (err) => err.code === 'SQLITE_BUSY'
  });
}

// Usage
await executeWithRetry(() => {
  db.prepare('INSERT INTO memories VALUES (?, ?)').run(key, value);
});
```

**Prevention:**
- Use WAL mode for SQLite
- Implement connection pooling
- Batch writes to reduce lock contention
- Add retry logic for lock errors
- Consider PostgreSQL for high-concurrency needs

---

### Problem: Query Performance Issues

**Symptoms:**
- Slow memory retrieval
- High CPU during database queries
- Timeouts on large result sets
- Query takes >1 second

**Root Cause:**
- Missing database indexes
- Full table scans on large tables
- Inefficient query patterns
- N+1 query problems

**Solution:**

```bash
# 1. Analyze query performance
sqlite3 .swarm/memory.db
sqlite> EXPLAIN QUERY PLAN SELECT * FROM memories WHERE namespace = 'swarm';

# 2. Check for missing indexes
sqlite> SELECT * FROM sqlite_master WHERE type = 'index';

# 3. Create missing indexes
sqlite> CREATE INDEX idx_namespace ON memories(namespace);
sqlite> CREATE INDEX idx_timestamp ON memories(timestamp);
sqlite> CREATE INDEX idx_key ON memories(key);

# 4. Analyze table statistics
sqlite> ANALYZE;

# 5. Rebuild indexes
sqlite> REINDEX;

# 6. Enable query logging
export CLAUDE_FLOW_LOG_SQL=true
npx claude-flow swarm start
```

**Index Creation for Memory System:**

```sql
-- Core indexes for memory system
CREATE INDEX IF NOT EXISTS idx_memories_namespace
  ON memories(namespace);

CREATE INDEX IF NOT EXISTS idx_memories_key
  ON memories(key);

CREATE INDEX IF NOT EXISTS idx_memories_timestamp
  ON memories(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_memories_ttl
  ON memories(ttl) WHERE ttl IS NOT NULL;

-- Composite index for common query pattern
CREATE INDEX IF NOT EXISTS idx_memories_namespace_key
  ON memories(namespace, key);

-- Full-text search index
CREATE VIRTUAL TABLE IF NOT EXISTS memories_fts
  USING fts5(key, value, content=memories);
```

**Query Optimization Examples:**

```typescript
// ❌ BAD: N+1 query
for (const agent of agents) {
  const memories = await db.getMemories(agent.id);  // Query per agent!
}

// ✅ GOOD: Batch query
const agentIds = agents.map(a => a.id);
const allMemories = await db.getMemoriesBatch(agentIds);
const memoriesByAgent = groupBy(allMemories, 'agentId');

// ❌ BAD: Unindexed query
SELECT * FROM memories WHERE value LIKE '%search%';  // Slow!

// ✅ GOOD: Use indexed columns
SELECT * FROM memories WHERE namespace = 'swarm' AND key = 'status';

// ✅ BETTER: Use full-text search
SELECT * FROM memories_fts WHERE memories_fts MATCH 'search';
```

**Prevention:**
- Add indexes for all WHERE/JOIN columns
- Use EXPLAIN QUERY PLAN before deployment
- Implement pagination for large result sets
- Cache frequently accessed data
- Use read replicas for query-heavy workloads

---

### Problem: Cache Inconsistencies

**Symptoms:**
- Stale data returned from cache
- Cache hit ratio very low
- Memory usage for cache too high
- Different agents see different data

**Root Cause:**
- No cache invalidation strategy
- Race conditions in cache updates
- Cache key collisions
- Distributed cache synchronization issues

**Solution:**

```bash
# 1. Clear all caches
npx claude-flow cache clear --all

# 2. Clear specific cache namespace
npx claude-flow cache clear --namespace swarm

# 3. Check cache statistics
npx claude-flow cache stats

# 4. Verify cache configuration
npx claude-flow config show cache

# 5. Enable cache debugging
export CLAUDE_FLOW_DEBUG_CACHE=true
npx claude-flow swarm start
```

**Cache Invalidation Patterns:**

```typescript
import { CacheManager } from './cache/cache-manager.js';

class MemoryManager {
  private cache: CacheManager;

  async set(key: string, value: any): Promise<void> {
    // Write to database
    await this.db.set(key, value);

    // Update cache
    this.cache.set(key, value, {
      ttl: 60000,  // 1 minute
      tags: ['memory', `key:${key}`]
    });

    // Notify other instances
    this.eventBus.emit('cache:invalidate', { key });
  }

  async get(key: string): Promise<any> {
    // Try cache first
    const cached = this.cache.get(key);
    if (cached !== undefined) {
      return cached;
    }

    // Cache miss - load from database
    const value = await this.db.get(key);

    // Store in cache
    if (value !== undefined) {
      this.cache.set(key, value, { ttl: 60000 });
    }

    return value;
  }

  async invalidate(pattern: string): Promise<void> {
    // Invalidate by tag pattern
    this.cache.invalidateByTag(pattern);
  }
}

// Listen for invalidation events from other instances
eventBus.on('cache:invalidate', ({ key }) => {
  cacheManager.delete(key);
});
```

**Cache Configuration Best Practices:**

```yaml
# .claude-flow/config.yml
cache:
  # Memory cache
  memory:
    enabled: true
    maxSize: 100MB
    ttl: 300000  # 5 minutes default

  # Redis cache (for distributed systems)
  redis:
    enabled: false
    host: localhost
    port: 6379
    ttl: 600000  # 10 minutes

  # Cache invalidation
  invalidation:
    strategy: "time-based"  # or "event-based"
    checkInterval: 10000
```

**Prevention:**
- Implement cache-aside pattern
- Use TTL appropriate for data volatility
- Tag cache entries for bulk invalidation
- Use distributed cache for multi-instance setups
- Monitor cache hit rates

---

## 4. MCP Server Issues

### Problem: Server Won't Start

**Symptoms:**
- "Failed to start MCP server" error
- Port already in use errors
- Server starts but immediately exits
- Connection refused on MCP port

**Root Cause:**
- Port conflict with another process
- Missing MCP server dependencies
- Invalid server configuration
- Permission issues binding to port

**Solution:**

```bash
# 1. Check if port is in use
lsof -i :3000  # Replace 3000 with your MCP port
netstat -tuln | grep 3000

# 2. Kill conflicting process
kill -9 $(lsof -t -i:3000)

# 3. Change MCP server port
# Edit .claude-flow/config.yml:
mcp:
  server:
    port: 3001  # Use different port
    host: "0.0.0.0"

# 4. Check MCP server logs
tail -f .swarm/logs/mcp-server.log

# 5. Start MCP server manually for debugging
npx claude-flow mcp start --debug --verbose

# 6. Verify MCP server dependencies
npm list @modelcontextprotocol/sdk

# 7. Restart with clean state
npx claude-flow mcp stop
rm -rf .swarm/mcp-state/
npx claude-flow mcp start
```

**MCP Server Startup Script:**

```bash
#!/bin/bash
# start-mcp-server.sh

PORT=${MCP_PORT:-3000}
HOST=${MCP_HOST:-0.0.0.0}

echo "Starting MCP server on $HOST:$PORT"

# Check if port is available
if lsof -i :$PORT > /dev/null 2>&1; then
  echo "Error: Port $PORT is already in use"
  echo "Current process:"
  lsof -i :$PORT
  exit 1
fi

# Start server with logging
npx claude-flow mcp start \
  --port $PORT \
  --host $HOST \
  --log-level debug \
  2>&1 | tee -a .swarm/logs/mcp-server.log

# Check if started successfully
sleep 2
if curl -f http://$HOST:$PORT/health > /dev/null 2>&1; then
  echo "MCP server started successfully"
else
  echo "Error: MCP server failed to start"
  exit 1
fi
```

**Prevention:**
- Use dynamic port allocation in development
- Document required ports in README
- Add health check endpoint
- Implement graceful shutdown
- Use process managers (PM2, systemd)

---

### Problem: Tool Registration Failures

**Symptoms:**
- Tools not appearing in MCP tool list
- "Tool not found" errors when calling tools
- MCP schema validation errors
- Tools registered but not callable

**Root Cause:**
- Invalid tool schema
- Tool name conflicts
- Registration timing issues
- Missing tool implementation

**Solution:**

```bash
# 1. List registered tools
npx claude-flow mcp tools list

# 2. Validate tool schema
npx claude-flow mcp tools validate swarm_init

# 3. Check tool registration logs
grep "tool.*register" .swarm/logs/mcp-server.log

# 4. Re-register all tools
npx claude-flow mcp tools reload

# 5. Test specific tool
npx claude-flow mcp tools test swarm_init '{"topology":"mesh"}'

# 6. Enable tool debugging
export MCP_DEBUG_TOOLS=true
npx claude-flow mcp start
```

**Tool Registration Example:**

```typescript
import { MCPServer } from '@modelcontextprotocol/sdk/server/index.js';
import { z } from 'zod';

const server = new MCPServer({
  name: 'claude-flow',
  version: '2.0.0'
});

// Define tool schema
const swarmInitSchema = z.object({
  topology: z.enum(['mesh', 'hierarchical', 'adaptive']),
  maxAgents: z.number().min(1).max(100).optional(),
  consensusThreshold: z.number().min(0).max(1).optional()
});

// Register tool
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [{
    name: 'swarm_init',
    description: 'Initialize a swarm with specified topology',
    inputSchema: {
      type: 'object',
      properties: {
        topology: {
          type: 'string',
          enum: ['mesh', 'hierarchical', 'adaptive'],
          description: 'Swarm topology pattern'
        },
        maxAgents: {
          type: 'number',
          minimum: 1,
          maximum: 100,
          description: 'Maximum number of agents'
        }
      },
      required: ['topology']
    }
  }]
}));

// Implement tool
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === 'swarm_init') {
    // Validate input
    const args = swarmInitSchema.parse(request.params.arguments);

    // Execute
    const result = await swarmManager.init(args);

    return {
      content: [{
        type: 'text',
        text: JSON.stringify(result, null, 2)
      }]
    };
  }

  throw new Error(`Unknown tool: ${request.params.name}`);
});
```

**Common Schema Errors:**

```typescript
// ❌ BAD: Invalid schema
{
  name: 'bad_tool',
  inputSchema: {
    // Missing 'type' field
    properties: { arg: { type: 'string' } }
  }
}

// ✅ GOOD: Valid schema
{
  name: 'good_tool',
  description: 'A properly defined tool',
  inputSchema: {
    type: 'object',
    properties: {
      arg: {
        type: 'string',
        description: 'Argument description'
      }
    },
    required: ['arg']
  }
}
```

**Prevention:**
- Use JSON Schema validation
- Test tools before deployment
- Version tool schemas
- Document tool requirements
- Use type-safe schema builders (Zod)

---

### Problem: Request/Response Errors

**Symptoms:**
- MCP requests timeout
- Invalid response format errors
- JSON parsing errors
- Request queue overflow

**Root Cause:**
- Response exceeds size limit
- Malformed JSON in response
- Request handler throws exception
- Network interruption during transfer

**Solution:**

```bash
# 1. Check request/response logs
tail -f .swarm/logs/mcp-requests.log

# 2. Test specific request
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/list","params":{}}'

# 3. Validate response format
echo '{"result":{}}' | jq .

# 4. Increase timeout settings
# Edit config:
mcp:
  server:
    requestTimeout: 60000  # 60 seconds
    maxResponseSize: 10485760  # 10MB

# 5. Enable response validation
export MCP_VALIDATE_RESPONSES=true
npx claude-flow mcp start
```

**Error Handling in MCP Tools:**

```typescript
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    // Validate request
    if (!request.params.name) {
      throw new Error('Tool name is required');
    }

    // Execute tool
    const result = await executeTool(request.params.name, request.params.arguments);

    // Validate response size
    const response = JSON.stringify(result);
    if (response.length > 10 * 1024 * 1024) {  // 10MB
      throw new Error('Response too large');
    }

    return {
      content: [{
        type: 'text',
        text: response
      }]
    };

  } catch (error) {
    // Return error in MCP format
    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          error: error.message,
          code: error.code || 'INTERNAL_ERROR'
        })
      }],
      isError: true
    };
  }
});
```

**Prevention:**
- Set reasonable timeouts
- Validate all inputs and outputs
- Paginate large responses
- Implement retry logic
- Use streaming for large data

---

### Problem: Protocol Version Mismatches

**Symptoms:**
- "Unsupported protocol version" errors
- Tools not recognized by client
- Handshake failures
- Incompatible message formats

**Root Cause:**
- Client and server using different MCP versions
- Outdated MCP SDK
- Breaking changes in protocol
- Version negotiation failure

**Solution:**

```bash
# 1. Check MCP SDK version
npm list @modelcontextprotocol/sdk
npm outdated @modelcontextprotocol/sdk

# 2. Update to latest MCP SDK
npm install @modelcontextprotocol/sdk@latest

# 3. Check protocol version compatibility
npx claude-flow mcp version

# 4. Force specific protocol version
# Edit config:
mcp:
  server:
    protocolVersion: "2024-11-05"

# 5. Test version negotiation
curl http://localhost:3000/mcp/initialize \
  -d '{"protocolVersion":"2024-11-05","capabilities":{}}'

# 6. Enable version logging
export MCP_LOG_VERSION=true
npx claude-flow mcp start
```

**Version Compatibility Check:**

```typescript
import { MCPServer } from '@modelcontextprotocol/sdk/server/index.js';

const SUPPORTED_VERSIONS = [
  '2024-11-05',
  '2024-10-07'  // Fallback version
];

server.setRequestHandler(InitializeRequestSchema, async (request) => {
  const clientVersion = request.params.protocolVersion;

  if (!SUPPORTED_VERSIONS.includes(clientVersion)) {
    throw new Error(
      `Unsupported protocol version: ${clientVersion}. ` +
      `Supported versions: ${SUPPORTED_VERSIONS.join(', ')}`
    );
  }

  return {
    protocolVersion: clientVersion,
    serverInfo: {
      name: 'claude-flow',
      version: '2.0.0'
    },
    capabilities: {
      tools: {},
      resources: {},
      prompts: {}
    }
  };
});
```

**Prevention:**
- Pin MCP SDK version in production
- Document supported protocol versions
- Implement version negotiation
- Maintain backward compatibility
- Test with multiple MCP versions

---

## 5. Swarm Coordination Issues

### Problem: Swarm Initialization Failures

**Symptoms:**
- "Failed to initialize swarm" errors
- Swarm stuck in "initializing" state
- No agents spawned after initialization
- Topology configuration rejected

**Root Cause:**
- Invalid topology configuration
- Resource constraints
- Network issues in distributed setup
- Consensus algorithm failure

**Solution:**

```bash
# 1. Validate swarm configuration
npx claude-flow config validate --section swarm

# 2. Check swarm status
npx claude-flow swarm status

# 3. Reset and re-initialize
npx claude-flow swarm stop
npx claude-flow swarm reset
npx claude-flow swarm init --topology mesh --max-agents 5

# 4. Use simpler topology for testing
npx claude-flow swarm init --topology simple

# 5. Check resource availability
npx claude-flow diagnostics --check-resources

# 6. Enable swarm debugging
export CLAUDE_FLOW_DEBUG_SWARM=true
npx claude-flow swarm init --debug
```

**Swarm Initialization Example:**

```typescript
import { SwarmCoordinator } from './swarm/coordinator.js';

async function initializeSwarm() {
  const coordinator = new SwarmCoordinator({
    topology: 'adaptive',
    maxAgents: 10,
    consensusThreshold: 0.7,
    healthCheckInterval: 30000
  });

  try {
    // Initialize with timeout
    await Promise.race([
      coordinator.initialize(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Initialization timeout')), 60000)
      )
    ]);

    console.log('Swarm initialized successfully');
    console.log('Topology:', coordinator.getTopology());
    console.log('Active agents:', coordinator.getAgentCount());

  } catch (error) {
    console.error('Swarm initialization failed:', error);

    // Cleanup on failure
    await coordinator.cleanup();
    throw error;
  }
}
```

**Topology Troubleshooting:**

```bash
# Test each topology
npx claude-flow swarm init --topology simple --dry-run
npx claude-flow swarm init --topology mesh --dry-run
npx claude-flow swarm init --topology hierarchical --dry-run
npx claude-flow swarm init --topology adaptive --dry-run

# Check topology constraints
npx claude-flow swarm validate-topology mesh --agents 10
```

**Prevention:**
- Start with simple topology
- Validate configuration before initialization
- Set reasonable agent limits
- Implement initialization retries
- Monitor initialization progress

---

### Problem: Agent Synchronization Problems

**Symptoms:**
- Agents have inconsistent state
- Messages delivered out of order
- Duplicate task execution
- Split-brain scenarios

**Root Cause:**
- Network partition
- Clock skew between nodes
- Race conditions in state updates
- Inconsistent consensus results

**Solution:**

```bash
# 1. Check agent synchronization status
npx claude-flow swarm sync-status

# 2. Force re-synchronization
npx claude-flow swarm resync --force

# 3. Check for network issues
npx claude-flow diagnostics --check-network

# 4. Verify consensus mechanism
npx claude-flow swarm consensus-check

# 5. Enable synchronization logging
export CLAUDE_FLOW_DEBUG_SYNC=true
npx claude-flow swarm start

# 6. Check for clock skew
npx claude-flow diagnostics --check-time-sync
```

**Synchronization Implementation:**

```typescript
import { ConsensusManager } from './consensus/manager.js';

class SwarmSynchronizer {
  private consensusManager: ConsensusManager;
  private syncInterval: NodeJS.Timeout;

  constructor() {
    this.consensusManager = new ConsensusManager({
      algorithm: 'raft',
      quorumSize: 3,
      heartbeatInterval: 1000
    });
  }

  async synchronize(): Promise<void> {
    // 1. Collect state from all agents
    const states = await this.collectAgentStates();

    // 2. Reach consensus on current state
    const consensusState = await this.consensusManager.propose({
      type: 'state_sync',
      states
    });

    // 3. Update all agents to consensus state
    await this.propagateState(consensusState);

    // 4. Verify synchronization
    await this.verifySynchronization();
  }

  private async collectAgentStates(): Promise<Map<string, any>> {
    const states = new Map();
    const agents = await this.getActiveAgents();

    await Promise.all(
      agents.map(async (agent) => {
        try {
          const state = await agent.getState();
          states.set(agent.id, state);
        } catch (error) {
          console.error(`Failed to get state from ${agent.id}:`, error);
        }
      })
    );

    return states;
  }
}
```

**Vector Clocks for Ordering:**

```typescript
class VectorClock {
  private clock: Map<string, number> = new Map();

  increment(agentId: string): void {
    const current = this.clock.get(agentId) || 0;
    this.clock.set(agentId, current + 1);
  }

  update(other: VectorClock): void {
    for (const [agentId, timestamp] of other.clock) {
      const current = this.clock.get(agentId) || 0;
      this.clock.set(agentId, Math.max(current, timestamp));
    }
  }

  happensBefore(other: VectorClock): boolean {
    let anyLess = false;

    for (const [agentId, timestamp] of this.clock) {
      const otherTimestamp = other.clock.get(agentId) || 0;
      if (timestamp > otherTimestamp) return false;
      if (timestamp < otherTimestamp) anyLess = true;
    }

    return anyLess;
  }
}
```

**Prevention:**
- Use distributed consensus algorithms
- Implement vector clocks for causality
- Add conflict resolution strategies
- Use NTP for time synchronization
- Implement idempotent operations

---

### Problem: Deadlocks

**Symptoms:**
- Swarm completely frozen
- All agents waiting indefinitely
- No progress on any tasks
- Resource acquisition hangs

**Root Cause:**
- Circular resource dependencies
- Lock ordering violations
- Missing timeout on locks
- Resource not released on error

**Solution:**

```bash
# 1. Detect deadlock
npx claude-flow swarm detect-deadlock

# 2. Show resource graph
npx claude-flow swarm resource-graph --visualize

# 3. Force release all locks
npx claude-flow swarm unlock-all --force

# 4. Restart swarm
npx claude-flow swarm restart --clean

# 5. Enable deadlock detection
# Edit config:
swarm:
  deadlockDetection:
    enabled: true
    interval: 10000  # Check every 10s
    action: "break"  # or "alert"
```

**Deadlock Prevention Patterns:**

```typescript
// ❌ BAD: Can cause deadlock
async function transferTask(from: Agent, to: Agent) {
  await from.lock();
  await to.lock();  // Deadlock if another thread locks in opposite order!

  const task = await from.getTask();
  await to.addTask(task);

  from.unlock();
  to.unlock();
}

// ✅ GOOD: Lock ordering prevents deadlock
async function transferTask(from: Agent, to: Agent) {
  // Always lock in consistent order (by ID)
  const [first, second] = [from, to].sort((a, b) =>
    a.id.localeCompare(b.id)
  );

  await first.lock();
  try {
    await second.lock();
    try {
      const task = await from.getTask();
      await to.addTask(task);
    } finally {
      second.unlock();
    }
  } finally {
    first.unlock();
  }
}

// ✅ BETTER: Use timeout
async function transferTaskWithTimeout(from: Agent, to: Agent) {
  const locks = await Promise.race([
    Promise.all([from.lock(), to.lock()]),
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Lock timeout')), 5000)
    )
  ]);

  try {
    const task = await from.getTask();
    await to.addTask(task);
  } finally {
    from.unlock();
    to.unlock();
  }
}
```

**Deadlock Detection:**

```typescript
class DeadlockDetector {
  private resourceGraph: Map<string, Set<string>> = new Map();

  addWait(agentId: string, resourceId: string): void {
    if (!this.resourceGraph.has(agentId)) {
      this.resourceGraph.set(agentId, new Set());
    }
    this.resourceGraph.get(agentId)!.add(resourceId);

    // Check for cycles
    if (this.detectCycle(agentId)) {
      console.error(`Deadlock detected involving agent ${agentId}`);
      this.breakDeadlock(agentId);
    }
  }

  private detectCycle(startAgent: string): boolean {
    const visited = new Set<string>();
    const stack = new Set<string>();

    const dfs = (agent: string): boolean => {
      visited.add(agent);
      stack.add(agent);

      const resources = this.resourceGraph.get(agent) || new Set();
      for (const resource of resources) {
        // Find who holds this resource
        const holder = this.getResourceHolder(resource);
        if (!holder) continue;

        if (stack.has(holder)) {
          return true;  // Cycle detected!
        }

        if (!visited.has(holder) && dfs(holder)) {
          return true;
        }
      }

      stack.delete(agent);
      return false;
    };

    return dfs(startAgent);
  }
}
```

**Prevention:**
- Always acquire locks in same order
- Use timeouts on all lock operations
- Implement deadlock detection
- Prefer lock-free algorithms
- Use resource hierarchies

---

### Problem: Resource Contention

**Symptoms:**
- High CPU usage with low throughput
- Agents spending time waiting
- Lock contention in logs
- Reduced parallelism

**Root Cause:**
- Too many agents competing for resources
- Inefficient locking strategy
- Hot spots in shared data
- Unbounded work queue

**Solution:**

```bash
# 1. Analyze resource contention
npx claude-flow diagnostics --analyze-contention

# 2. Check lock statistics
npx claude-flow swarm lock-stats

# 3. Reduce concurrent agents
# Edit config:
agents:
  maxConcurrent: 5  # Reduce from higher number

# 4. Enable resource pooling
swarm:
  resourcePooling:
    enabled: true
    poolSize: 10

# 5. Use finer-grained locks
# Refactor to reduce lock scope

# 6. Monitor contention metrics
npx claude-flow monitor --metric lock-contention
```

**Lock Optimization:**

```typescript
// ❌ BAD: Coarse-grained lock
class AgentRegistry {
  private agents: Map<string, Agent> = new Map();
  private lock = new Lock();

  async getAgent(id: string): Promise<Agent> {
    await this.lock.acquire();  // Locks entire registry!
    try {
      return this.agents.get(id);
    } finally {
      this.lock.release();
    }
  }
}

// ✅ GOOD: Fine-grained locks
class AgentRegistry {
  private agents: Map<string, Agent> = new Map();
  private locks: Map<string, Lock> = new Map();

  async getAgent(id: string): Promise<Agent> {
    // Lock only specific agent
    const lock = this.getLock(id);
    await lock.acquire();
    try {
      return this.agents.get(id);
    } finally {
      lock.release();
    }
  }

  private getLock(id: string): Lock {
    if (!this.locks.has(id)) {
      this.locks.set(id, new Lock());
    }
    return this.locks.get(id)!;
  }
}

// ✅ BETTER: Read-write locks
class AgentRegistry {
  private agents: Map<string, Agent> = new Map();
  private rwLock = new ReadWriteLock();

  async getAgent(id: string): Promise<Agent> {
    // Multiple readers allowed
    await this.rwLock.readLock();
    try {
      return this.agents.get(id);
    } finally {
      this.rwLock.readUnlock();
    }
  }

  async addAgent(agent: Agent): Promise<void> {
    // Exclusive write lock
    await this.rwLock.writeLock();
    try {
      this.agents.set(agent.id, agent);
    } finally {
      this.rwLock.writeUnlock();
    }
  }
}
```

**Prevention:**
- Use read-write locks
- Minimize critical sections
- Prefer immutable data structures
- Use lock-free algorithms where possible
- Monitor contention metrics

---

## 6. Performance Issues

### Problem: Slow Response Times

**Symptoms:**
- API requests take >1 second
- Task execution slower than expected
- User interface lags
- Timeout errors increasing

**Root Cause:**
- Inefficient algorithms
- Unnecessary synchronous operations
- Database query performance
- Network latency
- Insufficient caching

**Solution:**

```bash
# 1. Generate performance report
npx claude-flow diagnostics --performance

# 2. Profile application
npx clinic doctor -- npx claude-flow swarm start
npx clinic flame -- npx claude-flow swarm start

# 3. Identify bottlenecks
npx claude-flow analyze bottleneck

# 4. Enable performance logging
export CLAUDE_FLOW_LOG_PERFORMANCE=true
npx claude-flow swarm start

# 5. Check database query performance
sqlite3 .swarm/memory.db
sqlite> EXPLAIN QUERY PLAN <your slow query>;

# 6. Monitor with continuous profiling
npx claude-flow monitor --continuous --metric response-time
```

**Performance Profiling:**

```typescript
import { performance } from 'perf_hooks';

class PerformanceMonitor {
  private metrics: Map<string, number[]> = new Map();

  async measure<T>(
    name: string,
    fn: () => Promise<T>
  ): Promise<T> {
    const start = performance.now();

    try {
      return await fn();
    } finally {
      const duration = performance.now() - start;
      this.recordMetric(name, duration);

      if (duration > 1000) {  // Slow operation
        console.warn(`Slow operation: ${name} took ${duration.toFixed(2)}ms`);
      }
    }
  }

  private recordMetric(name: string, duration: number): void {
    if (!this.metrics.has(name)) {
      this.metrics.set(name, []);
    }

    const metrics = this.metrics.get(name)!;
    metrics.push(duration);

    // Keep only last 100 measurements
    if (metrics.length > 100) {
      metrics.shift();
    }
  }

  getStats(name: string) {
    const metrics = this.metrics.get(name) || [];
    if (metrics.length === 0) return null;

    const sorted = [...metrics].sort((a, b) => a - b);
    return {
      count: metrics.length,
      avg: metrics.reduce((a, b) => a + b) / metrics.length,
      min: sorted[0],
      max: sorted[sorted.length - 1],
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      p99: sorted[Math.floor(sorted.length * 0.99)]
    };
  }
}

// Usage
const monitor = new PerformanceMonitor();

const result = await monitor.measure('agent.spawn', async () => {
  return await orchestrator.spawnAgent(profile);
});

console.log('Spawn stats:', monitor.getStats('agent.spawn'));
```

**Optimization Techniques:**

```typescript
// 1. Use Promise.all for parallel operations
// ❌ Serial (slow)
for (const agent of agents) {
  await agent.initialize();  // 1s each = 10s total
}

// ✅ Parallel (fast)
await Promise.all(
  agents.map(agent => agent.initialize())  // 1s total
);

// 2. Implement caching
const cache = new Map();
async function getData(key: string) {
  if (cache.has(key)) {
    return cache.get(key);  // Fast!
  }

  const data = await expensiveOperation(key);
  cache.set(key, data);
  return data;
}

// 3. Batch operations
// ❌ N queries
for (const id of ids) {
  await db.query('SELECT * FROM table WHERE id = ?', [id]);
}

// ✅ 1 query
const results = await db.query(
  'SELECT * FROM table WHERE id IN (?)',
  [ids]
);
```

**Prevention:**
- Profile before optimizing
- Set performance budgets
- Use caching strategically
- Optimize database queries
- Monitor performance continuously

---

### Problem: High CPU Usage

**Symptoms:**
- CPU usage sustained >80%
- System becoming unresponsive
- Fan running constantly
- Processes getting throttled

**Root Cause:**
- Infinite loops
- Inefficient algorithms
- Too many concurrent operations
- CPU-bound tasks not yielding
- Excessive logging

**Solution:**

```bash
# 1. Identify CPU-intensive processes
top -o cpu
htop

# 2. Profile CPU usage
npx clinic flame -- npx claude-flow swarm start

# 3. Check for busy loops
npx claude-flow diagnostics --check-loops

# 4. Reduce concurrent agents
npx claude-flow config set agents.maxConcurrent 5

# 5. Add throttling
# Edit config:
performance:
  throttling:
    enabled: true
    maxCPU: 80  # Max CPU percentage

# 6. Disable debug logging
export CLAUDE_FLOW_LOG_LEVEL=warn
```

**CPU Usage Monitoring:**

```typescript
import os from 'os';

class CPUMonitor {
  private startUsage = process.cpuUsage();
  private startTime = Date.now();

  getCPUUsage(): number {
    const cpuUsage = process.cpuUsage(this.startUsage);
    const elapsed = Date.now() - this.startTime;

    // Calculate CPU percentage
    const totalCPU = (cpuUsage.user + cpuUsage.system) / 1000;  // ms
    const cpuPercent = (totalCPU / elapsed) * 100;

    return cpuPercent;
  }

  async throttleIfNeeded(maxCPU: number = 80): Promise<void> {
    const usage = this.getCPUUsage();

    if (usage > maxCPU) {
      // Delay to reduce CPU usage
      const delay = Math.min(1000, (usage - maxCPU) * 10);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

// Usage in CPU-intensive loops
const monitor = new CPUMonitor();

for (const item of largeArray) {
  // Do work
  await processItem(item);

  // Throttle if CPU is high
  await monitor.throttleIfNeeded(80);
}
```

**CPU Optimization:**

```typescript
// ❌ BAD: Busy waiting
while (!isReady) {
  // Consumes CPU!
}

// ✅ GOOD: Event-driven
await new Promise(resolve => {
  eventBus.once('ready', resolve);
});

// ❌ BAD: Synchronous CPU-intensive work
const result = complexCalculation(data);  // Blocks event loop!

// ✅ GOOD: Use worker threads
import { Worker } from 'worker_threads';

function runWorker(data: any): Promise<any> {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./worker.js', {
      workerData: data
    });

    worker.on('message', resolve);
    worker.on('error', reject);
  });
}

const result = await runWorker(data);
```

**Prevention:**
- Use asynchronous operations
- Offload CPU work to workers
- Implement rate limiting
- Monitor CPU usage
- Set CPU quotas in containers

---

### Problem: Memory Exhaustion

**Symptoms:**
- "JavaScript heap out of memory" errors
- Process crashes randomly
- Performance degrades over time
- OOM killer terminates process

**Root Cause:**
- Memory leaks
- Large object retention
- Insufficient heap size
- Memory fragmentation
- Too many concurrent operations

**Solution:**

```bash
# 1. Increase heap size
export NODE_OPTIONS="--max-old-space-size=4096"  # 4GB
npx claude-flow swarm start

# 2. Generate heap snapshot
node --expose-gc --inspect your-app.js
# Chrome DevTools → Memory → Take snapshot

# 3. Analyze memory usage
npx claude-flow diagnostics --analyze-memory

# 4. Force garbage collection
node --expose-gc index.js
# Then in code: global.gc();

# 5. Check for memory leaks
npx clinic doctor -- npx claude-flow swarm start

# 6. Monitor memory over time
watch -n 1 'ps aux | grep claude-flow | grep -v grep'
```

**Memory Management:**

```typescript
// 1. Stream large data instead of loading all
import { createReadStream } from 'fs';
import { pipeline } from 'stream/promises';

// ❌ BAD: Load entire file
const data = await fs.readFile('huge-file.json');
const parsed = JSON.parse(data.toString());

// ✅ GOOD: Stream processing
const stream = createReadStream('huge-file.json');
await pipeline(
  stream,
  new JSONStream.parse('*'),
  async function* (items) {
    for await (const item of items) {
      yield processItem(item);
    }
  }
);

// 2. Clear large objects when done
let largeData = await loadData();
processData(largeData);
largeData = null;  // Allow GC

// 3. Use weak references for caches
const cache = new WeakMap();
cache.set(object, data);  // GC can collect object if no other refs
```

**Memory Monitoring:**

```typescript
class MemoryWatcher {
  private baseline: number;

  constructor() {
    this.baseline = process.memoryUsage().heapUsed;
  }

  check(): void {
    const usage = process.memoryUsage();
    const heapUsed = usage.heapUsed;
    const heapTotal = usage.heapTotal;
    const external = usage.external;

    console.log({
      heapUsed: `${(heapUsed / 1024 / 1024).toFixed(2)} MB`,
      heapTotal: `${(heapTotal / 1024 / 1024).toFixed(2)} MB`,
      external: `${(external / 1024 / 1024).toFixed(2)} MB`,
      heapPercent: `${((heapUsed / heapTotal) * 100).toFixed(2)}%`,
      growth: `${((heapUsed - this.baseline) / 1024 / 1024).toFixed(2)} MB`
    });

    if (heapUsed / heapTotal > 0.9) {
      console.warn('⚠️  Memory usage above 90%!');
      if (global.gc) global.gc();
    }
  }
}

// Monitor every 10 seconds
const watcher = new MemoryWatcher();
setInterval(() => watcher.check(), 10000);
```

**Prevention:**
- Set appropriate heap size limits
- Implement memory monitoring
- Use streaming for large data
- Clear references when done
- Profile memory usage regularly

---

### Problem: I/O Bottlenecks

**Symptoms:**
- High disk I/O wait time
- Slow file operations
- Database queries slow
- Network requests timing out

**Root Cause:**
- Synchronous file operations
- Sequential I/O operations
- No read/write buffering
- Disk full or slow
- Network congestion

**Solution:**

```bash
# 1. Check disk I/O
iostat -x 1
iotop

# 2. Check disk space
df -h
du -sh .swarm/*

# 3. Enable I/O monitoring
npx claude-flow monitor --metric io

# 4. Use faster storage
# Move .swarm to SSD if on HDD

# 5. Enable write buffering
# Edit config:
storage:
  buffering:
    enabled: true
    bufferSize: 65536

# 6. Check network latency
ping api.anthropic.com
curl -w "@curl-format.txt" -o /dev/null https://api.anthropic.com
```

**I/O Optimization:**

```typescript
import { promises as fs } from 'fs';

// ❌ BAD: Synchronous I/O (blocks event loop)
import { readFileSync } from 'fs';
const data = readFileSync('file.txt', 'utf8');

// ✅ GOOD: Asynchronous I/O
const data = await fs.readFile('file.txt', 'utf8');

// ❌ BAD: Sequential reads
for (const file of files) {
  const data = await fs.readFile(file);
  process(data);
}

// ✅ GOOD: Parallel reads
const dataPromises = files.map(file => fs.readFile(file));
const allData = await Promise.all(dataPromises);
allData.forEach(data => process(data));

// ✅ BETTER: Batch with concurrency limit
import pLimit from 'p-limit';

const limit = pLimit(5);  // Max 5 concurrent reads
const results = await Promise.all(
  files.map(file =>
    limit(() => fs.readFile(file))
  )
);
```

**Buffered Writes:**

```typescript
class BufferedWriter {
  private buffer: string[] = [];
  private bufferSize = 1000;
  private flushInterval = 5000;  // 5 seconds
  private timer: NodeJS.Timeout;

  constructor(private filePath: string) {
    this.timer = setInterval(() => this.flush(), this.flushInterval);
  }

  async write(data: string): Promise<void> {
    this.buffer.push(data);

    if (this.buffer.length >= this.bufferSize) {
      await this.flush();
    }
  }

  async flush(): Promise<void> {
    if (this.buffer.length === 0) return;

    const data = this.buffer.join('\n') + '\n';
    this.buffer = [];

    await fs.appendFile(this.filePath, data);
  }

  async close(): Promise<void> {
    clearInterval(this.timer);
    await this.flush();
  }
}
```

**Prevention:**
- Use asynchronous I/O
- Implement buffering
- Batch operations
- Use appropriate concurrency limits
- Monitor I/O metrics

---

## 7. Integration Issues

### Problem: GitHub API Errors

**Symptoms:**
- Rate limit exceeded errors
- Authentication failures
- Repository not found errors
- API request timeouts

**Root Cause:**
- Invalid or expired GitHub token
- Exceeded rate limits (5000/hour)
- Insufficient permissions
- Network issues
- API endpoint changes

**Solution:**

```bash
# 1. Verify GitHub token
echo $GITHUB_TOKEN
gh auth status

# 2. Check rate limit
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# 3. Refresh token
gh auth refresh -h github.com -s repo,workflow

# 4. Use authenticated requests
npx claude-flow github config --token "$GITHUB_TOKEN"

# 5. Implement rate limiting
# Edit config:
integrations:
  github:
    rateLimit:
      enabled: true
      requestsPerHour: 4000  # Below 5000 limit

# 6. Enable retry logic
github:
  retry:
    enabled: true
    maxRetries: 3
    backoff: exponential
```

**GitHub API Client with Rate Limiting:**

```typescript
import { Octokit } from '@octokit/rest';
import Bottleneck from 'bottleneck';

class GitHubClient {
  private octokit: Octokit;
  private limiter: Bottleneck;

  constructor(token: string) {
    this.octokit = new Octokit({ auth: token });

    // Rate limiter: max 4000 requests per hour
    this.limiter = new Bottleneck({
      maxConcurrent: 10,
      minTime: 1000,  // 1s between requests
      reservoir: 4000,  // 4000 requests
      reservoirRefreshAmount: 4000,
      reservoirRefreshInterval: 60 * 60 * 1000  // 1 hour
    });
  }

  async makeRequest<T>(fn: () => Promise<T>): Promise<T> {
    return this.limiter.schedule(async () => {
      try {
        return await fn();
      } catch (error) {
        if (error.status === 403 && error.message.includes('rate limit')) {
          // Wait for rate limit reset
          const resetTime = error.response.headers['x-ratelimit-reset'];
          const waitTime = (resetTime * 1000) - Date.now();

          console.log(`Rate limited. Waiting ${waitTime}ms`);
          await new Promise(resolve => setTimeout(resolve, waitTime));

          // Retry
          return await fn();
        }
        throw error;
      }
    });
  }

  async getRepo(owner: string, repo: string) {
    return this.makeRequest(() =>
      this.octokit.repos.get({ owner, repo })
    );
  }
}
```

**Prevention:**
- Use personal access tokens
- Implement rate limiting
- Cache API responses
- Handle errors gracefully
- Monitor rate limit status

---

### Problem: Docker Container Failures

**Symptoms:**
- Container exits immediately
- Cannot connect to container
- Volume mount failures
- Port binding errors

**Root Cause:**
- Missing environment variables
- Incorrect volume paths
- Port conflicts
- Insufficient resources
- Image build failures

**Solution:**

```bash
# 1. Check container logs
docker logs claude-flow
docker logs -f claude-flow  # Follow logs

# 2. Inspect container
docker inspect claude-flow
docker ps -a  # Show all containers

# 3. Check resource usage
docker stats claude-flow

# 4. Verify volume mounts
docker inspect -f '{{ .Mounts }}' claude-flow

# 5. Test container interactively
docker run -it --rm claude-flow sh

# 6. Rebuild image
docker build --no-cache -t claude-flow .

# 7. Check port conflicts
docker port claude-flow
lsof -i :3000
```

**Docker Compose Configuration:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  claude-flow:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: claude-flow

    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - NODE_ENV=production
      - LOG_LEVEL=info

    volumes:
      - ./.swarm:/app/.swarm:rw
      - ./config:/app/config:ro

    ports:
      - "3000:3000"

    restart: unless-stopped

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    resources:
      limits:
        cpus: '2'
        memory: 4G
      reservations:
        cpus: '1'
        memory: 2G

# Run with:
# docker-compose up -d
# docker-compose logs -f
```

**Prevention:**
- Use health checks
- Set resource limits
- Validate environment variables
- Use named volumes
- Test locally before deployment

---

### Problem: External Dependency Failures

**Symptoms:**
- Third-party API timeouts
- Service unavailable errors
- Network connection failures
- Dependency version conflicts

**Root Cause:**
- Service outage
- Network issues
- Rate limiting
- Breaking API changes
- Incompatible versions

**Solution:**

```bash
# 1. Check service status
curl -I https://api.anthropic.com/health
curl -I https://api.github.com

# 2. Test network connectivity
ping api.anthropic.com
traceroute api.anthropic.com

# 3. Check DNS resolution
nslookup api.anthropic.com
dig api.anthropic.com

# 4. Verify dependency versions
npm list
npm outdated

# 5. Update dependencies
npm update
npm audit fix

# 6. Use fallback services
# Edit config:
integrations:
  fallback:
    enabled: true
    services:
      - primary: "api.anthropic.com"
        fallback: "fallback-api.anthropic.com"
```

**Circuit Breaker Pattern:**

```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailTime = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';

  constructor(
    private threshold = 5,  // Failures before opening
    private timeout = 60000  // Time to wait before retry (ms)
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      const now = Date.now();
      if (now - this.lastFailTime >= this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await fn();

      if (this.state === 'half-open') {
        this.state = 'closed';
        this.failures = 0;
      }

      return result;

    } catch (error) {
      this.failures++;
      this.lastFailTime = Date.now();

      if (this.failures >= this.threshold) {
        this.state = 'open';
        console.error(`Circuit breaker opened after ${this.failures} failures`);
      }

      throw error;
    }
  }
}

// Usage
const breaker = new CircuitBreaker(5, 60000);

async function callExternalAPI(data: any) {
  return breaker.execute(async () => {
    const response = await fetch('https://api.example.com', {
      method: 'POST',
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  });
}
```

**Prevention:**
- Implement circuit breakers
- Use retry with exponential backoff
- Set reasonable timeouts
- Have fallback mechanisms
- Monitor dependency health

---

### Problem: Network Timeouts

**Symptoms:**
- "ETIMEDOUT" errors
- "ECONNRESET" errors
- Requests never complete
- Intermittent connectivity

**Root Cause:**
- Slow network connection
- Firewall/proxy blocking
- DNS resolution slow
- Server not responding
- Request timeout too short

**Solution:**

```bash
# 1. Test network speed
curl -w "@curl-format.txt" -o /dev/null https://api.anthropic.com

# 2. Check firewall rules
sudo iptables -L
sudo ufw status

# 3. Test with different timeout
curl --max-time 60 https://api.anthropic.com

# 4. Check proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY

# 5. Increase timeout in config
# Edit .claude-flow/config.yml:
network:
  timeout: 60000  # 60 seconds
  retries: 3
  retryDelay: 1000

# 6. Use keep-alive connections
network:
  keepAlive:
    enabled: true
    timeout: 60000
```

**Timeout Configuration:**

```typescript
import fetch from 'node-fetch';
import AbortController from 'abort-controller';

async function fetchWithTimeout(
  url: string,
  options: any = {},
  timeout = 30000
): Promise<any> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
      // Keep-alive for connection reuse
      headers: {
        ...options.headers,
        'Connection': 'keep-alive'
      }
    });

    return response;

  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;

  } finally {
    clearTimeout(timeoutId);
  }
}

// Usage with retry
async function fetchWithRetry(
  url: string,
  maxRetries = 3
): Promise<any> {
  let lastError;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetchWithTimeout(url, {}, 30000);
    } catch (error) {
      lastError = error;

      if (i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000;  // Exponential backoff
        console.log(`Retry ${i + 1}/${maxRetries} after ${delay}ms`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError;
}
```

**Prevention:**
- Set appropriate timeouts
- Implement retry logic
- Use connection pooling
- Monitor network latency
- Configure proxies correctly

---

## 8. Hook Issues

### Problem: Hooks Not Executing

**Symptoms:**
- Pre/post task hooks don't run
- No hook output in logs
- Expected side effects not happening
- Hook scripts exist but ignored

**Root Cause:**
- Hooks not executable
- Hook path not configured
- Syntax errors in hook scripts
- Hooks disabled in configuration
- Wrong hook file naming

**Solution:**

```bash
# 1. Check hook configuration
npx claude-flow config show hooks

# 2. Verify hook files exist
ls -la hooks/
ls -la .claude-flow/hooks/

# 3. Make hooks executable
chmod +x hooks/*
chmod +x .claude-flow/hooks/*

# 4. Test hook manually
bash hooks/pre-task.sh

# 5. Enable hooks in config
# Edit .claude-flow/config.yml:
hooks:
  enabled: true
  directory: "./hooks"

# 6. Enable hook debugging
export CLAUDE_FLOW_DEBUG_HOOKS=true
npx claude-flow swarm start

# 7. Check hook logs
cat .swarm/logs/hooks.log
```

**Hook File Structure:**

```bash
# Proper hook directory structure
.claude-flow/hooks/
├── pre-task.sh         # Runs before each task
├── post-task.sh        # Runs after each task
├── pre-edit.sh         # Runs before file edits
├── post-edit.sh        # Runs after file edits
├── session-start.sh    # Runs at session start
└── session-end.sh      # Runs at session end

# Make all executable
chmod +x .claude-flow/hooks/*
```

**Hook Template:**

```bash
#!/bin/bash
# hooks/pre-task.sh

set -e  # Exit on error

# Get arguments
TASK_ID=$1
TASK_DESCRIPTION=$2
AGENT_ID=$3

echo "=== Pre-Task Hook ==="
echo "Task ID: $TASK_ID"
echo "Description: $TASK_DESCRIPTION"
echo "Agent: $AGENT_ID"

# Store in memory
npx claude-flow memory store \
  --key "swarm/tasks/$TASK_ID/start" \
  --value "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --namespace "coordination"

# Run validation
if ! npx claude-flow validate --task "$TASK_ID"; then
  echo "❌ Task validation failed"
  exit 1
fi

echo "✅ Pre-task hook completed"
exit 0
```

**Prevention:**
- Always make hooks executable
- Test hooks in isolation
- Use proper shebang lines
- Handle errors gracefully
- Log hook execution

---

### Problem: Hook Errors

**Symptoms:**
- Hook execution fails
- Error messages in logs
- Tasks blocked by failing hooks
- Partial hook execution

**Root Cause:**
- Syntax errors in hook script
- Missing dependencies
- Insufficient permissions
- Unhandled exceptions
- Invalid hook logic

**Solution:**

```bash
# 1. Check hook syntax
bash -n hooks/pre-task.sh  # Syntax check without execution
shellcheck hooks/pre-task.sh  # Lint script

# 2. Run hook with debugging
bash -x hooks/pre-task.sh "$TASK_ID" "$DESCRIPTION"

# 3. Check hook dependencies
which jq  # Check if jq is installed
which curl

# 4. View detailed error
tail -100 .swarm/logs/hooks.log | grep ERROR

# 5. Configure error handling
# Edit config:
hooks:
  errorHandling:
    continueOnError: false  # or true to ignore errors
    logErrors: true
    maxRetries: 3

# 6. Validate hook script
npx claude-flow hooks validate pre-task
```

**Error Handling in Hooks:**

```bash
#!/bin/bash
# hooks/post-task.sh with error handling

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Logging function
log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a .swarm/logs/hooks.log
}

error() {
  log "ERROR: $*" >&2
}

# Trap errors
trap 'error "Hook failed at line $LINENO"' ERR

# Main logic with validation
TASK_ID=${1:?"Task ID required"}
TASK_STATUS=${2:?"Task status required"}

log "Post-task hook starting for $TASK_ID"

# Validate inputs
if [[ ! "$TASK_STATUS" =~ ^(completed|failed|cancelled)$ ]]; then
  error "Invalid task status: $TASK_STATUS"
  exit 1
fi

# Safe command execution with error handling
if ! result=$(npx claude-flow memory store \
  --key "swarm/tasks/$TASK_ID/end" \
  --value "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --namespace "coordination" 2>&1); then
  error "Failed to store completion time: $result"
  exit 1
fi

log "Post-task hook completed successfully"
exit 0
```

**Hook Testing Framework:**

```bash
#!/bin/bash
# test-hooks.sh

HOOKS_DIR=".claude-flow/hooks"
FAILED=0

echo "Testing all hooks..."

for hook in "$HOOKS_DIR"/*.sh; do
  hook_name=$(basename "$hook")
  echo -n "Testing $hook_name... "

  # Check syntax
  if ! bash -n "$hook" 2>/dev/null; then
    echo "❌ Syntax error"
    FAILED=$((FAILED + 1))
    continue
  fi

  # Check executable
  if [[ ! -x "$hook" ]]; then
    echo "❌ Not executable"
    FAILED=$((FAILED + 1))
    continue
  fi

  # Dry run (if hook supports --dry-run)
  if ! "$hook" --dry-run &>/dev/null; then
    echo "⚠️  Dry run failed (may be normal)"
  fi

  echo "✅ Passed"
done

if [ $FAILED -gt 0 ]; then
  echo "❌ $FAILED hook(s) failed"
  exit 1
else
  echo "✅ All hooks passed"
  exit 0
fi
```

**Prevention:**
- Validate hook scripts before deployment
- Add comprehensive error handling
- Use shellcheck for linting
- Test with edge cases
- Log all errors

---

### Problem: Hook Performance Impact

**Symptoms:**
- Tasks take longer than expected
- Hooks slow down operations
- Timeout errors from slow hooks
- System responsiveness degraded

**Root Cause:**
- Hooks doing too much work
- Synchronous heavy operations
- External API calls in hooks
- No caching in hooks
- Hooks running sequentially

**Solution:**

```bash
# 1. Profile hook execution
time bash hooks/pre-task.sh

# 2. Check hook duration in logs
grep "hook duration" .swarm/logs/hooks.log

# 3. Set hook timeout
# Edit config:
hooks:
  timeout: 5000  # 5 seconds max

# 4. Run hooks in background (if appropriate)
# Modify hook to fork for long operations

# 5. Cache expensive operations
# Add caching to hook scripts

# 6. Parallelize independent hooks
hooks:
  parallel: true  # Run pre-* hooks in parallel
```

**Optimized Hook Example:**

```bash
#!/bin/bash
# hooks/pre-task.sh (optimized)

set -euo pipefail

TASK_ID=$1
CACHE_DIR=".swarm/cache/hooks"
CACHE_FILE="$CACHE_DIR/$TASK_ID.cache"

# Use cache if available and fresh
if [ -f "$CACHE_FILE" ]; then
  AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE") ))
  if [ $AGE -lt 300 ]; then  # 5 minutes
    echo "Using cached result"
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Do expensive work in background
(
  result=$(expensive_operation)
  mkdir -p "$CACHE_DIR"
  echo "$result" > "$CACHE_FILE"
) &

# Continue with lightweight validation
quick_validation

exit 0
```

**Hook Performance Monitoring:**

```typescript
import { performance } from 'perf_hooks';

class HookManager {
  private hookTimes: Map<string, number[]> = new Map();

  async executeHook(
    name: string,
    args: string[],
    timeout = 5000
  ): Promise<void> {
    const start = performance.now();

    try {
      await Promise.race([
        this.runHook(name, args),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Hook timeout')), timeout)
        )
      ]);

    } finally {
      const duration = performance.now() - start;
      this.recordHookTime(name, duration);

      if (duration > 1000) {
        console.warn(`Slow hook: ${name} took ${duration.toFixed(2)}ms`);
      }
    }
  }

  private recordHookTime(name: string, duration: number): void {
    if (!this.hookTimes.has(name)) {
      this.hookTimes.set(name, []);
    }

    const times = this.hookTimes.get(name)!;
    times.push(duration);

    // Keep only last 100
    if (times.length > 100) {
      times.shift();
    }
  }

  getHookStats(name: string) {
    const times = this.hookTimes.get(name) || [];
    if (times.length === 0) return null;

    const avg = times.reduce((a, b) => a + b) / times.length;
    const max = Math.max(...times);

    return { avg, max, count: times.length };
  }
}
```

**Prevention:**
- Keep hooks lightweight
- Run heavy work in background
- Implement caching
- Set timeouts
- Monitor hook performance

---

## 9. Common Error Messages

### Error Catalog

#### SQLITE_CANTOPEN

**Message:** `SQLITE_CANTOPEN: unable to open database file`

**Cause:** Database file doesn't exist or no permissions

**Solution:**
```bash
mkdir -p .swarm
chmod 755 .swarm
npx claude-flow memory init
```

---

#### ECONNREFUSED

**Message:** `connect ECONNREFUSED 127.0.0.1:3000`

**Cause:** Server not running or port unavailable

**Solution:**
```bash
# Check if server is running
lsof -i :3000

# Start server
npx claude-flow mcp start

# Or change port
export MCP_PORT=3001
```

---

#### ETIMEDOUT

**Message:** `request timeout after 30000ms`

**Cause:** Network timeout or slow operation

**Solution:**
```bash
# Increase timeout
export CLAUDE_FLOW_TIMEOUT=60000

# Or in config:
# timeout: 60000
```

---

#### Maximum concurrent agents reached

**Message:** `SystemError: Maximum concurrent agents reached`

**Cause:** Hit maxConcurrent limit

**Solution:**
```bash
# Increase limit in config
# agents:
#   maxConcurrent: 20

# Or terminate idle agents
npx claude-flow agent list
npx claude-flow agent terminate <agent-id>
```

---

#### Orchestrator not initialized

**Message:** `SystemError: Orchestrator not initialized`

**Cause:** Trying to use orchestrator before initialization

**Solution:**
```typescript
// Ensure initialization before use
await orchestrator.initialize();

// Then use orchestrator
await orchestrator.spawnAgent(profile);
```

---

#### Task queue is full

**Message:** `SystemError: Task queue is full`

**Cause:** Too many queued tasks

**Solution:**
```bash
# Clear old tasks
npx claude-flow task clear --status completed

# Increase queue size in config:
# tasks:
#   maxQueueSize: 1000
```

---

#### Agent not found

**Message:** `SystemError: Agent not found: agent-xyz`

**Cause:** Agent doesn't exist or was terminated

**Solution:**
```bash
# Check active agents
npx claude-flow agent list

# Spawn new agent if needed
npx claude-flow agent spawn coder
```

---

#### Failed to spawn agent

**Message:** `Failed to spawn agent: [reason]`

**Cause:** Various (check error details)

**Solution:**
```bash
# Check logs for specific reason
tail -50 .swarm/logs/agent-manager.log

# Common fixes:
# 1. Check max concurrent limit
# 2. Verify agent profile is valid
# 3. Ensure resources available
```

---

#### Database is locked

**Message:** `SQLITE_BUSY: database is locked`

**Cause:** Concurrent writes exceeding SQLite limits

**Solution:**
```sql
-- Enable WAL mode
PRAGMA journal_mode=WAL;

-- Increase busy timeout
PRAGMA busy_timeout=5000;
```

---

#### Memory leak detected

**Message:** `Memory leak detected: heap growth 150%`

**Cause:** Memory not being freed

**Solution:**
```bash
# Take heap snapshot
node --expose-gc --inspect app.js

# Force garbage collection
node --expose-gc app.js
# Then: global.gc()

# Check for common leaks:
# - Event listeners not removed
# - Large objects in closures
# - Unbounded caches
```

---

## 10. Debugging Workflows

### Workflow 1: Enable Debug Logging

```bash
# Step 1: Set log level to debug
export CLAUDE_FLOW_LOG_LEVEL=debug

# Step 2: Enable specific debug categories
export DEBUG="claude-flow:*"

# Step 3: Start with verbose output
npx claude-flow swarm start --verbose --debug

# Step 4: Monitor logs in real-time
tail -f .swarm/logs/claude-flow.log

# Step 5: Filter for errors
tail -f .swarm/logs/claude-flow.log | grep ERROR

# Step 6: Analyze specific component
export CLAUDE_FLOW_DEBUG_COMPONENT=orchestrator
```

**Log Levels:**
- `error`: Only errors
- `warn`: Warnings and errors
- `info`: General information (default)
- `debug`: Detailed debugging
- `trace`: Very verbose

---

### Workflow 2: Use Diagnostics

```bash
# Step 1: Run full diagnostic
npx claude-flow diagnostics

# Step 2: Generate detailed report
npx claude-flow diagnostics \
  --detailed \
  --output diagnostics.html \
  --format html

# Step 3: Check specific component
npx claude-flow diagnostics --component memoryManager

# Step 4: Run health check
npx claude-flow health-check

# Step 5: Check for specific issues
npx claude-flow diagnostics --check-memory-leaks
npx claude-flow diagnostics --check-deadlocks
npx claude-flow diagnostics --analyze-performance

# Step 6: Export for analysis
npx claude-flow diagnostics --export diagnostics.json
```

---

### Workflow 3: Profile Performance

```bash
# Step 1: Install profiling tools
npm install -g clinic

# Step 2: Profile with Clinic Doctor
clinic doctor -- npx claude-flow swarm start

# Step 3: Generate flame graph
clinic flame -- npx claude-flow swarm start

# Step 4: Analyze event loop
clinic bubbleprof -- npx claude-flow swarm start

# Step 5: Built-in performance monitoring
npx claude-flow monitor --continuous --metric all

# Step 6: Generate performance report
npx claude-flow performance-report \
  --duration 300 \
  --output perf-report.html
```

---

### Workflow 4: Trace Execution

```bash
# Step 1: Enable tracing
export CLAUDE_FLOW_TRACE=true

# Step 2: Trace specific operations
npx claude-flow --trace agent spawn coder

# Step 3: View execution trace
cat .swarm/traces/trace-*.json | jq .

# Step 4: Use Node.js inspector
node --inspect-brk node_modules/.bin/claude-flow swarm start
# Then open chrome://inspect

# Step 5: Add custom trace points
# In code:
console.trace('Custom trace point');

# Step 6: Analyze with Chrome DevTools
# Performance tab → Record → Stop → Analyze
```

---

### Workflow 5: Debug Memory Issues

```bash
# Step 1: Take baseline snapshot
node --expose-gc --inspect app.js
# Chrome DevTools → Memory → Take snapshot

# Step 2: Run workload

# Step 3: Take another snapshot

# Step 4: Compare snapshots
# Look for objects that increased

# Step 5: Force GC and check if memory drops
global.gc();

# Step 6: Use heapdump
npm install heapdump
node -r heapdump app.js
# Snapshots saved automatically on SIGUSR2:
kill -USR2 <pid>
```

---

### Workflow 6: Analyze Database Issues

```bash
# Step 1: Check database integrity
sqlite3 .swarm/memory.db "PRAGMA integrity_check;"

# Step 2: Analyze query performance
sqlite3 .swarm/memory.db
sqlite> .timer on
sqlite> EXPLAIN QUERY PLAN SELECT * FROM memories WHERE namespace = 'swarm';

# Step 3: Check indexes
sqlite> .indices memories

# Step 4: View table statistics
sqlite> ANALYZE;
sqlite> SELECT * FROM sqlite_stat1;

# Step 5: Enable query logging
export SQLITE_TRACE=1

# Step 6: Optimize database
sqlite> VACUUM;
sqlite> REINDEX;
```

---

### Workflow 7: Debug Network Issues

```bash
# Step 1: Test connectivity
ping api.anthropic.com
curl -I https://api.anthropic.com

# Step 2: Trace route
traceroute api.anthropic.com

# Step 3: Check DNS
nslookup api.anthropic.com
dig api.anthropic.com

# Step 4: Monitor network traffic
sudo tcpdump -i any -n host api.anthropic.com

# Step 5: Test with different timeout
curl --max-time 60 --verbose https://api.anthropic.com

# Step 6: Check proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY
curl --proxy "" https://api.anthropic.com  # Bypass proxy
```

---

### Workflow 8: Debug Agent Issues

```bash
# Step 1: List all agents
npx claude-flow agent list --detailed

# Step 2: Check specific agent
npx claude-flow agent status <agent-id>

# Step 3: View agent logs
tail -f .swarm/logs/agent-<agent-id>.log

# Step 4: Inspect agent state
npx claude-flow agent inspect <agent-id> --show-state

# Step 5: Test agent health
npx claude-flow agent health-check <agent-id>

# Step 6: Force restart if needed
npx claude-flow agent restart <agent-id>

# Step 7: Clean terminate
npx claude-flow agent terminate <agent-id> --graceful
```

---

### Workflow 9: Debug Swarm Coordination

```bash
# Step 1: Check swarm status
npx claude-flow swarm status --detailed

# Step 2: View coordination graph
npx claude-flow swarm topology --visualize

# Step 3: Check consensus state
npx claude-flow swarm consensus-status

# Step 4: Monitor synchronization
npx claude-flow swarm monitor --watch sync

# Step 5: Test communication
npx claude-flow swarm test-communication

# Step 6: Reset if needed
npx claude-flow swarm reset --keep-agents
```

---

### Workflow 10: Debug Hook Issues

```bash
# Step 1: List registered hooks
npx claude-flow hooks list

# Step 2: Test hook manually
bash -x hooks/pre-task.sh "test-id" "test description"

# Step 3: Validate hook
npx claude-flow hooks validate pre-task

# Step 4: Check hook logs
tail -f .swarm/logs/hooks.log

# Step 5: Run hook in dry-run mode
hooks/pre-task.sh --dry-run

# Step 6: Disable problematic hook temporarily
npx claude-flow hooks disable pre-task
```

---

## Quick Reference

### Decision Tree: Swarm Won't Start

```
Swarm won't start
├─ Error: "Port already in use"
│  └─ Solution: Change port or kill process
│     • lsof -i :3000
│     • kill -9 <pid>
│
├─ Error: "Configuration not found"
│  └─ Solution: Initialize config
│     • npx claude-flow init
│
├─ Error: "Database error"
│  └─ Solution: Reinitialize database
│     • npx claude-flow memory init
│
└─ Error: "Resource limits"
   └─ Solution: Increase limits
      • Edit config: maxConcurrent
```

### Decision Tree: Agent Problems

```
Agent issues
├─ Won't spawn
│  ├─ Check: Max concurrent reached?
│  │  └─ Increase maxConcurrent or terminate agents
│  ├─ Check: Invalid configuration?
│  │  └─ Validate agent profile
│  └─ Check: Resource constraints?
│     └─ Run diagnostics
│
├─ Crashes frequently
│  ├─ Check logs for errors
│  ├─ Enable auto-restart
│  └─ Review crash dumps
│
└─ Hangs/timeouts
   ├─ Check for deadlocks
   ├─ Increase timeout
   └─ Force terminate and restart
```

### Performance Checklist

- [ ] Database indexes created
- [ ] WAL mode enabled for SQLite
- [ ] Caching implemented
- [ ] Connection pooling configured
- [ ] Timeouts set appropriately
- [ ] Monitoring enabled
- [ ] Resource limits configured
- [ ] Logs not too verbose
- [ ] Background jobs optimized
- [ ] Memory leaks checked

---

## Support Resources

### Documentation
- Main docs: `/docs/README.md`
- API reference: `/docs/api/README.md`
- Architecture: `/docs/reverse-engineering/01-architecture-overview.md`

### Tools
- Diagnostics: `npx claude-flow diagnostics`
- Health check: `npx claude-flow health-check`
- Monitoring: `npx claude-flow monitor`
- Debug logs: `.swarm/logs/`

### Community
- GitHub Issues: https://github.com/ruvnet/claude-flow/issues
- Discussions: https://github.com/ruvnet/claude-flow/discussions

---

**Last updated:** 2025-11-18
**Version:** 2.0.0

This troubleshooting cookbook is a living document. Please contribute solutions to problems you've encountered!
