# Documentação de Algoritmos ML - Sistema de Análise de Estoque

## 🔗 **INTEGRAÇÃO CLASSIFICAÇÃO ↔ FORECASTING**

**A INOVAÇÃO CENTRAL deste sistema:** Os algoritmos não trabalham independentemente - **a classificação é o cérebro que otimiza o forecasting**!

### **📋 Como Funciona a Integração:**
- **🔍 DBSCAN**: Detecta outliers → **TimesFM para produtos atípicos**
- **🎯 K-means**: Define clusters ABC/XYZ → **Estratégia específica por categoria**
- **🤖 XGBoost**: Router inteligente → **Aprende melhor método por produto**

### **📊 Exemplo Prático:**
```
Produto ABC123 → DBSCAN: Normal → K-means: A_X → XGBoost: "Use SARIMA" → Result: Forecast preciso para produto crítico
Produto XYZ789 → DBSCAN: Outlier → Router: "Use TimesFM" → Result: Forecast robusto para padrão atípico
```

**📖 Documentação Completa:** [Integração Detalhada](./classification_forecasting_integration.md)

---

## 📚 **Índice de Algoritmos Implementados**

### **🧠 Abordagem Tripla Atual**
- [DBSCAN - Descoberta de Padrões](./dbscan_discovery.md)
- [K-means - Estruturação de Negócio](./kmeans_structure.md)
- [SVM - Classificação Automática](./svm_classification.md)

### **📈 Algoritmos de Previsão (IMPLEMENTADOS)**
- [SARIMA - Previsão Sazonal](./forecasting_algorithms.md#sarima-seasonal-arima)
- [ARIMA - Séries Temporais](./forecasting_algorithms.md#arima-autoregressive-integrated-moving-average)
- [Prophet - Facebook Prophet](./forecasting_algorithms.md#prophet-facebook-prophet)
- [Holt-Winters - Suavização Exponencial](./forecasting_algorithms.md#holt-winters-exponential-smoothing)
- [Regressão Robusta - Resistente a Outliers](./forecasting_algorithms.md#regressão-robusta-huber-regressor)

### **🚀 Foundation Models (REVOLUÇÃO 2024-2025)**
- [TimesFM - Google Foundation Model](./foundation_models_guide.md#timesfm-google-foundation-model)
- [TimeGPT - Nixtla Commercial API](./foundation_models_guide.md#timegpt-nixtla-commercial-foundation-model)
- [Model Router Framework](./model_selection_guide.md#intelligent-model-routing)
- [Zero-Shot Forecasting Guide](./foundation_models_guide.md#zero-shot-forecasting)

### **📊 Demanda Intermitente (ESPECIALIZAÇÃO)**
- [Croston's Method - Método Clássico](./intermittent_methods_guide.md#crostons-method)
- [TSB Method - Bias-Corrected](./intermittent_methods_guide.md#tsb-method)
- [ADIDA - Aggregate-Disaggregate](./intermittent_methods_guide.md#adida)
- [Intermittent Detection System](./intermittent_methods_guide.md#sistema-de-detecção-automática)

### **🔬 Transformers Avançados (ESTADO DA ARTE)**
- [PatchTST - Patching Transformer](./transformer_architectures.md#patchtst)
- [N-HiTS - Hierarchical Interpolation](./transformer_architectures.md#n-hits)
- [Ensemble Methods - Model Combination](./transformer_architectures.md#ensemble-intelligence)

### **🏗️ Infraestrutura Enterprise (NOVO)**
- [Ativos Estratégicos - PostgreSQL, Redis, Celery](./infrastructure_strategic_assets.md) **← APROVEITAMENTO ATIVOS**
- [Hadoop DW ↔ PostgreSQL ML - Tempo Real](./hadoop_postgresql_realtime_integration.md) **← INTEGRAÇÃO CORPORATIVA**
- [Ambiente de Produção/Staging - VM](./production_environment_vm.md) **← AMBIENTE PRODUÇÃO**
- [Backup Tri-Cloud + Deployment SuperPower](./backup_deployment_infrastructure.md) **← BACKUP & DEPLOY** ⭐

### **🚀 Algoritmos Avançados (Roadmap)**
- [XGBoost - Classificação Superior](./xgboost_advanced.md)
- [Isolation Forest - Detecção de Anomalias](./isolation_forest_anomalies.md)
- [Gaussian Mixture Models - Clustering Flexível](./gmm_flexible.md)
- [HDBSCAN - Clustering Hierárquico](./hdbscan_hierarchical.md)

### **🏪 Algoritmos Especializados para Estoque**
- [Time Series Clustering - Padrões Sazonais](./timeseries_seasonal.md)
- [Market Basket Analysis - Produtos Relacionados](./market_basket.md)
- [LSTM Forecasting - Previsão de Demanda](./lstm_forecasting.md)

### **🤖 Algoritmos de IA Avançada**
- [Graph Neural Networks - Relacionamentos Complexos](./graph_neural_networks.md)
- [Ensemble Methods - Combinação de Modelos](./ensemble_methods.md)
- [Deep Learning Pipeline - Arquiteturas Neurais](./deep_learning_pipeline.md)

### **🎯 Algoritmos de Otimização Dinâmica**
- [Multi-Armed Bandit - Otimização em Tempo Real](./multi_armed_bandit.md)
- [Reinforcement Learning - Agente Inteligente](./reinforcement_learning.md)
- [AutoML - Seleção Automática de Algoritmos](./automl_pipeline.md)

## 🎯 **Guia de Seleção de Algoritmos**

### **Por Objetivo de Negócio**

| **Objetivo** | **Algoritmo Principal** | **Algoritmo Secundário** | **Métricas Foco** |
|-------------|------------------------|--------------------------|------------------|
| **Reduzir Custos** | K-means (estruturação) | DBSCAN (outliers) | DIO, Custo Manutenção, Valor Estoque |
| **Acelerar Giro** | DBSCAN (descoberta) | Isolation Forest | Taxa Giro, DIO, Frequência Vendas |
| **Melhorar Atendimento** | K-means (4 categorias) | GMM (probabilidades) | Nível Atendimento, Coef. Variação |
| **Detectar Anomalias** | Isolation Forest | DBSCAN outliers | Todas as métricas |
| **Prever Demanda Sazonal** | SARIMA | Prophet | Séries temporais, Sazonalidade |
| **Prever Demanda Robusta** | Prophet | Holt-Winters | Dados com outliers, Missing values |
| **Planejamento Rápido** | Holt-Winters | ARIMA | Previsões rápidas, Sazonalidade moderada |
| **Zero-Shot Universal** | TimesFM | TimeGPT | Novos produtos, Sem dados históricos |
| **Demanda Intermitente** | TSB Method | Croston | Spare parts, Slow-moving items |
| **Long-Horizon Advanced** | PatchTST | N-HiTS | Previsões 6+ meses, Transformers |

### **Por Tipo de Análise**

| **Tipo de Análise** | **Algoritmo Recomendado** | **Quando Usar** |
|--------------------|-----------------------------|-----------------|
| **Exploratória** | DBSCAN | Primeira análise, descobrir padrões |
| **Estruturada** | K-means | Categorias específicas para gestão |
| **Preditiva (Classificação)** | XGBoost/SVM | Classificar novos produtos |
| **Preditiva (Forecasting)** | TimesFM/SARIMA/Prophet | Prever demanda futura |
| **Zero-Shot Forecasting** | TimesFM/TimeGPT | Novos produtos sem histórico |
| **Intermittent Forecasting** | TSB/Croston | Demanda esparsa, spare parts |
| **Long-Horizon Forecasting** | PatchTST/N-HiTS | Previsões > 6 meses |
| **Anomalias** | Isolation Forest | Identificar produtos problemáticos |
| **Hierárquica** | HDBSCAN | Relacionamentos complexos |
| **Temporal (Clustering)** | Time Series Clustering | Padrões sazonais |
| **Ensemble Intelligence** | Model Router + Multiple | Combinação automática otimizada |

## 📊 **Comparação de Performance**

### **Métricas Técnicas**

### **Algoritmos de Classificação e Clustering**

| **Algoritmo** | **Velocidade** | **Precisão** | **Interpretabilidade** | **Configuração** |
|---------------|----------------|--------------|----------------------|-----------------|
| **DBSCAN** | 🟡 Média | 🟢 Alta | 🟡 Média | 🔴 Complexa |
| **K-means** | 🟢 Rápida | 🟢 Alta | 🟢 Fácil | 🟢 Simples |
| **SVM** | 🟡 Média | 🟢 Alta | 🔴 Baixa | 🟡 Média |
| **XGBoost** | 🟢 Rápida | 🟢 Muito Alta | 🟢 Fácil | 🟡 Média |
| **Isolation Forest** | 🟢 Muito Rápida | 🟢 Alta | 🟢 Fácil | 🟢 Simples |

### **Algoritmos de Previsão Clássicos**

| **Algoritmo** | **Velocidade** | **Precisão Sazonal** | **Robustez** | **Configuração** |
|---------------|----------------|---------------------|--------------|-----------------|
| **SARIMA** | 🔴 Lenta | 🟢 Muito Alta | 🟡 Média | 🔴 Complexa |
| **ARIMA** | 🟡 Média | 🟡 Média | 🟡 Média | 🟡 Média |
| **Prophet** | 🟡 Média | 🟢 Alta | 🟢 Muito Alta | 🟢 Simples |
| **Holt-Winters** | 🟢 Muito Rápida | 🟢 Alta | 🟡 Média | 🟢 Simples |
| **Regressão Robusta** | 🟢 Rápida | 🟡 Média | 🟢 Muito Alta | 🟡 Média |

### **Foundation Models & Estado da Arte**

| **Algoritmo** | **Zero-Shot** | **Precisão Universal** | **Escalabilidade** | **Custo** |
|---------------|---------------|----------------------|------------------|-----------|
| **TimesFM** | 🟢 Excelente | 🟢 Muito Alta | 🟢 Infinita | 🟢 Gratuito |
| **TimeGPT** | 🟢 Excelente | 🟢 Muito Alta | 🟢 Infinita | 🔴 API Paga |
| **PatchTST** | 🔴 Não | 🟢 Muito Alta | 🟡 Limitada | 🟢 Open Source |
| **N-HiTS** | 🔴 Não | 🟢 Alta | 🟢 Boa | 🟢 Open Source |

### **Métodos para Demanda Intermitente**

| **Algoritmo** | **Intermittent Accuracy** | **Bias** | **Implementação** | **Indústria** |
|---------------|----------------------------|----------|------------------|---------------|
| **Croston** | 🟡 Média | 🔴 Alto Bias | 🟢 Simples | 🟢 Padrão |
| **TSB** | 🟢 Alta | 🟢 Bias-Free | 🟢 Simples | 🟡 Crescente |
| **ADIDA** | 🟡 Média | 🟡 Médio | 🟡 Complexa | 🟡 Específica |

### **Adequação por Contexto de Estoque - Algoritmos Base**

| **Algoritmo** | **ABC Analysis** | **Produtos Problemáticos** | **Novos Produtos** | **Sazonalidade** |
|---------------|------------------|----------------------------|-------------------|-----------------|
| **DBSCAN** | 🟡 Médio | 🟢 Excelente | 🔴 Não | 🟡 Médio |
| **K-means** | 🟢 Excelente | 🔴 Ruim | 🔴 Não | 🟡 Médio |
| **SVM** | 🟡 Médio | 🟡 Médio | 🟢 Excelente | 🔴 Ruim |
| **XGBoost** | 🟢 Excelente | 🟢 Excelente | 🟢 Excelente | 🟡 Médio |
| **Isolation Forest** | 🔴 Ruim | 🟢 Excelente | 🔴 Não | 🔴 Ruim |

### **Adequação por Contexto - Algoritmos Especializados**

| **Algoritmo** | **Previsão Demanda** | **Produtos Relacionados** | **Otimização Políticas** | **Relacionamentos Complexos** |
|---------------|---------------------|----------------------------|-------------------------|------------------------------|
| **LSTM** | 🟢 **Excelente** | 🔴 Não | 🔴 Não | 🟡 Médio |
| **Graph Neural Networks** | 🟡 Médio | 🟢 **Excelente** | 🟡 Médio | 🟢 **Excelente** |
| **Multi-Armed Bandit** | 🔴 Não | 🔴 Não | 🟢 **Excelente** | 🔴 Não |
| **Market Basket** | 🔴 Não | 🟢 **Excelente** | 🟡 Médio | 🟡 Médio |
| **Time Series Clustering** | 🟢 **Excelente** | 🔴 Não | 🔴 Não | 🔴 Não |
| **Reinforcement Learning** | 🟡 Médio | 🟡 Médio | 🟢 **Excelente** | 🟡 Médio |

## 🛠️ **Padrões de Implementação**

### **Estrutura Base para Todos Algoritmos**
```python
class AlgorithmBase:
    def __init__(self, context: AnalysisContext):
        self.context = context
        self.parameters = self._load_default_parameters()
        
    def _load_default_parameters(self) -> Dict:
        # Parâmetros específicos por contexto
        pass
        
    def fit(self, data: pd.DataFrame) -> Dict:
        # Implementação específica
        pass
        
    def explain_parameters(self) -> Dict:
        # Explicação de cada parâmetro
        pass
        
    def get_business_insights(self) -> List[str]:
        # Tradução para linguagem de negócio
        pass
```

### **Interface de Transparência**
```python
def show_algorithm_config(algorithm_name: str, parameters: Dict):
    st.markdown(f"#### 🔧 **{algorithm_name} - Configuração**")
    
    for param, value in parameters.items():
        explanation = get_parameter_explanation(algorithm_name, param)
        impact = get_parameter_impact(algorithm_name, param, value)
        
        st.write(f"**{param}**: {value}")
        st.info(f"📝 {explanation}")
        st.info(f"📊 {impact}")
```

## 🎯 **Casos de Uso Específicos**

### **1. Análise ABC Inteligente**
- **Algoritmo**: K-means (K=3)
- **Features**: valor_vendas, margem_lucro, frequencia_vendas
- **Output**: Classes A, B, C balanceadas
- **Vantagem**: Distribuição automática vs manual

### **2. Detecção de Produtos Obsoletos**
- **Algoritmo**: Isolation Forest + DBSCAN
- **Features**: taxa_giro, dio, ultima_venda
- **Output**: Score de anomalia + classificação
- **Vantagem**: Foco 100% em produtos problemáticos

### **3. Classificação de Novos Produtos**
- **Algoritmo**: XGBoost (futuro) / SVM (atual)
- **Features**: todas as métricas disponíveis
- **Output**: Categoria + probabilidade + explicação
- **Vantagem**: Automação completa do processo

### **4. Padrões Sazonais**
- **Algoritmo**: Time Series Clustering (futuro)
- **Features**: séries temporais de vendas
- **Output**: Grupos sazonais + previsões
- **Vantagem**: Estratégias de estoque específicas

## 📈 **Roadmap de Implementação**

### **Fase 1: Consolidação (Atual)**
- [x] DBSCAN contextual implementado
- [x] K-means com auto-determinação de K
- [x] SVM com transparência de parâmetros
- [x] Interface de configuração

### **Fase 2: Algoritmos Superiores (Próximos 2 meses)**
- [ ] XGBoost substitui SVM
- [ ] Isolation Forest para anomalias
- [ ] Feature importance e SHAP
- [ ] Comparação A/B de algoritmos

### **Fase 3: Clustering Avançado (3-4 meses)**
- [ ] Gaussian Mixture Models
- [ ] HDBSCAN hierárquico
- [ ] Validação com especialistas
- [ ] Otimização de hiperparâmetros

### **Fase 4: Especialização para Estoque (6-9 meses)**
- [ ] Time Series Clustering para padrões sazonais
- [ ] Market Basket Analysis para produtos relacionados
- [ ] Feature Engineering avançado

### **Fase 5: IA Avançada (9-12 meses)**
- [ ] LSTM Forecasting para previsão precisa de demanda
- [ ] Graph Neural Networks para relacionamentos complexos
- [ ] Ensemble Methods para combinação inteligente

### **Fase 6: Otimização Dinâmica (12+ meses)**
- [ ] Multi-Armed Bandit para otimização em tempo real
- [ ] Reinforcement Learning para agente inteligente
- [ ] AutoML pipeline completamente autônomo

## 🔧 **Configuração e Customização**

### **Parâmetros Globais**
```python
GLOBAL_CONFIG = {
    "random_state": 42,  # Reproducibilidade
    "test_size": 0.2,    # Split treino/teste
    "cv_folds": 5,       # Cross-validation
    "outlier_threshold": 0.025,  # Quantis para outliers
    "min_cluster_size": 5,       # Tamanho mínimo de cluster
}
```

### **Contextos Específicos**
Cada contexto (reduzir_custos, acelerar_giro, etc.) tem:
- Métricas prioritárias
- Algoritmos recomendados
- Parâmetros otimizados
- Interpretações de negócio

---

## 📚 **Recursos Adicionais**

- [Guia de Troubleshooting](./troubleshooting.md)
- [Exemplos de Código](./code_examples/)
- [Benchmarks e Comparações](./benchmarks.md)
- [Best Practices](./best_practices.md)

**Esta documentação é atualizada continuamente conforme novos algoritmos são implementados.** 