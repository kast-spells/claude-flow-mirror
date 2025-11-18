# Test Infrastructure Documentation

**Version:** 2.7.34
**Last Updated:** 2025-11-18
**Status:** Production

## Table of Contents

1. [Overview](#overview)
2. [Test Directory Structure](#test-directory-structure)
3. [Test Frameworks and Tools](#test-frameworks-and-tools)
4. [Test Patterns](#test-patterns)
5. [Test Coverage](#test-coverage)
6. [Running Tests](#running-tests)
7. [Writing Tests](#writing-tests)
8. [Test Utilities](#test-utilities)
9. [Performance Testing](#performance-testing)
10. [Integration Testing](#integration-testing)
11. [Continuous Integration](#continuous-integration)
12. [Best Practices](#best-practices)

---

## Overview

Claude-flow maintains a comprehensive test infrastructure with **73+ test files** covering:

- **Unit Tests**: Component and function-level testing
- **Integration Tests**: Cross-component interaction testing
- **E2E Tests**: End-to-end workflow validation
- **Performance Tests**: Benchmark and load testing
- **Production Tests**: Deployment validation
- **Security Tests**: Security and vulnerability testing

**Test Coverage Targets:**
- Statements: >80%
- Branches: >75%
- Functions: >80%
- Lines: >80%

---

## Test Directory Structure

```
tests/
├── benchmark/                      # Benchmark tests
│   ├── agent-booster-benchmark.js
│   └── test.js
├── cli/                           # CLI command tests
│   ├── environment-handling.test.ts
│   └── init-settings-local.test.js
├── docker/                        # Docker integration tests
│   └── tests/
├── fixtures/                      # Test data generators
│   └── generators.ts
├── integration/                   # Integration tests
│   ├── agentdb/
│   │   └── compatibility.test.js
│   ├── agent-booster.test.js
│   ├── batch-task-mock-test.ts
│   ├── batch-task-test.ts
│   ├── cli-simple.test.js
│   ├── cross-platform-portability.test.js
│   ├── error-handling-patterns.test.js
│   ├── functional-portability.test.js
│   ├── hive-mind-schema.test.js
│   ├── hook-basic.test.js
│   ├── init-workflow.test.js
│   ├── json-output.test.ts
│   ├── mcp-pattern-persistence.test.js
│   ├── mcp.test.ts
│   ├── portability-fixes.test.js
│   ├── real-metrics.test.js
│   ├── reasoningbank-integration.test.js
│   ├── sdk-integration.test.ts
│   ├── start-command.test.ts
│   ├── start-compatibility.test.ts
│   ├── system-integration.test.ts
│   └── ui-display-fixes.test.ts
├── maestro/                       # Maestro orchestration tests
├── manual/                        # Manual test scripts
│   └── test-pattern-persistence.js
├── mcp/                          # MCP compliance tests
│   ├── mcp-2025-compliance.test.ts
│   ├── mcp-2025-core.test.ts
│   └── progressive-disclosure.test.ts
├── mocks/                        # Mock implementations
│   └── index.ts
├── performance/                  # Performance tests
│   ├── agentdb/
│   │   └── benchmarks.test.js
│   ├── benchmark.test.ts
│   └── init-performance.test.js
├── production/                   # Production validation tests
│   ├── deployment-validation.test.ts
│   ├── environment-validation.test.ts
│   ├── integration-validation.test.ts
│   ├── performance-validation.test.ts
│   └── security-validation.test.ts
├── sdk/                         # SDK tests
│   └── verification.test.ts
├── security/                    # Security tests
│   └── init-security.test.js
├── unit/                        # Unit tests
│   ├── api/
│   ├── cli/
│   │   ├── commands/
│   │   │   ├── init/
│   │   │   │   ├── validation.test.js
│   │   │   │   ├── rollback.test.js
│   │   │   │   ├── npx-isolation.test.js
│   │   │   │   ├── init-core.test.js
│   │   │   │   └── batch-init.test.js
│   │   │   └── task-parsing.test.js
│   │   ├── simple-commands/
│   │   │   └── monitor.test.js
│   │   └── start/
│   ├── coordination/
│   ├── core/
│   ├── mcp/
│   ├── memory/
│   ├── terminal/
│   ├── ui/
│   │   └── console/
│   │       └── analysis-tools.test.js
│   ├── utils/
│   │   └── npx-isolated-cache.test.js
│   ├── components.test.ts
│   ├── fix-typos-syntax.test.js
│   └── performance.test.js
├── test.config.js               # Test configuration
├── test.utils.ts                # Test utilities
├── test-coverage-report.js      # Coverage reporting
└── test-mcp-stdio.js           # MCP stdio testing
```

---

## Test Frameworks and Tools

### Core Testing Framework

**Jest v29.7.0** - Primary test runner and assertion library

```javascript
// jest.config.js
export default {
  preset: 'ts-jest/presets/default-esm',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: [
    '<rootDir>/tests/**/*.test.ts',
    '<rootDir>/tests/**/*.test.js',
    '<rootDir>/tests/**/*.spec.ts',
    '<rootDir>/tests/**/*.spec.js'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testTimeout: 30000,
  clearMocks: true,
  restoreMocks: true
};
```

### TypeScript Support

**ts-jest v29.4.0** - TypeScript transformation

```javascript
transform: {
  '^.+\\.ts$': ['ts-jest', {
    useESM: true,
    tsconfig: {
      module: 'es2022',
      moduleResolution: 'node',
      target: 'es2022'
    }
  }]
}
```

### Babel Support

**babel-jest v29.7.0** - JavaScript transformation

```javascript
transform: {
  '^.+\\.js$': ['babel-jest', {
    presets: [['@babel/preset-env', { modules: false }]]
  }]
}
```

### Additional Tools

- **Supertest v7.1.4** - HTTP assertion library
- **Puppeteer v24.11.2** - E2E browser testing
- **@jest/globals** - Jest globals and types

### Module Resolution

```javascript
moduleNameMapper: {
  '^(\\.{1,2}/.*)\\.js$': '$1',
  '^~/(.*)$': '<rootDir>/src/$1',
  '^@/(.*)$': '<rootDir>/src/$1',
  '^@tests/(.*)$': '<rootDir>/tests/$1'
}
```

---

## Test Patterns

### Unit Test Pattern

**Location:** `/tests/unit/`

```typescript
// Example: tests/unit/performance.test.js
import { jest } from '@jest/globals';
import { parseFlags } from '../../cli/utils.js';

describe('Performance Tests', () => {
  describe('Utility Functions Performance', () => {
    test('parseFlags should handle large argument lists efficiently', async () => {
      const largeArgList = [];
      for (let i = 0; i < 1000; i++) {
        largeArgList.push(`--flag${i}`, `value${i}`);
      }

      const { result, duration } = await perfHelpers.measureTime(() => {
        return parseFlags(largeArgList);
      });

      expect(duration).toBeLessThan(100);
      expect(Object.keys(result.flags)).toHaveLength(1000);
    });
  });
});
```

**Characteristics:**
- Fast execution (<100ms per test)
- Isolated from external dependencies
- Heavy use of mocks
- Focus on single functions/components

### Integration Test Pattern

**Location:** `/tests/integration/`

```typescript
// Example: tests/integration/hook-basic.test.js
import { describe, it, expect } from '@jest/globals';

describe('Hook Basic Tests', () => {
  it('should handle hook parameters', () => {
    const options = {
      'validate-safety': true,
      'prepare-resources': false
    };

    const validateSafety = options['validate-safety'] || options.validate || false;
    const prepareResources = options['prepare-resources'] || false;

    expect(validateSafety).toBe(true);
    expect(prepareResources).toBe(false);
  });

  it('should map file extensions to agents', () => {
    const getAgentTypeFromFile = (filePath) => {
      const ext = filePath.split('.').pop().toLowerCase();
      const agentMap = {
        'js': 'javascript-developer',
        'ts': 'typescript-developer',
        'py': 'python-developer'
      };
      return agentMap[ext] || 'general-developer';
    };

    expect(getAgentTypeFromFile('test.js')).toBe('javascript-developer');
    expect(getAgentTypeFromFile('test.py')).toBe('python-developer');
  });
});
```

**Characteristics:**
- Tests component interactions
- May involve database/filesystem
- Moderate execution time
- Real integrations (minimal mocking)

### Performance Test Pattern

**Location:** `/tests/performance/`

```typescript
// Example: tests/performance/benchmark.test.ts
describe('Performance Benchmark Tests', () => {
  it('should spawn agents efficiently', async () => {
    const agentCount = 100;
    const startTime = performance.now();

    const spawnPromises = Array.from({ length: agentCount }, (_, i) =>
      agentManager.spawnAgent('researcher', {
        name: `Agent-${i}`,
        capabilities: ['research', 'analysis']
      })
    );

    const spawnedAgents = await Promise.all(spawnPromises);
    const endTime = performance.now();

    const spawnTime = endTime - startTime;
    const agentsPerSecond = (agentCount / spawnTime) * 1000;

    expect(spawnedAgents).toHaveLength(agentCount);
    expect(spawnTime).toBeLessThan(10000);
    expect(agentsPerSecond).toBeGreaterThan(10);

    console.log(`Spawned ${agentCount} agents in ${spawnTime.toFixed(2)}ms`);
  });
});
```

**Characteristics:**
- Measures execution time
- Validates throughput
- Tests scalability limits
- Performance regression detection

### Production Validation Pattern

**Location:** `/tests/production/`

```typescript
// Example: tests/production/deployment-validation.test.ts
describe('Production Deployment Validation', () => {
  test('should provide comprehensive health check response', async () => {
    const healthResult = await healthCheckManager.performHealthCheck();

    expect(healthResult).toBeDefined();
    expect(healthResult.status).toMatch(/^(healthy|warning|unhealthy)$/);
    expect(healthResult.uptime).toBeGreaterThan(0);

    healthResult.components.forEach(component => {
      expect(component).toHaveProperty('name');
      expect(component).toHaveProperty('status');
      expect(['healthy', 'warning', 'unhealthy']).toContain(component.status);
    });
  });

  test('should handle SIGTERM gracefully', async () => {
    const shutdownSystem = SystemIntegration.getInstance();
    await shutdownSystem.initialize({ environment: 'shutdown-test' });

    const startTime = Date.now();
    await shutdownSystem.shutdown();
    const shutdownTime = Date.now() - startTime;

    expect(shutdownTime).toBeLessThan(10000);
    expect(shutdownSystem.isReady()).toBe(false);
  });
});
```

**Characteristics:**
- Validates production readiness
- Tests health check endpoints
- Validates graceful shutdown
- Resource cleanup verification

---

## Test Coverage

### Current Coverage Configuration

```javascript
// jest.config.js
collectCoverageFrom: [
  'src/**/*.ts',
  'src/**/*.js',
  '!src/**/*.d.ts',
  '!src/**/*.test.ts',
  '!src/**/*.test.js'
],
coverageDirectory: 'coverage',
coverageReporters: ['text', 'lcov', 'html']
```

### Coverage Targets

| Metric | Target | Enforcement |
|--------|--------|-------------|
| Statements | >80% | CI Pipeline |
| Branches | >75% | CI Pipeline |
| Functions | >80% | CI Pipeline |
| Lines | >80% | CI Pipeline |

### Running Coverage Reports

```bash
# Full coverage report
npm run test:coverage

# Unit test coverage only
npm run test:coverage:unit

# Integration test coverage
npm run test:coverage:integration

# E2E test coverage
npm run test:coverage:e2e

# CI coverage with limits
npm run test:ci
```

### Coverage Output

```
-----------------|---------|----------|---------|---------|
File             | % Stmts | % Branch | % Funcs | % Lines |
-----------------|---------|----------|---------|---------|
All files        |   87.5  |   78.2   |   92.3  |   86.8  |
 cli/            |   89.2  |   80.1   |   94.5  |   88.7  |
 coordination/   |   91.3  |   85.4   |   96.2  |   90.8  |
 memory/         |   84.1  |   72.8   |   88.9  |   83.5  |
-----------------|---------|----------|---------|---------|
```

### Coverage Gaps Analysis

**Uncovered Critical Areas:**
```
src/cli/simple-commands/init/index.js:245-248
src/cli/simple-commands/init/batch-init.js:156-159
src/cli/simple-commands/init/validation/index.js:78-82
```

---

## Running Tests

### All Test Commands

From `package.json`:

```bash
# Run all tests (bail on first failure)
npm test

# Watch mode for development
npm run test:watch

# Specific test suites
npm run test:unit              # Unit tests only
npm run test:integration       # Integration tests only
npm run test:e2e              # End-to-end tests only
npm run test:performance      # Performance tests only
npm run test:cli              # CLI tests only

# Coverage reports
npm run test:coverage         # All tests with coverage
npm run test:coverage:unit    # Unit tests with coverage
npm run test:coverage:integration
npm run test:coverage:e2e

# CI testing
npm run test:ci               # CI mode with coverage

# Debug mode
npm run test:debug            # Run with Node debugger

# Comprehensive testing
npm run test:comprehensive           # All test types
npm run test:comprehensive:verbose   # Verbose output
npm run test:comprehensive:full      # Load + Docker + NPX tests

# Specific test types
npm run test:load             # Load testing
npm run test:docker           # Docker integration
npm run test:npx              # NPX installation tests
npm run test:health           # Health check tests
npm run test:swarm            # Swarm coordination tests
npm run test:benchmark        # Benchmark tests
```

### Running Individual Tests

```bash
# Run specific test file
NODE_OPTIONS='--experimental-vm-modules' jest tests/unit/performance.test.js

# Run test with pattern
NODE_OPTIONS='--experimental-vm-modules' jest --testNamePattern="should spawn agents"

# Run with coverage for specific file
NODE_OPTIONS='--experimental-vm-modules' jest tests/unit/cli/ --coverage

# Run in watch mode
NODE_OPTIONS='--experimental-vm-modules' jest --watch tests/integration/
```

### Test Execution Flags

```bash
# Bail on first failure
jest --bail

# Force exit after tests
jest --forceExit

# Limit workers for performance
jest --maxWorkers=1

# Run tests in band (serial)
jest --runInBand

# No cache
jest --no-cache

# Update snapshots
jest --updateSnapshot
```

---

## Writing Tests

### Test File Template

```typescript
/**
 * Test suite description
 */
import { describe, test, expect, beforeEach, afterEach } from '@jest/globals';
import { setupTestEnvironment, teardownTestEnvironment } from '../test.utils.js';

describe('Component Name', () => {
  let testEnv;

  beforeEach(() => {
    testEnv = setupTestEnvironment();
  });

  afterEach(() => {
    teardownTestEnvironment();
  });

  describe('Feature Group', () => {
    test('should perform expected behavior', () => {
      // Arrange
      const input = { test: 'data' };

      // Act
      const result = performOperation(input);

      // Assert
      expect(result).toBeDefined();
      expect(result.success).toBe(true);
    });

    test('should handle edge cases', () => {
      expect(() => performOperation(null)).toThrow();
    });

    test('should validate async operations', async () => {
      const result = await asyncOperation();
      expect(result).resolves.toBeDefined();
    });
  });
});
```

### Mocking Strategies

#### Function Mocking

```typescript
import { jest } from '@jest/globals';

// Mock function
const mockFunction = jest.fn();
mockFunction.mockReturnValue('mocked value');
mockFunction.mockResolvedValue('async value');
mockFunction.mockRejectedValue(new Error('error'));

// Spy on existing function
const spy = jest.spyOn(object, 'method');
spy.mockImplementation(() => 'custom implementation');

// Verify calls
expect(mockFunction).toHaveBeenCalled();
expect(mockFunction).toHaveBeenCalledWith(arg1, arg2);
expect(mockFunction).toHaveBeenCalledTimes(3);
```

#### Module Mocking

```typescript
// Mock entire module
jest.mock('fs-extra', () => ({
  pathExists: jest.fn().mockResolvedValue(true),
  readJson: jest.fn().mockResolvedValue({ data: 'test' }),
  writeJson: jest.fn().mockResolvedValue(undefined)
}));

// Partial module mock
jest.mock('../../utils', () => ({
  ...jest.requireActual('../../utils'),
  specificFunction: jest.fn()
}));
```

### Test Data Management

#### Using Fixtures

```typescript
// tests/fixtures/generators.ts
export function generateCoordinationTasks(count: number) {
  return Array.from({ length: count }, (_, i) => ({
    id: `task-${i}`,
    priority: ['low', 'medium', 'high'][Math.floor(Math.random() * 3)],
    requiredResources: [`resource-${i % 3}`],
    estimatedDuration: Math.random() * 1000
  }));
}

export function generateMemoryEntries(count: number) {
  return Array.from({ length: count }, (_, i) => ({
    namespace: ['test', 'production', 'staging'][i % 3],
    key: `entry-${i}`,
    value: { id: i, data: `Test data ${i}` }
  }));
}

// Usage in tests
import { generateCoordinationTasks } from '../fixtures/generators.js';

test('should handle multiple tasks', () => {
  const tasks = generateCoordinationTasks(100);
  expect(tasks).toHaveLength(100);
});
```

#### Using Mocks

```typescript
// tests/mocks/index.ts
export const mockAgent = {
  id: 'mock-agent-1',
  name: 'Mock Agent',
  type: 'coordinator' as const,
  capabilities: ['task-management'],
  maxConcurrentTasks: 5
};

export const mockConfig = {
  orchestrator: {
    maxConcurrentAgents: 10,
    taskQueueSize: 100
  },
  memory: {
    backend: 'sqlite' as const,
    cacheSizeMB: 10
  }
};
```

### Setup and Teardown Patterns

```typescript
// Global setup
beforeAll(async () => {
  // Setup database, servers, etc.
  await initializeTestDatabase();
  testServer = await startTestServer();
});

// Global teardown
afterAll(async () => {
  // Cleanup resources
  await testServer.close();
  await cleanupTestDatabase();
});

// Per-test setup
beforeEach(() => {
  jest.clearAllMocks();
  process.env.NODE_ENV = 'test';
});

// Per-test teardown
afterEach(() => {
  delete process.env.LOG_LEVEL;
});
```

---

## Test Utilities

### Core Test Utilities

**Location:** `/tests/test.utils.ts`

```typescript
// Mock implementations
export const mockLogger = {
  info: jest.fn(),
  error: jest.fn(),
  warn: jest.fn()
};

export const mockCoordinationSystem = {
  initialize: jest.fn(),
  shutdown: jest.fn(),
  addAgent: jest.fn()
};

// Test helper functions
export const createMockAgent = (id: string, type: string = 'test') => ({
  id,
  type,
  capabilities: ['test'],
  status: 'idle',
  execute: jest.fn()
});

// Async utilities
export const waitFor = (ms: number) =>
  new Promise(resolve => setTimeout(resolve, ms));

export const waitForCondition = async (
  condition: () => boolean,
  timeout: number = 5000
): Promise<void> => {
  const startTime = Date.now();

  while (!condition()) {
    if (Date.now() - startTime > timeout) {
      throw new Error('Condition not met within timeout');
    }
    await waitFor(100);
  }
};

// Environment setup
export const setupTestEnvironment = () => {
  jest.clearAllMocks();
  process.env.NODE_ENV = 'test';
  process.env.LOG_LEVEL = 'error';

  return {
    logger: mockLogger,
    coordinationSystem: mockCoordinationSystem
  };
};
```

### Timer Mocking (FakeTime)

```typescript
import { FakeTime } from './test.utils.js';

test('should handle timeouts', () => {
  const fakeTime = new FakeTime();
  fakeTime.install();

  const callback = jest.fn();
  setTimeout(callback, 1000);

  fakeTime.tick(1000);
  expect(callback).toHaveBeenCalled();

  fakeTime.restore();
});
```

### Spy Utilities

```typescript
import { spy, stub } from './test.utils.js';

test('should track function calls', () => {
  const mySpy = spy();
  mySpy('arg1', 'arg2');

  expect(mySpy.calls.length).toBe(1);
  expect(mySpy).toHaveBeenCalledWith('arg1', 'arg2');
});
```

### Test Data Builders

```typescript
import { TestDataBuilder } from './test.utils.js';

test('should create test agents', () => {
  const agent = TestDataBuilder.createTestAgent({
    name: 'Custom Agent',
    type: 'researcher'
  });

  expect(agent.name).toBe('Custom Agent');
  expect(agent.type).toBe('researcher');
});

test('should create test config', () => {
  const config = TestDataBuilder.config();
  expect(config.orchestrator.maxConcurrentAgents).toBe(10);
});
```

---

## Performance Testing

### Benchmark Test Structure

```typescript
describe('Performance Benchmark Tests', () => {
  it('should initialize system within acceptable time', async () => {
    const startTime = performance.now();
    await systemIntegration.initialize(config);
    const endTime = performance.now();

    const initTime = endTime - startTime;

    expect(initTime).toBeLessThan(5000); // <5 seconds
    console.log(`System initialization: ${initTime.toFixed(2)}ms`);
  });
});
```

### Throughput Testing

```typescript
it('should handle high task throughput', async () => {
  const taskCount = 1000;
  const startTime = performance.now();

  const taskPromises = Array.from({ length: taskCount }, (_, i) =>
    taskEngine.createTask({
      type: 'development',
      objective: `Task ${i}`,
      priority: 'medium'
    })
  );

  const tasks = await Promise.all(taskPromises);
  const endTime = performance.now();

  const creationTime = endTime - startTime;
  const tasksPerSecond = (taskCount / creationTime) * 1000;

  expect(tasksPerSecond).toBeGreaterThan(30);
  console.log(`Created ${taskCount} tasks in ${creationTime}ms (${tasksPerSecond} tasks/sec)`);
});
```

### Memory Usage Testing

```typescript
test('should not leak memory during repeated operations', async () => {
  const getMemoryUsage = () => process.memoryUsage().heapUsed;

  const initialMemory = getMemoryUsage();

  for (let i = 0; i < 100; i++) {
    const largeArray = Array.from({ length: 1000 }, (_, j) => ({
      id: j,
      data: 'x'.repeat(1000)
    }));

    parseFlags([`--test${i}`, 'value']);

    if (global.gc) global.gc();
  }

  const finalMemory = getMemoryUsage();
  const memoryIncrease = finalMemory - initialMemory;

  expect(memoryIncrease).toBeLessThan(50 * 1024 * 1024); // <50MB
});
```

### Scalability Testing

```typescript
it('should scale agent listing efficiently', async () => {
  const agentCount = 500;

  // Spawn many agents
  await Promise.all(
    Array.from({ length: agentCount }, (_, i) =>
      agentManager.spawnAgent('coder', { name: `Coder-${i}` })
    )
  );

  // Benchmark listing
  const iterations = 100;
  const times: number[] = [];

  for (let i = 0; i < iterations; i++) {
    const startTime = performance.now();
    const agents = await agentManager.listAgents();
    const endTime = performance.now();

    times.push(endTime - startTime);
  }

  const averageTime = times.reduce((sum, time) => sum + time, 0) / times.length;

  expect(averageTime).toBeLessThan(50); // <50ms average
  console.log(`Agent listing: avg ${averageTime.toFixed(2)}ms`);
});
```

---

## Integration Testing

### Multi-Agent Coordination Tests

```typescript
describe('Agent Coordination Tests', () => {
  it('should test inter-agent communication', async () => {
    const results = {
      agentType: 'coder',
      agentCount: 5,
      communicationTests: []
    };

    for (let i = 0; i < 5; i++) {
      const test = {
        agentId: `coder-${i + 1}`,
        messagesSent: Math.floor(Math.random() * 50) + 10,
        messagesReceived: Math.floor(Math.random() * 50) + 10,
        averageLatency: Math.floor(Math.random() * 100) + 20,
        successRate: 0.95 + Math.random() * 0.05
      };
      results.communicationTests.push(test);
    }

    expect(results.communicationTests).toHaveLength(5);
    results.communicationTests.forEach(test => {
      expect(test.successRate).toBeGreaterThan(0.9);
    });
  });
});
```

### Memory Synchronization Tests

```typescript
describe('Memory Sharing Integration', () => {
  it('should test cross-agent memory synchronization', async () => {
    const agents = ['coder-1', 'tester-1', 'reviewer-1'];

    for (let i = 0; i < 5; i++) {
      const syncTest = {
        testId: i + 1,
        participants: agents.slice(0, Math.floor(Math.random() * 2) + 2),
        syncLatency: Math.floor(Math.random() * 200) + 50,
        conflictsDetected: Math.floor(Math.random() * 3),
        dataConsistency: true
      };

      expect(syncTest.syncLatency).toBeLessThan(500);
      expect(syncTest.dataConsistency).toBe(true);
    }
  });
});
```

### Fault Tolerance Tests

```typescript
describe('Fault Tolerance Tests', () => {
  it('should test agent failure recovery', async () => {
    const failureScenarios = [
      'agent-crash',
      'network-timeout',
      'memory-overflow',
      'task-timeout'
    ];

    for (const scenario of failureScenarios) {
      const test = {
        scenario: scenario,
        failureTime: new Date().toISOString(),
        detectionTime: Math.floor(Math.random() * 5000) + 1000,
        recoveryTime: Math.floor(Math.random() * 10000) + 3000,
        recoverySuccess: Math.random() > 0.1 // 90% success
      };

      expect(test.recoveryTime).toBeLessThan(20000);
      expect(test.detectionTime).toBeLessThan(10000);
    }
  });
});
```

---

## Continuous Integration

### GitHub Actions Workflows

#### Main Test Workflow

**File:** `.github/workflows/test.yml`

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linting
      run: npm run lint

    - name: Run all tests
      run: npm test

    - name: Generate coverage report
      run: npm run test:coverage
```

#### Integration Test Workflow

**File:** `.github/workflows/integration-tests.yml`

**Features:**
- Multi-agent coordination testing
- Memory sharing integration
- Fault tolerance validation
- Performance under load
- Comprehensive reporting

**Test Scopes:**
- `smoke`: 2 agents, basic tests
- `core`: 7 agents, standard tests
- `full`: 14 agents, comprehensive tests
- `stress`: 13 agents, stress tests

**Test Matrix:**
```yaml
strategy:
  matrix:
    include:
      - { type: coder, count: 4 }
      - { type: tester, count: 3 }
      - { type: reviewer, count: 2 }
      - { type: planner, count: 2 }
```

#### Status Badge Workflow

**File:** `.github/workflows/status-badges.yml`

Generates dynamic status badges for:
- Test status
- Coverage percentage
- Build status
- Version information

### CI Test Commands

```bash
# CI mode testing
npm run test:ci

# With specific worker count
jest --ci --coverage --maxWorkers=2

# Bail on first failure
jest --bail --ci

# Force exit after completion
jest --forceExit --ci
```

### Test Artifacts

CI workflows preserve:
- Test results (JSON format)
- Coverage reports (HTML/LCOV)
- Integration test logs
- Performance metrics
- Failure screenshots (E2E)

**Retention:** 30-90 days depending on artifact type

---

## Best Practices

### 1. Test Organization

**DO:**
- Group related tests with `describe` blocks
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Keep tests focused and atomic

**DON'T:**
- Test multiple behaviors in one test
- Rely on test execution order
- Share mutable state between tests
- Skip cleanup in teardown

### 2. Mocking Strategy

**DO:**
- Mock external dependencies
- Use spies to verify behavior
- Reset mocks between tests
- Mock at module boundaries

**DON'T:**
- Mock what you're testing
- Over-mock (test becomes meaningless)
- Share mock instances
- Forget to restore mocks

### 3. Async Testing

**DO:**
- Use async/await for clarity
- Set appropriate timeouts
- Test both success and failure
- Handle promise rejections

**DON'T:**
- Use callbacks (prefer promises)
- Forget to await async operations
- Set infinite timeouts
- Ignore unhandled rejections

### 4. Test Data

**DO:**
- Use test data builders
- Generate realistic data
- Test edge cases
- Use fixtures for complex data

**DON'T:**
- Hardcode magic values
- Use production data
- Create brittle assertions
- Share test data state

### 5. Performance Testing

**DO:**
- Measure actual performance
- Test under realistic load
- Track performance trends
- Set reasonable thresholds

**DON'T:**
- Use artificial delays
- Test on inconsistent hardware
- Ignore variance
- Set unrealistic benchmarks

### 6. Coverage Goals

**DO:**
- Aim for >80% coverage
- Focus on critical paths
- Test error handling
- Review uncovered code

**DON'T:**
- Chase 100% coverage
- Write tests just for coverage
- Ignore integration gaps
- Skip edge case testing

### 7. CI Integration

**DO:**
- Run tests on every PR
- Fail builds on test failures
- Generate coverage reports
- Archive test results

**DON'T:**
- Skip slow tests in CI
- Disable failing tests
- Ignore flaky tests
- Skip coverage checks

### 8. Test Maintenance

**DO:**
- Update tests with code changes
- Refactor brittle tests
- Remove obsolete tests
- Document complex test setups

**DON'T:**
- Leave commented-out tests
- Keep failing tests disabled
- Copy-paste test code
- Skip test refactoring

---

## Testing Checklist

### Before Committing

- [ ] All tests pass locally
- [ ] New code has tests
- [ ] Coverage meets thresholds
- [ ] No console errors/warnings
- [ ] Mocks properly cleaned up
- [ ] Test names are descriptive

### For New Features

- [ ] Unit tests for components
- [ ] Integration tests for workflows
- [ ] Performance benchmarks
- [ ] Edge case coverage
- [ ] Error handling tests
- [ ] Documentation updated

### For Bug Fixes

- [ ] Regression test added
- [ ] Root cause tested
- [ ] Related cases covered
- [ ] Integration verified
- [ ] Performance not degraded

---

## Troubleshooting

### Common Issues

**Tests timing out:**
```bash
# Increase timeout
jest --testTimeout=60000

# Or in test file
jest.setTimeout(60000);
```

**Memory issues:**
```bash
# Limit workers
jest --maxWorkers=1

# Enable garbage collection
NODE_OPTIONS='--expose-gc' jest

# Run in band
jest --runInBand
```

**Module resolution errors:**
```bash
# Clear cache
jest --clearCache

# Check module mapper in jest.config.js
# Verify import paths
```

**Flaky tests:**
- Add appropriate waits
- Check for race conditions
- Verify mock cleanup
- Isolate shared state

---

## Resources

### Documentation
- [Jest Documentation](https://jestjs.io/)
- [TypeScript Testing](https://jestjs.io/docs/getting-started#using-typescript)
- [Supertest API](https://github.com/visionmedia/supertest)

### Internal Files
- `/tests/test.utils.ts` - Test utilities
- `/tests/fixtures/generators.ts` - Test data generators
- `/tests/mocks/index.ts` - Mock implementations
- `/jest.config.js` - Jest configuration

### CI Workflows
- `.github/workflows/test.yml` - Main test suite
- `.github/workflows/integration-tests.yml` - Integration testing
- `.github/workflows/status-badges.yml` - Status reporting

---

**Last Updated:** 2025-11-18
**Maintained By:** Claude-flow Testing Team
**Questions?** See [CONTRIBUTING.md](../../CONTRIBUTING.md)
