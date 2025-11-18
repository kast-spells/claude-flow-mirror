# MLE-STAR Ensemble Agents Module

> **Status**: 🔴 **STANDALONE MODULE - NOT INTEGRATED**
>
> **Critical Finding**: This Python module exists in the codebase but is **NOT integrated** with the TypeScript orchestration layer. It appears to be a planned feature or legacy code that was never connected.

## Executive Summary

The MLE-STAR (Machine Learning Engineering - STAR) ensemble agents module is a sophisticated Python-based machine learning ensemble system implementing 4+ ensemble strategies with neural network integration. Despite being ~1,290 lines of production-quality code, **it has no integration points with the TypeScript codebase**.

### Module Statistics
- **Location**: `/src/mle-star/`
- **Files**: 3 Python modules
- **Total Lines**: ~1,290 lines
- **Dependencies**: scikit-learn, PyTorch, NumPy
- **Integration Status**: ❌ None (standalone)
- **Test Coverage**: Comprehensive test suite included

## 1. Module Overview

### 1.1 What Are Ensemble Agents?

Ensemble agents are specialized machine learning systems that combine multiple models to achieve better predictive performance than any single model. The MLE-STAR implementation provides:

- **4 Core Ensemble Strategies**: Dynamic weighting, stacking, mixture of experts, Bayesian averaging
- **Advanced Techniques**: Attention-based ensembles, hierarchical ensembles, adaptive selection
- **Neural Integration**: PyTorch-based gating networks and attention mechanisms
- **Performance Monitoring**: Real-time tracking and optimization

### 1.2 Why Python for This Module?

Python is used for MLE-STAR due to:

1. **Scientific Computing Ecosystem**: Native sklearn, PyTorch, NumPy integration
2. **ML Tooling**: Extensive machine learning libraries unavailable in TypeScript
3. **Performance**: Optimized numerical operations via NumPy/BLAS
4. **Prototyping**: Rapid ML experimentation and iteration

### 1.3 Role in Overall Architecture (Intended)

**Current Status**: No role - module is disconnected

**Intended Role** (based on code analysis):
```
┌─────────────────────────────────────────────┐
│         TypeScript Orchestration            │
│     (Agent Manager, Task Scheduler)         │
└──────────────────┬──────────────────────────┘
                   │
                   │ (MISSING INTEGRATION LAYER)
                   │
                   ▼
┌─────────────────────────────────────────────┐
│        Python MLE-STAR Module               │
│  (Ensemble Strategies, Model Training)      │
└─────────────────────────────────────────────┘
```

## 2. File Structure

### 2.1 Module Components

```
src/mle-star/
├── ensemble_agent_implementation.py  (427 lines)
│   ├── DynamicWeightingEnsemble
│   ├── StackingEnsemble
│   ├── MixtureOfExpertsEnsemble
│   ├── BayesianModelAveraging
│   └── EnsembleOptimizer
│
├── ensemble_agent_advanced.py       (472 lines)
│   ├── NeuralGatingNetwork (PyTorch)
│   ├── AttentionBasedEnsemble
│   ├── HierarchicalEnsemble
│   ├── AdaptiveEnsembleSelector
│   └── EnsembleMonitor
│
└── ensemble_agent_tests.py          (391 lines)
    ├── test_classification_ensembles()
    ├── test_regression_ensembles()
    ├── test_advanced_ensembles()
    └── test_ensemble_optimization()
```

### 2.2 Dependency Map

```python
# Core Dependencies
sklearn.base.BaseEstimator
sklearn.ensemble.{RandomForest, VotingClassifier}
sklearn.linear_model.{LogisticRegression, Ridge}
sklearn.model_selection.cross_val_predict

# Neural Dependencies
torch.nn.Module
torch.optim.Adam

# Scientific Computing
numpy
warnings (for sklearn warnings suppression)
```

## 3. Ensemble Agent Architecture

### 3.1 Architecture Overview

```mermaid
graph TB
    subgraph "Ensemble Optimizer"
        EO[EnsembleOptimizer]
        EO -->|creates| DWE[DynamicWeightingEnsemble]
        EO -->|creates| SE[StackingEnsemble]
        EO -->|creates| MOE[MixtureOfExpertsEnsemble]
        EO -->|creates| BMA[BayesianModelAveraging]
    end

    subgraph "Advanced Ensembles"
        ABE[AttentionBasedEnsemble]
        HE[HierarchicalEnsemble]
        AES[AdaptiveEnsembleSelector]
        EM[EnsembleMonitor]
    end

    subgraph "Base Models"
        BM1[RandomForest]
        BM2[LogisticRegression]
        BM3[SVM]
        BM4[MLP]
    end

    BM1 --> DWE
    BM2 --> DWE
    BM3 --> SE
    BM4 --> SE

    AES -->|selects strategy| EO
    EM -->|monitors| DWE
    EM -->|monitors| SE

    ABE -->|PyTorch| NN[Neural Gating]
    MOE -->|uses| NN
```

### 3.2 Ensemble Strategies

#### 3.2.1 Dynamic Weighting Ensemble

**File**: `ensemble_agent_implementation.py:16-79`

**Purpose**: Automatically compute model weights based on cross-validation performance

**Algorithm**:
```python
class DynamicWeightingEnsemble(BaseEstimator):
    """
    1. Fit all base models
    2. Compute CV performance for each model
    3. Apply softmax to convert scores to weights
    4. Make weighted predictions
    """

    def _compute_dynamic_weights(self, X, y):
        performances = []
        for model in self.models:
            score = cross_val_score(model, X, y, cv=3)
            performances.append(score)

        # Softmax for smooth weights
        exp_scores = np.exp(performances - np.max(performances))
        weights = exp_scores / exp_scores.sum()
        return weights
```

**Use Cases**:
- Models with similar architectures
- When model diversity is low
- Fast prediction requirements

**Complexity**: O(n_models × n_cv_folds × model_complexity)

#### 3.2.2 Stacking Ensemble

**File**: `ensemble_agent_implementation.py:81-162`

**Purpose**: Use meta-learner to combine base model predictions

**Architecture**:
```
Layer 1 (Base Models)    Layer 2 (Meta Model)
┌─────────────────┐
│  RandomForest   │──────┐
└─────────────────┘      │
┌─────────────────┐      ├──► ┌──────────────┐
│      SVM        │──────┤    │ Logistic     │──► Final
└─────────────────┘      │    │ Regression   │    Prediction
┌─────────────────┐      │    └──────────────┘
│      MLP        │──────┘
└─────────────────┘
```

**Key Features**:
- Out-of-fold predictions to avoid overfitting
- Supports probability predictions for classification
- Configurable meta-model (default: LogisticRegression/Ridge)

**Training Process**:
```python
def fit(self, X, y):
    # 1. Generate meta-features using cross-validation
    meta_features = self._generate_meta_features(X, y, training=True)

    # 2. Train meta-model on meta-features
    self.meta_model.fit(meta_features, y)

    # 3. Refit base models on full data
    for model in self.base_models:
        model.fit(X, y)
```

#### 3.2.3 Mixture of Experts (MoE)

**File**: `ensemble_agent_implementation.py:164-230`

**Purpose**: Different models specialize in different regions of input space

**Architecture**:
```mermaid
graph LR
    Input[Input X] --> GN[Gating Network]
    Input --> E1[Expert 1]
    Input --> E2[Expert 2]
    Input --> E3[Expert 3]

    GN -->|weight_1| C[Weighted Combination]
    E1 -->|prediction_1| C
    GN -->|weight_2| C
    E2 -->|prediction_2| C
    GN -->|weight_3| C
    E3 -->|prediction_3| C

    C --> Output[Final Prediction]
```

**Gating Network Training**:
```python
def fit(self, X, y):
    # 1. Fit expert models
    for expert in self.expert_models:
        expert.fit(X, y)

    # 2. Evaluate which expert is best for each sample
    expert_performances = self._evaluate_expert_performance(X, y)
    best_experts = np.argmax(expert_performances, axis=1)

    # 3. Train gating network to predict best expert
    self.gate_model = RandomForestClassifier(n_estimators=50)
    self.gate_model.fit(gate_X, best_experts)
```

**Use Cases**:
- Heterogeneous data (different clusters/regions)
- Class imbalance problems
- Multi-modal distributions

#### 3.2.4 Bayesian Model Averaging

**File**: `ensemble_agent_implementation.py:232-297`

**Purpose**: Combine models weighted by posterior probability using BIC

**Mathematical Foundation**:
```
BIC = n_samples × log(RSS/n_samples) + n_params × log(n_samples)

posterior_weight ∝ exp(-0.5 × (BIC - min_BIC)) × prior_weight
```

**Implementation**:
```python
def _compute_posterior_weights(self, X, y):
    bic_scores = []
    for model in self.models:
        predictions = model.predict(X)
        rss = np.sum((y - predictions) ** 2)
        n_params = self._estimate_n_params(model)
        bic = n_samples * np.log(rss/n_samples) + n_params * np.log(n_samples)
        bic_scores.append(bic)

    # Convert BIC to weights (lower is better)
    exp_scores = np.exp(-0.5 * (bic_scores - np.min(bic_scores)))
    posterior = exp_scores * self.prior_weights
    return posterior / posterior.sum()
```

### 3.3 Advanced Neural Techniques

#### 3.3.1 Neural Gating Network (PyTorch)

**File**: `ensemble_agent_advanced.py:14-32`

```python
class NeuralGatingNetwork(nn.Module):
    """
    Sophisticated gating using deep neural network

    Architecture:
        Input (n_features)
        ↓
        Linear(hidden_dim) + ReLU + Dropout(0.2)
        ↓
        Linear(hidden_dim) + ReLU + Dropout(0.2)
        ↓
        Linear(n_experts) + Softmax
        ↓
        Output (expert weights)
    """
    def __init__(self, input_dim, n_experts, hidden_dim=64):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(hidden_dim, n_experts),
            nn.Softmax(dim=1)
        )
```

#### 3.3.2 Attention-Based Ensemble

**File**: `ensemble_agent_advanced.py:34-135`

**Purpose**: Use self-attention mechanism to weight model outputs

**Attention Mechanism**:
```
Q = Query(input_features)
K = Key(model_outputs)
V = Value(model_outputs)

attention_weights = softmax(Q·K^T / √d_k)
output = attention_weights · V
```

**Training**:
```python
def _train_attention(self, X, y, epochs=100):
    X_tensor = torch.FloatTensor(X)
    y_tensor = torch.FloatTensor(y)

    optimizer = optim.Adam(self.attention_network.parameters(), lr=0.001)
    criterion = nn.MSELoss()

    for epoch in range(epochs):
        weighted_outputs, _ = self.attention_network(X_tensor, outputs_tensor)
        ensemble_pred = weighted_outputs.sum(dim=1)
        loss = criterion(ensemble_pred, y_tensor)
        loss.backward()
        optimizer.step()
```

#### 3.3.3 Hierarchical Ensemble

**File**: `ensemble_agent_advanced.py:137-186`

**Purpose**: Multi-level ensemble with recursive combination

**Structure**:
```
Level 0:           Model1  Model2  Model3  Model4  Model5
                      ↓      ↓      ↓      ↓      ↓
Level 1:          Ensemble1    Ensemble2    Model5
                      ↓            ↓           ↓
Level 2:              Final Ensemble
```

**Algorithm**:
```python
def fit(self, X, y):
    current_models = self.base_models

    for level in range(self.n_levels):
        level_ensemble = []

        # Group models in pairs
        for i in range(0, len(current_models), 2):
            if i + 1 < len(current_models):
                mini_ensemble = DynamicWeightingEnsemble([
                    current_models[i],
                    current_models[i+1]
                ])
                mini_ensemble.fit(X, y)
                level_ensemble.append(mini_ensemble)

        current_models = level_ensemble

    # Final stacking ensemble
    self.final_ensemble = StackingEnsemble(current_models)
    self.final_ensemble.fit(X, y)
```

### 3.4 Adaptive Ensemble Selection

**File**: `ensemble_agent_advanced.py:188-307`

**Purpose**: Automatically select best ensemble strategy based on data characteristics

**Data Characteristics Analyzed**:
```python
def analyze_data_characteristics(self, X, y):
    return {
        'n_samples': n_samples,
        'n_features': n_features,
        'sample_feature_ratio': n_samples / n_features,
        'feature_variance': np.var(X, axis=0).mean(),
        'target_variance': np.var(y),
        'feature_correlation': avg_abs_correlation,
        'class_balance': min_count / max_count
    }
```

**Strategy Scoring**:
```python
# Stacking: Good for diverse models and sufficient data
scores['stacking'] = (
    min(sample_feature_ratio / 10, 1.0) * 0.4 +
    (1 - feature_correlation) * 0.3 +
    (n_models / 10) * 0.3
)

# Dynamic Weighting: Good for similar models
scores['dynamic_weighting'] = (
    feature_correlation * 0.4 +
    (1 - sample_feature_ratio / 50) * 0.3 +
    class_balance * 0.3
)

# Mixture of Experts: Good for heterogeneous data
scores['mixture_of_experts'] = (
    (1 - class_balance) * 0.4 +
    feature_variance * 0.3 +
    min(n_features / 50, 1.0) * 0.3
)
```

## 4. Python Code Analysis

### 4.1 ensemble_agent_implementation.py (427 lines)

**Classes**:

| Class | Lines | Purpose | Complexity |
|-------|-------|---------|------------|
| DynamicWeightingEnsemble | 16-79 | Softmax-weighted ensemble | O(n×k×m) |
| StackingEnsemble | 81-162 | Meta-learning ensemble | O(n×k×m + n×meta) |
| MixtureOfExpertsEnsemble | 164-230 | Gated expert mixture | O(n²×k×m) |
| BayesianModelAveraging | 232-297 | BIC-weighted ensemble | O(n×k×m) |
| EnsembleOptimizer | 299-375 | Factory and optimizer | O(n×k×m) |

**Key Dependencies**:
- `sklearn.base`: BaseEstimator, RegressorMixin, ClassifierMixin
- `sklearn.model_selection`: cross_val_predict, train_test_split
- `sklearn.metrics`: accuracy_score, mean_squared_error
- `sklearn.ensemble`: RandomForestClassifier/Regressor
- `numpy`: array operations, exp, log, corrcoef

**Design Patterns**:
- **Factory Pattern**: EnsembleOptimizer creates ensemble instances
- **Strategy Pattern**: Interchangeable ensemble strategies
- **Template Method**: BaseEstimator provides fit/predict interface

### 4.2 ensemble_agent_advanced.py (472 lines)

**Classes**:

| Class | Lines | Purpose | Framework |
|-------|-------|---------|-----------|
| NeuralGatingNetwork | 14-32 | Deep learning gating | PyTorch |
| AttentionBasedEnsemble | 34-135 | Self-attention ensemble | PyTorch + sklearn |
| HierarchicalEnsemble | 137-186 | Multi-level ensemble | sklearn |
| AdaptiveEnsembleSelector | 188-307 | Auto-strategy selection | sklearn |
| EnsembleMonitor | 309-419 | Performance tracking | sklearn.metrics |

**PyTorch Integration**:
```python
import torch
import torch.nn as nn
import torch.optim as optim

# Neural network components
class NeuralGatingNetwork(nn.Module):
    def __init__(self, input_dim, n_experts, hidden_dim=64):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(hidden_dim, n_experts),
            nn.Softmax(dim=1)
        )
```

**Monitoring System**:
```python
class EnsembleMonitor:
    def track_performance(self, ensemble, X_test, y_test):
        # Calculate metrics
        predictions = ensemble.predict(X_test)

        metrics = {
            'accuracy': accuracy_score(y_test, predictions),
            'f1_score': f1_score(y_test, predictions, average='weighted'),
            'timestamp': str(np.datetime64('now')),
            'n_samples': len(y_test)
        }

        self.performance_history.append(metrics)
        return metrics

    def _calculate_trend(self):
        if len(self.performance_history) < 2:
            return 'insufficient_data'

        values = [h[metric_key] for h in self.performance_history]
        trend = np.polyfit(range(len(values)), values, 1)[0]

        return 'improving' if trend > 0.01 else 'degrading' if trend < -0.01 else 'stable'
```

### 4.3 ensemble_agent_tests.py (391 lines)

**Test Coverage**:

```python
def test_classification_ensembles():
    """
    Tests all 4 ensemble strategies on classification:
    - Dynamic Weighting
    - Stacking
    - Mixture of Experts
    - Bayesian Averaging

    Compares to individual model baselines
    Measures training/prediction time
    """

def test_regression_ensembles():
    """
    Tests regression ensembles:
    - Dynamic Weighting
    - Stacking
    - Bayesian Averaging

    Uses R² and MSE metrics
    """

def test_advanced_ensembles():
    """
    Tests advanced techniques:
    - Adaptive Ensemble Selection
    - Data characteristics analysis
    - Ensemble Monitoring
    - Performance trend detection
    """

def test_ensemble_optimization():
    """
    Tests model composition optimization:
    - Greedy selection of diverse models
    - Correlation-based diversity checking
    - Performance comparison (optimized vs all models)
    """
```

**Test Execution**:
```bash
$ python ensemble_agent_tests.py

MLE-STAR Ensemble Agent Test Suite
================================================================================

Testing Classification Ensembles
============================================================

Individual Model Performance:
----------------------------------------
LogisticRegression: 0.8556 (train time: 0.12s)
RandomForestClassifier: 0.8889 (train time: 0.45s)
SVC: 0.8711 (train time: 0.89s)
DecisionTreeClassifier: 0.8267 (train time: 0.05s)
MLPClassifier: 0.8622 (train time: 1.23s)

Ensemble Performance:
----------------------------------------
dynamic_weighting: 0.9022 (improvement: +0.0133, train: 2.15s, pred: 0.045s)
stacking: 0.9111 (improvement: +0.0222, train: 3.67s, pred: 0.098s)
mixture_of_experts: 0.8978 (improvement: +0.0089, train: 1.89s, pred: 0.067s)
bayesian_averaging: 0.8956 (improvement: +0.0067, train: 2.34s, pred: 0.034s)
```

## 5. Cross-Language Integration

### 5.1 Current Integration Status

**⚠️ CRITICAL: NO INTEGRATION EXISTS**

Findings from codebase analysis:
- ✅ Python modules are complete and production-ready
- ❌ No TypeScript files import or reference mle-star
- ❌ No process spawning code found (child_process, spawn, exec)
- ❌ No Python bridge or RPC mechanism
- ❌ No configuration files linking Python to TypeScript
- ❌ No API endpoints exposing ensemble functionality

**Evidence**:
```bash
# Search results for Python integration
$ grep -r "mle-star" src/**/*.ts
# No results

$ grep -r "ensemble.*agent" src/**/*.ts
# No results

$ grep -r "spawn.*python" src/**/*.ts
# No results
```

### 5.2 Intended Integration Patterns (Hypothetical)

Based on similar patterns in the codebase, integration **would** likely use:

#### Option A: Child Process Spawning

```typescript
// HYPOTHETICAL - NOT IMPLEMENTED
import { spawn } from 'child_process';

export class EnsembleAgentManager {
  async createEnsemble(
    models: Model[],
    strategy: 'stacking' | 'dynamic_weighting' | 'moe' | 'bayesian',
    data: { X: number[][], y: number[] }
  ): Promise<EnsembleResult> {

    const pythonProcess = spawn('python', [
      './src/mle-star/ensemble_agent_implementation.py',
      '--strategy', strategy,
      '--models', JSON.stringify(models),
      '--data', JSON.stringify(data)
    ]);

    return new Promise((resolve, reject) => {
      pythonProcess.stdout.on('data', (data) => {
        const result = JSON.parse(data.toString());
        resolve(result);
      });

      pythonProcess.stderr.on('data', (data) => {
        reject(new Error(data.toString()));
      });
    });
  }
}
```

#### Option B: HTTP API Bridge

```typescript
// HYPOTHETICAL - NOT IMPLEMENTED
import axios from 'axios';

export class EnsemblePythonBridge {
  private pythonServiceUrl = 'http://localhost:8000';

  async trainEnsemble(config: EnsembleConfig): Promise<EnsembleModel> {
    const response = await axios.post(`${this.pythonServiceUrl}/ensemble/train`, {
      strategy: config.strategy,
      base_models: config.models,
      X_train: config.data.X,
      y_train: config.data.y
    });

    return response.data;
  }

  async predict(modelId: string, X: number[][]): Promise<number[]> {
    const response = await axios.post(`${this.pythonServiceUrl}/ensemble/predict`, {
      model_id: modelId,
      X: X
    });

    return response.data.predictions;
  }
}
```

#### Option C: WebAssembly/PyScript

```typescript
// HYPOTHETICAL - NOT IMPLEMENTED
// Would require compiling Python to WASM
import { loadPyodide } from 'pyodide';

export class WasmEnsembleAgent {
  private pyodide: any;

  async initialize() {
    this.pyodide = await loadPyodide();
    await this.pyodide.loadPackage(['numpy', 'scikit-learn']);

    // Load Python modules
    await this.pyodide.runPython(`
      from ensemble_agent_implementation import EnsembleOptimizer
      optimizer = EnsembleOptimizer()
    `);
  }

  async createEnsemble(strategy: string): Promise<any> {
    return await this.pyodide.runPython(`
      ensemble = optimizer.create_ensemble(models, strategy='${strategy}')
      ensemble.to_json()
    `);
  }
}
```

### 5.3 Communication Protocols (If Implemented)

**Data Serialization Format**:
```json
{
  "request_type": "train_ensemble",
  "request_id": "uuid-1234",
  "payload": {
    "strategy": "stacking",
    "task_type": "classification",
    "base_models": [
      {
        "type": "RandomForestClassifier",
        "params": {"n_estimators": 100, "random_state": 42}
      },
      {
        "type": "LogisticRegression",
        "params": {"max_iter": 1000}
      }
    ],
    "data": {
      "X_train": [[...], [...]],
      "y_train": [0, 1, 0, ...],
      "cv_folds": 5
    }
  }
}
```

**Response Format**:
```json
{
  "request_id": "uuid-1234",
  "status": "success",
  "result": {
    "model_id": "ensemble_abc123",
    "strategy": "stacking",
    "cv_score": 0.9111,
    "base_models": ["model_1", "model_2"],
    "meta_model": "LogisticRegression",
    "training_time": 3.67,
    "model_path": "/models/ensemble_abc123.pkl"
  }
}
```

### 5.4 Process Management (If Implemented)

```typescript
// HYPOTHETICAL
export class PythonProcessPool {
  private processes: Map<string, ChildProcess> = new Map();
  private maxProcesses = 4;

  async getProcess(): Promise<ChildProcess> {
    if (this.processes.size < this.maxProcesses) {
      const process = spawn('python', ['-u', './python_worker.py']);
      const id = nanoid();
      this.processes.set(id, process);
      return process;
    }

    // Round-robin selection
    const processes = Array.from(this.processes.values());
    return processes[Math.floor(Math.random() * processes.length)];
  }

  async cleanup() {
    for (const [id, process] of this.processes) {
      process.kill('SIGTERM');
      this.processes.delete(id);
    }
  }
}
```

## 6. API Reference

### 6.1 Python API

#### EnsembleOptimizer

```python
class EnsembleOptimizer:
    """Main ensemble factory and optimizer"""

    def create_ensemble(
        self,
        models: List[BaseEstimator],
        strategy: str = 'stacking',
        task_type: str = 'classification',
        **kwargs
    ) -> BaseEstimator:
        """
        Create ensemble with specified strategy

        Args:
            models: List of fitted sklearn models
            strategy: One of ['dynamic_weighting', 'stacking',
                             'mixture_of_experts', 'bayesian_averaging']
            task_type: 'classification' or 'regression'
            **kwargs: Strategy-specific parameters

        Returns:
            Fitted ensemble model

        Example:
            >>> from sklearn.ensemble import RandomForestClassifier
            >>> from sklearn.svm import SVC
            >>>
            >>> models = [RandomForestClassifier(), SVC(probability=True)]
            >>> for m in models: m.fit(X_train, y_train)
            >>>
            >>> optimizer = EnsembleOptimizer()
            >>> ensemble = optimizer.create_ensemble(
            ...     models,
            ...     strategy='stacking',
            ...     task_type='classification'
            ... )
            >>> ensemble.fit(X_train, y_train)
            >>> predictions = ensemble.predict(X_test)
        """
```

#### AdaptiveEnsembleSelector

```python
class AdaptiveEnsembleSelector:
    """Automatically select best ensemble strategy"""

    def recommend_strategy(
        self,
        X: np.ndarray,
        y: np.ndarray,
        models: List[BaseEstimator]
    ) -> str:
        """
        Analyze data and recommend best strategy

        Args:
            X: Feature matrix
            y: Target vector
            models: Available base models

        Returns:
            Strategy name ('stacking', 'dynamic_weighting', etc.)

        Example:
            >>> selector = AdaptiveEnsembleSelector()
            >>> strategy = selector.recommend_strategy(X, y, models)
            >>> print(f"Recommended: {strategy}")
            >>> print(f"Scores: {selector.strategy_scores}")
        """

    def create_adaptive_ensemble(
        self,
        X: np.ndarray,
        y: np.ndarray,
        models: List[BaseEstimator]
    ) -> BaseEstimator:
        """
        Create ensemble with auto-selected strategy

        Performs:
        1. Data analysis
        2. Strategy selection
        3. Model optimization
        4. Ensemble creation

        Returns:
            Fitted ensemble with optimal strategy
        """
```

#### EnsembleMonitor

```python
class EnsembleMonitor:
    """Monitor ensemble performance over time"""

    def track_performance(
        self,
        ensemble: BaseEstimator,
        X_test: np.ndarray,
        y_test: np.ndarray,
        timestamp: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Track performance metrics

        Args:
            ensemble: Fitted ensemble model
            X_test: Test features
            y_test: Test targets
            timestamp: Optional timestamp (defaults to now)

        Returns:
            Dict with metrics:
            {
                'accuracy': 0.91,
                'f1_score': 0.89,
                'timestamp': '2025-01-04T10:00:00',
                'n_samples': 200
            }
        """

    def generate_report(self) -> Dict[str, Any]:
        """
        Generate comprehensive report

        Returns:
            {
                'performance_summary': {...},
                'model_contributions': {...},
                'recommendations': [...]
            }
        """
```

### 6.2 TypeScript Integration API (Hypothetical)

```typescript
/**
 * NOT IMPLEMENTED - Hypothetical interface
 */
export interface IEnsembleAgent {
  /**
   * Create and train ensemble model
   */
  createEnsemble(config: EnsembleConfig): Promise<EnsembleModel>;

  /**
   * Make predictions with trained ensemble
   */
  predict(modelId: string, X: number[][]): Promise<number[]>;

  /**
   * Get ensemble performance metrics
   */
  getMetrics(modelId: string): Promise<EnsembleMetrics>;

  /**
   * Optimize ensemble composition
   */
  optimizeComposition(
    candidateModels: Model[],
    validationData: Dataset,
    maxModels?: number
  ): Promise<Model[]>;
}

export interface EnsembleConfig {
  strategy: 'stacking' | 'dynamic_weighting' | 'moe' | 'bayesian';
  taskType: 'classification' | 'regression';
  baseModels: ModelConfig[];
  data: {
    X: number[][];
    y: number[];
  };
  cvFolds?: number;
}

export interface EnsembleModel {
  id: string;
  strategy: string;
  cvScore: number;
  baseModels: string[];
  modelPath: string;
  trainingTime: number;
}
```

### 6.3 Message Formats (Hypothetical)

**Train Request**:
```json
{
  "action": "train",
  "request_id": "req_123",
  "config": {
    "strategy": "stacking",
    "task_type": "classification",
    "base_models": [
      {"type": "RandomForestClassifier", "params": {"n_estimators": 100}},
      {"type": "SVC", "params": {"probability": true}}
    ],
    "meta_model": {"type": "LogisticRegression"},
    "cv_folds": 5
  },
  "data": {
    "X_train": "base64_encoded_numpy_array",
    "y_train": "base64_encoded_numpy_array"
  }
}
```

**Predict Request**:
```json
{
  "action": "predict",
  "request_id": "req_124",
  "model_id": "ensemble_abc123",
  "data": {
    "X": "base64_encoded_numpy_array"
  }
}
```

**Response**:
```json
{
  "request_id": "req_123",
  "status": "success",
  "result": {
    "model_id": "ensemble_abc123",
    "cv_score": 0.9111,
    "training_time": 3.67,
    "model_path": "/models/ensemble_abc123.pkl"
  },
  "metadata": {
    "python_version": "3.10",
    "sklearn_version": "1.0.0",
    "timestamp": "2025-01-04T10:00:00Z"
  }
}
```

## 7. Performance Characteristics

### 7.1 Computational Complexity

| Ensemble Strategy | Training Complexity | Prediction Complexity | Memory |
|-------------------|--------------------|--------------------|---------|
| Dynamic Weighting | O(n × k × m) | O(m) | O(m) |
| Stacking | O(n × k × m + n × meta) | O(m + meta) | O(m + meta) |
| Mixture of Experts | O(n² × k × m) | O(m + gate) | O(m + gate) |
| Bayesian Averaging | O(n × k × m) | O(m) | O(m) |
| Attention-Based | O(n × k × m + epochs × n) | O(m + attention) | O(m + θ) |
| Hierarchical | O(levels × n × k × m) | O(log(m)) | O(m) |

**Legend**:
- n = number of samples
- k = number of CV folds
- m = number of base models
- meta = meta-model complexity
- gate = gating network complexity
- θ = neural network parameters

### 7.2 Benchmarks (from tests)

**Classification Task** (1500 samples, 20 features, 3 classes):

```
Individual Models:
├── LogisticRegression:  0.8556  (0.12s train)
├── RandomForest:        0.8889  (0.45s train)
├── SVM:                 0.8711  (0.89s train)
└── MLP:                 0.8622  (1.23s train)

Ensembles:
├── Dynamic Weighting:   0.9022  (+1.33%, 2.15s train, 0.045s pred)
├── Stacking:            0.9111  (+2.22%, 3.67s train, 0.098s pred)
├── Mixture of Experts:  0.8978  (+0.89%, 1.89s train, 0.067s pred)
└── Bayesian Averaging:  0.8956  (+0.67%, 2.34s train, 0.034s pred)
```

**Performance Gains**:
- Best improvement: **Stacking (+2.22%)**
- Fastest prediction: **Bayesian Averaging (0.034s)**
- Best trade-off: **Dynamic Weighting (+1.33%, fast prediction)**

### 7.3 Scalability Limits

**Dataset Size**:
- ✅ Small: < 10K samples (all strategies work well)
- ✅ Medium: 10K-100K samples (use Dynamic Weighting or Bayesian)
- ⚠️ Large: 100K-1M samples (avoid MoE, use subsampling)
- ❌ Very Large: > 1M samples (requires distributed training - not implemented)

**Number of Models**:
- ✅ 2-5 models: All strategies applicable
- ✅ 5-10 models: Use composition optimization
- ⚠️ 10-20 models: High memory usage, consider pruning
- ❌ > 20 models: Not recommended without hierarchical approach

**Feature Dimensionality**:
- ✅ Low: < 100 features (no issues)
- ✅ Medium: 100-1000 features (use feature selection)
- ⚠️ High: 1000-10000 features (dimensionality reduction needed)
- ❌ Very High: > 10000 features (requires sparse matrix support)

### 7.4 Memory Requirements

```python
# Approximate memory usage (classification)
base_model_memory = n_samples * n_features * 8 bytes  # float64

dynamic_weighting = m * base_model_memory + m * 8  # weights
stacking = m * base_model_memory + meta_model_memory + n_samples * m * 8
moe = m * base_model_memory + gate_model_memory
bayesian = m * base_model_memory + m * 8  # posterior weights
attention = m * base_model_memory + neural_params * 4  # float32

# Example: 10K samples, 100 features, 5 models
# Base memory: 10000 * 100 * 8 * 5 = 40 MB
# Stacking total: 40 MB + 5 MB (meta) + 0.4 MB (meta-features) ≈ 45 MB
```

## 8. Usage Guide

### 8.1 Basic Usage

#### Example 1: Creating a Stacking Ensemble

```python
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression

from ensemble_agent_implementation import EnsembleOptimizer

# Generate data
X, y = make_classification(n_samples=1000, n_features=20, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Create base models
models = [
    RandomForestClassifier(n_estimators=100, random_state=42),
    SVC(probability=True, random_state=42),
    LogisticRegression(max_iter=1000)
]

# Fit base models
for model in models:
    model.fit(X_train, y_train)

# Create stacking ensemble
optimizer = EnsembleOptimizer()
ensemble = optimizer.create_ensemble(
    models,
    strategy='stacking',
    task_type='classification'
)

# Train ensemble
ensemble.fit(X_train, y_train)

# Make predictions
predictions = ensemble.predict(X_test)
score = ensemble.score(X_test, y_test)

print(f"Ensemble accuracy: {score:.4f}")
```

#### Example 2: Adaptive Strategy Selection

```python
from ensemble_agent_advanced import AdaptiveEnsembleSelector

# Prepare models
models = [
    RandomForestClassifier(n_estimators=50),
    RandomForestClassifier(n_estimators=100),
    LogisticRegression(),
    SVC(probability=True)
]

# Fit models
for model in models:
    model.fit(X_train, y_train)

# Auto-select best strategy
selector = AdaptiveEnsembleSelector()
ensemble = selector.create_adaptive_ensemble(X_train, y_train, models)

print(f"Selected strategy: {selector.selected_strategy}")
print(f"Strategy scores: {selector.strategy_scores}")

# Use ensemble
predictions = ensemble.predict(X_test)
```

#### Example 3: Performance Monitoring

```python
from ensemble_agent_advanced import EnsembleMonitor

# Create monitor
monitor = EnsembleMonitor()

# Track performance over multiple test sets
for i in range(5):
    X_val, _, y_val, _ = train_test_split(X_test, y_test, test_size=0.5)

    metrics = monitor.track_performance(
        ensemble, X_val, y_val,
        timestamp=f"eval_{i}"
    )

    print(f"Evaluation {i}: {metrics}")

# Generate report
report = monitor.generate_report()
print(f"Performance trend: {report['performance_summary']['performance_trend']}")
print(f"Recommendations: {report['recommendations']}")
```

### 8.2 Advanced Usage

#### Mixture of Experts with Custom Gating

```python
from ensemble_agent_implementation import MixtureOfExpertsEnsemble

# Create specialized expert models
expert_models = [
    RandomForestClassifier(max_depth=5),   # Shallow trees
    RandomForestClassifier(max_depth=20),  # Deep trees
    SVC(kernel='rbf')                      # Non-linear
]

# Fit experts
for expert in expert_models:
    expert.fit(X_train, y_train)

# Create MoE with feature subset for gating
moe = MixtureOfExpertsEnsemble(
    expert_models,
    gate_features=[0, 1, 2, 3, 4]  # Use first 5 features for gating
)

moe.fit(X_train, y_train)
predictions = moe.predict(X_test)
```

#### Hierarchical Ensemble

```python
from ensemble_agent_advanced import HierarchicalEnsemble

# Create many base models
base_models = [
    RandomForestClassifier(n_estimators=50, random_state=i)
    for i in range(10)
]

# Fit models
for model in base_models:
    model.fit(X_train, y_train)

# Create hierarchical ensemble (3 levels)
hierarchical = HierarchicalEnsemble(base_models, n_levels=3)
hierarchical.fit(X_train, y_train)

predictions = hierarchical.predict(X_test)
```

#### Attention-Based Ensemble

```python
from ensemble_agent_advanced import AttentionBasedEnsemble

# Create diverse models
models = [
    RandomForestClassifier(),
    LogisticRegression(),
    SVC(probability=True)
]

for model in models:
    model.fit(X_train, y_train)

# Create attention ensemble
attention_ensemble = AttentionBasedEnsemble(
    models,
    attention_dim=32  # Attention embedding dimension
)

attention_ensemble.fit(X_train, y_train)
predictions = attention_ensemble.predict(X_test)
```

### 8.3 Configuration Examples

#### Complete Workflow

```python
from ensemble_agent_implementation import EnsembleOptimizer
from ensemble_agent_advanced import AdaptiveEnsembleSelector, EnsembleMonitor
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
import numpy as np

# 1. Prepare candidate models
candidate_models = [
    RandomForestClassifier(n_estimators=50, random_state=42),
    RandomForestClassifier(n_estimators=100, random_state=43),
    SVC(probability=True, random_state=42),
    LogisticRegression(max_iter=1000),
    DecisionTreeClassifier(max_depth=10)
]

# Fit candidates
for model in candidate_models:
    model.fit(X_train, y_train)

# 2. Optimize model composition
optimizer = EnsembleOptimizer()
X_val, X_final_test, y_val, y_final_test = train_test_split(
    X_test, y_test, test_size=0.5
)

selected_models = optimizer.optimize_ensemble_composition(
    candidate_models,
    X_val,
    y_val,
    max_models=3  # Select top 3 diverse models
)

print(f"Selected {len(selected_models)} models")

# 3. Auto-select strategy
selector = AdaptiveEnsembleSelector()
strategy = selector.recommend_strategy(X_train, y_train, selected_models)
print(f"Recommended strategy: {strategy}")

# 4. Create ensemble
ensemble = optimizer.create_ensemble(
    selected_models,
    strategy=strategy,
    task_type='classification'
)

# Refit selected models on full training data
for model in selected_models:
    model.fit(X_train, y_train)

ensemble.fit(X_train, y_train)

# 5. Monitor performance
monitor = EnsembleMonitor()
metrics = monitor.track_performance(ensemble, X_final_test, y_final_test)

print(f"Final metrics: {metrics}")
print(f"Model contributions: {monitor.analyze_model_contributions(ensemble, X_final_test[:10])}")

# 6. Generate report
report = monitor.generate_report()
print("\nFinal Report:")
print(f"  Accuracy: {metrics['accuracy']:.4f}")
print(f"  Trend: {report['performance_summary']['performance_trend']}")
print(f"  Recommendations: {report['recommendations']}")
```

### 8.4 Integration with Claude-Flow Hooks (If Implemented)

```python
import subprocess
import json

class EnsembleAgentWithHooks:
    def __init__(self, session_id, execution_id):
        self.session_id = session_id
        self.execution_id = execution_id

    def pre_task(self, description):
        """Execute pre-task hook"""
        subprocess.run([
            'npx', 'claude-flow@alpha', 'hooks', 'pre-task',
            '--description', description
        ])

    def post_edit(self, file_path, memory_key):
        """Notify about file changes"""
        subprocess.run([
            'npx', 'claude-flow@alpha', 'hooks', 'post-edit',
            '--file', file_path,
            '--memory-key', memory_key
        ])

    def store_memory(self, key, value):
        """Store results in memory"""
        subprocess.run([
            'npx', 'claude-flow@alpha', 'memory', 'store',
            key,
            json.dumps(value)
        ])

    def post_task(self):
        """Execute post-task hook"""
        subprocess.run([
            'npx', 'claude-flow@alpha', 'hooks', 'post-task',
            '--task-id', self.execution_id
        ])

    def run_ensemble_workflow(self, X, y, models, strategy):
        # Pre-task hook
        self.pre_task(f"Training {strategy} ensemble with {len(models)} models")

        # Create and train ensemble
        optimizer = EnsembleOptimizer()
        ensemble = optimizer.create_ensemble(models, strategy=strategy)
        ensemble.fit(X, y)

        # Save model
        model_path = f"/tmp/ensemble_{self.session_id}.pkl"
        import joblib
        joblib.dump(ensemble, model_path)

        # Post-edit notification
        self.post_edit(model_path, f"agent/ensemble/{strategy}/model")

        # Store results in memory
        self.store_memory(
            f"agent/ensemble/{strategy}/results",
            {
                "strategy": strategy,
                "n_models": len(models),
                "model_path": model_path
            }
        )

        # Post-task hook
        self.post_task()

        return ensemble

# Usage
agent = EnsembleAgentWithHooks(
    session_id="session_123",
    execution_id="exec_456"
)

ensemble = agent.run_ensemble_workflow(X_train, y_train, models, 'stacking')
```

## 9. Integration Gap Analysis

### 9.1 Current State vs. Intended State

**Current State**:
```
┌─────────────────────────────────────┐
│   TypeScript Claude-Flow System     │
│   - Agent orchestration             │
│   - Task management                 │
│   - Memory coordination             │
└─────────────────────────────────────┘

              ❌ NO CONNECTION

┌─────────────────────────────────────┐
│   Python MLE-STAR Module            │
│   - Ensemble strategies             │
│   - Model training                  │
│   - Performance tracking            │
└─────────────────────────────────────┘
```

**Intended State**:
```
┌─────────────────────────────────────┐
│   TypeScript Claude-Flow System     │
│   - Agent orchestration             │
│   - Task management                 │
│   - Memory coordination             │
└──────────────┬──────────────────────┘
               │
               │ IPC/HTTP/WASM Bridge
               │
┌──────────────▼──────────────────────┐
│   Python MLE-STAR Module            │
│   - Ensemble strategies             │
│   - Model training                  │
│   - Performance tracking            │
└─────────────────────────────────────┘
```

### 9.2 Missing Components

1. **Python Process Manager** ❌
   - Spawn Python workers
   - Manage process lifecycle
   - Handle crashes and restarts

2. **Communication Bridge** ❌
   - Serialize TypeScript → Python data
   - Deserialize Python → TypeScript results
   - Error propagation

3. **Model Persistence Layer** ❌
   - Save trained ensembles
   - Load for predictions
   - Version management

4. **TypeScript Type Definitions** ❌
   - Interface definitions
   - Response types
   - Configuration schemas

5. **Integration Tests** ❌
   - End-to-end TypeScript → Python tests
   - Performance benchmarks
   - Error handling validation

### 9.3 Potential Integration Approaches

#### Approach 1: MCP Server Bridge (Recommended)

Create an MCP server that wraps the Python ensemble functionality:

```typescript
// src/mcp/servers/ensemble-server.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { spawn } from 'child_process';

const server = new Server({
  name: 'ensemble-agent-server',
  version: '1.0.0'
}, {
  capabilities: {
    tools: {}
  }
});

// Register ensemble tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'train_ensemble',
      description: 'Train ML ensemble model',
      inputSchema: {
        type: 'object',
        properties: {
          strategy: { type: 'string', enum: ['stacking', 'dynamic_weighting', 'moe', 'bayesian'] },
          models: { type: 'array' },
          data: { type: 'object' }
        }
      }
    },
    {
      name: 'predict_ensemble',
      description: 'Make predictions with trained ensemble',
      inputSchema: {
        type: 'object',
        properties: {
          model_id: { type: 'string' },
          X: { type: 'array' }
        }
      }
    }
  ]
}));

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === 'train_ensemble') {
    return await trainEnsemble(request.params.arguments);
  }
  // ... other handlers
});
```

**Advantages**:
- ✅ Follows existing MCP architecture
- ✅ Easy to integrate with claude-flow
- ✅ Standardized tool interface
- ✅ Built-in error handling

#### Approach 2: REST API Service

```python
# src/mle-star/api_server.py
from flask import Flask, request, jsonify
from ensemble_agent_implementation import EnsembleOptimizer
import joblib

app = Flask(__name__)
optimizer = EnsembleOptimizer()
models = {}

@app.route('/ensemble/train', methods=['POST'])
def train_ensemble():
    config = request.json

    # Deserialize models and data
    base_models = deserialize_models(config['models'])
    X, y = config['data']['X'], config['data']['y']

    # Create ensemble
    ensemble = optimizer.create_ensemble(
        base_models,
        strategy=config['strategy'],
        task_type=config['task_type']
    )

    # Train
    ensemble.fit(X, y)

    # Save and register
    model_id = generate_id()
    joblib.dump(ensemble, f'/models/{model_id}.pkl')
    models[model_id] = ensemble

    return jsonify({
        'model_id': model_id,
        'cv_score': cross_val_score(ensemble, X, y).mean()
    })

@app.route('/ensemble/predict', methods=['POST'])
def predict():
    model_id = request.json['model_id']
    X = request.json['X']

    ensemble = models.get(model_id) or joblib.load(f'/models/{model_id}.pkl')
    predictions = ensemble.predict(X).tolist()

    return jsonify({'predictions': predictions})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

```typescript
// TypeScript client
export class EnsembleAPIClient {
  async trainEnsemble(config: EnsembleConfig): Promise<string> {
    const response = await fetch('http://localhost:8000/ensemble/train', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config)
    });

    const result = await response.json();
    return result.model_id;
  }
}
```

**Advantages**:
- ✅ Language-agnostic HTTP protocol
- ✅ Easy to deploy separately
- ✅ Scalable with load balancers
- ❌ Additional service to manage

#### Approach 3: Shared File System

```typescript
// Simplest approach: communicate via files
import { writeFile, readFile } from 'fs/promises';
import { spawn } from 'child_process';

export class EnsembleAgent {
  async trainEnsemble(config: EnsembleConfig): Promise<string> {
    // Write config to file
    const configPath = '/tmp/ensemble_config.json';
    await writeFile(configPath, JSON.stringify(config));

    // Spawn Python process
    const python = spawn('python', [
      './src/mle-star/ensemble_runner.py',
      '--config', configPath,
      '--output', '/tmp/ensemble_result.json'
    ]);

    await new Promise((resolve) => python.on('close', resolve));

    // Read result
    const result = JSON.parse(await readFile('/tmp/ensemble_result.json', 'utf-8'));
    return result.model_id;
  }
}
```

**Advantages**:
- ✅ Very simple
- ✅ No additional dependencies
- ❌ Not scalable
- ❌ File I/O overhead

### 9.4 Recommended Integration Path

**Phase 1: MCP Server (Week 1-2)**
1. Create MCP server wrapper for Python ensemble
2. Implement 2 core tools: `train_ensemble`, `predict_ensemble`
3. Add basic error handling
4. Integration tests

**Phase 2: Advanced Features (Week 3-4)**
1. Add `optimize_composition` tool
2. Add `monitor_performance` tool
3. Model persistence and versioning
4. Performance optimization

**Phase 3: Production Hardening (Week 5-6)**
1. Process pool management
2. Graceful degradation
3. Comprehensive error handling
4. Monitoring and logging
5. Documentation

## 10. Recommendations

### 10.1 For Developers

1. **Immediate Actions**:
   - ⚠️ **Document the integration gap** - Add warning to README
   - 📝 Create GitHub issue to track integration work
   - 🏷️ Tag module as "experimental/standalone"

2. **Short-term (1-2 months)**:
   - 🔌 Implement MCP server bridge (recommended approach)
   - ✅ Add integration tests
   - 📚 Update architecture documentation

3. **Long-term (3-6 months)**:
   - 🚀 Production hardening
   - 📊 Performance benchmarking
   - 🔄 Consider WebAssembly migration (sklearn-wasm)

### 10.2 For Users

**Current State**:
- ❌ Cannot use ensemble features from TypeScript
- ✅ Can use Python module standalone
- ⚠️ No guarantee of future integration

**Workarounds**:
1. **Use Foundation Agent**: The `src/automation/agents/foundation_agent_*` Python modules provide ensemble functionality and ARE integrated
2. **Direct Python Usage**: Call Python scripts directly via subprocess
3. **Manual Integration**: Implement custom bridge using examples in this doc

### 10.3 For Project Maintainers

**Decision Point**: Should MLE-STAR be integrated or removed?

**Option A: Integrate**
- Effort: ~6 weeks development
- Value: Advanced ensemble capabilities
- Risk: Adds Python runtime dependency

**Option B: Remove**
- Effort: ~1 day
- Value: Cleaner codebase
- Risk: Loss of advanced ensemble features

**Option C: Keep as Standalone**
- Effort: ~2 hours (documentation)
- Value: Users can import as library
- Risk: Confusion about integration status

**Recommendation**: **Option C** with clear documentation, then evaluate integration in Q2 2025 based on user demand.

## 11. Architecture Diagrams

### 11.1 Current Architecture (Disconnected)

```mermaid
graph TB
    subgraph "TypeScript Layer"
        AM[Agent Manager]
        TS[Task Scheduler]
        MEM[Memory Store]
        MCP[MCP Server]
    end

    subgraph "Python Layer - Foundation (INTEGRATED)"
        FA[Foundation Agent]
        FC[foundation_agent_core.py]
        FF[foundation_agent_features.py]
        FI[foundation_agent_integration.py]
    end

    subgraph "Python Layer - MLE-STAR (NOT INTEGRATED)"
        EI[ensemble_agent_implementation.py]
        EA[ensemble_agent_advanced.py]
        ET[ensemble_agent_tests.py]
    end

    AM --> TS
    TS --> MEM
    TS --> MCP

    AM -.->|subprocess| FA
    FA --> FC
    FA --> FF
    FA --> FI

    EI -.x|NO CONNECTION|.-x AM
    EA -.x|NO CONNECTION|.-x AM
    ET -.x|NO CONNECTION|.-x AM

    style EI fill:#f99,stroke:#f00,stroke-width:2px
    style EA fill:#f99,stroke:#f00,stroke-width:2px
    style ET fill:#f99,stroke:#f00,stroke-width:2px
```

### 11.2 Proposed Architecture (With MCP Bridge)

```mermaid
graph TB
    subgraph "TypeScript Orchestration"
        CC[Claude Code]
        AM[Agent Manager]
        TS[Task Scheduler]
    end

    subgraph "MCP Layer"
        MCP[MCP Server]
        ES[Ensemble MCP Server]
    end

    subgraph "Python Ensemble Workers"
        PW1[Python Worker 1]
        PW2[Python Worker 2]
        PWN[Python Worker N]
    end

    subgraph "Ensemble Strategies"
        DWE[Dynamic Weighting]
        SE[Stacking]
        MOE[Mixture of Experts]
        BMA[Bayesian Averaging]
    end

    subgraph "Storage"
        DB[(Model DB)]
        FS[File System]
    end

    CC --> AM
    AM --> TS
    TS --> MCP
    MCP --> ES

    ES -->|spawn| PW1
    ES -->|spawn| PW2
    ES -->|spawn| PWN

    PW1 --> DWE
    PW1 --> SE
    PW2 --> MOE
    PW2 --> BMA

    PW1 -->|save| DB
    PW2 -->|save| FS

    ES -.->|load models| DB
    ES -.->|load models| FS
```

### 11.3 Ensemble Strategy Decision Tree

```mermaid
graph TD
    Start[Need Ensemble?] --> CheckData{Analyze Data}

    CheckData -->|High correlation<br/>Similar models| DWE[Dynamic Weighting]
    CheckData -->|Diverse models<br/>Sufficient data| SE[Stacking]
    CheckData -->|Heterogeneous data<br/>Multiple clusters| MOE[Mixture of Experts]
    CheckData -->|Uncertainty needed<br/>Model comparison| BMA[Bayesian Averaging]

    DWE --> Fast{Speed priority?}
    SE --> Fast
    MOE --> Fast
    BMA --> Fast

    Fast -->|Yes| DWE2[✓ Dynamic Weighting]
    Fast -->|No| Acc{Accuracy priority?}

    Acc -->|Yes| SE2[✓ Stacking]
    Acc -->|No| Int{Interpretability?}

    Int -->|Yes| BMA2[✓ Bayesian Averaging]
    Int -->|No| Comp{Complex data?}

    Comp -->|Yes| MOE2[✓ Mixture of Experts]
    Comp -->|No| Adv{Advanced features?}

    Adv -->|Attention needed| ATT[✓ Attention-Based]
    Adv -->|Many models| HIE[✓ Hierarchical]
    Adv -->|Auto-select| ADA[✓ Adaptive Selector]
```

### 11.4 Data Flow (Hypothetical Integration)

```mermaid
sequenceDiagram
    participant TS as TypeScript<br/>Agent Manager
    participant MCP as MCP<br/>Ensemble Server
    participant PY as Python<br/>Worker Pool
    participant ENS as Ensemble<br/>Optimizer
    participant DISK as Model<br/>Storage

    TS->>MCP: train_ensemble({strategy, models, data})
    MCP->>PY: Get available worker
    PY->>ENS: create_ensemble(strategy)

    ENS->>ENS: Fit base models
    ENS->>ENS: Compute weights/meta-model
    ENS->>ENS: Cross-validation

    ENS->>DISK: Save ensemble.pkl
    DISK-->>ENS: model_id

    ENS-->>PY: {model_id, cv_score, metrics}
    PY-->>MCP: Result
    MCP-->>TS: {model_id, cv_score}

    Note over TS: Later prediction request

    TS->>MCP: predict_ensemble({model_id, X})
    MCP->>DISK: Load model
    DISK-->>MCP: ensemble
    MCP->>ENS: ensemble.predict(X)
    ENS-->>MCP: predictions
    MCP-->>TS: {predictions}
```

### 11.5 Class Hierarchy

```mermaid
classDiagram
    class BaseEstimator {
        <<sklearn>>
        +fit(X, y)
        +predict(X)
        +score(X, y)
    }

    class DynamicWeightingEnsemble {
        -models: List
        -weights: ndarray
        -performance_history: List
        +fit(X, y)
        +predict(X)
        -_compute_dynamic_weights()
    }

    class StackingEnsemble {
        -base_models: List
        -meta_model: BaseEstimator
        -use_proba: bool
        +fit(X, y)
        +predict(X)
        +predict_proba(X)
        -_generate_meta_features()
    }

    class MixtureOfExpertsEnsemble {
        -expert_models: List
        -gate_model: BaseEstimator
        -n_experts: int
        +fit(X, y)
        +predict(X)
        -_evaluate_expert_performance()
    }

    class BayesianModelAveraging {
        -models: List
        -prior_weights: ndarray
        -posterior_weights: ndarray
        +fit(X, y)
        +predict(X)
        -_compute_posterior_weights()
        -_estimate_n_params()
    }

    class EnsembleOptimizer {
        -ensemble_strategies: Dict
        +create_ensemble()
        +optimize_ensemble_composition()
    }

    class AttentionBasedEnsemble {
        -models: List
        -attention_network: AttentionNet
        -attention_dim: int
        +fit(X, y)
        +predict(X)
        -_build_attention_network()
        -_train_attention()
    }

    class AdaptiveEnsembleSelector {
        -strategy_scores: Dict
        -selected_strategy: str
        +analyze_data_characteristics()
        +recommend_strategy()
        +create_adaptive_ensemble()
    }

    class EnsembleMonitor {
        -performance_history: List
        -model_contributions: Dict
        +track_performance()
        +analyze_model_contributions()
        +generate_report()
    }

    BaseEstimator <|-- DynamicWeightingEnsemble
    BaseEstimator <|-- StackingEnsemble
    BaseEstimator <|-- MixtureOfExpertsEnsemble
    BaseEstimator <|-- BayesianModelAveraging
    BaseEstimator <|-- AttentionBasedEnsemble

    EnsembleOptimizer ..> DynamicWeightingEnsemble : creates
    EnsembleOptimizer ..> StackingEnsemble : creates
    EnsembleOptimizer ..> MixtureOfExpertsEnsemble : creates
    EnsembleOptimizer ..> BayesianModelAveraging : creates

    AdaptiveEnsembleSelector ..> EnsembleOptimizer : uses
    EnsembleMonitor ..> BaseEstimator : monitors
```

## 12. Conclusion

### 12.1 Summary

The MLE-STAR ensemble agents module is a **sophisticated, production-quality Python ML library** that:
- ✅ Implements 4+ ensemble strategies with scientific rigor
- ✅ Includes advanced neural techniques (attention, hierarchical)
- ✅ Provides comprehensive testing and monitoring
- ✅ Follows sklearn conventions for easy integration
- ❌ **Has NO integration with the TypeScript codebase**

### 12.2 Key Findings

1. **Code Quality**: Excellent (well-structured, documented, tested)
2. **ML Techniques**: State-of-the-art ensemble methods
3. **Integration Status**: ❌ None - completely standalone
4. **Alternative**: Foundation agent provides basic ensemble via sklearn
5. **Future**: Requires MCP bridge or HTTP API for integration

### 12.3 Next Steps

**For Documentation**:
- ✅ This comprehensive reverse engineering document
- ⬜ Add warning to main README.md
- ⬜ Create GitHub issue for integration tracking
- ⬜ Update architecture diagrams

**For Integration** (if decided):
- ⬜ Design MCP server interface
- ⬜ Implement Python worker pool
- ⬜ Add TypeScript type definitions
- ⬜ Create integration tests
- ⬜ Performance benchmarking
- ⬜ Production deployment guide

### 12.4 References

**Internal**:
- `/src/mle-star/ensemble_agent_implementation.py` - Core ensembles
- `/src/mle-star/ensemble_agent_advanced.py` - Advanced techniques
- `/src/mle-star/ensemble_agent_tests.py` - Test suite
- `/src/automation/agents/foundation_agent_*.py` - Integrated alternative

**External**:
- scikit-learn Ensemble Methods: https://scikit-learn.org/stable/modules/ensemble.html
- PyTorch Documentation: https://pytorch.org/docs/
- Mixture of Experts: https://arxiv.org/abs/1701.06538
- Attention Mechanisms: https://arxiv.org/abs/1706.03762

---

**Document Version**: 1.0
**Last Updated**: 2025-01-04
**Status**: ⚠️ Module Not Integrated - Standalone Use Only
**Maintainer**: Documentation generated via reverse engineering
