# Engenharia Contextual - Sistema de Análise de Estoque com ML

## 🎯 **VISÃO GERAL DO PROJETO**

Este projeto implementa análise avançada de estoque usando **Abordagem Tripla Inteligente**:
- **🔍 DBSCAN**: Descoberta de padrões naturais e detecção de outliers
- **🎯 K-means**: Estruturação para necessidades de negócio  
- **🤖 SVM/XGBoost**: Classificação automática de novos produtos

### **Contexto de Domínio**
- **Setor**: Gestão de inventário e estoque
- **Métricas principais**: Taxa de Giro, DIO, Nível de Atendimento, Custo de Manutenção
- **Objetivos**: Reduzir custos, acelerar giro, melhorar atendimento
- **Usuários**: Gestores de compras, analistas de estoque, equipe comercial

## 📋 **REGRAS FUNDAMENTAIS DE DESENVOLVIMENTO**

### **1. Estrutura de Código**
- **Arquivos Python**: Máximo 500 linhas por arquivo
- **Modularização**: Separar algoritmos ML em utils/contextual_clustering.py
- **Interface**: Streamlit em pages/olho_thundera.py
- **Componentes**: Separar visualizações em pages/components/

### **2. Padrões de Machine Learning**
- **Transparência total**: Sempre mostrar parâmetros usados
- **Reproducibilidade**: random_state=42 em todos algoritmos
- **Validação**: Cross-validation obrigatório para classificadores
- **Interpretabilidade**: Explicar impacto dos parâmetros nos resultados

### **3. Algoritmos ML - Ordem de Preferência**

#### **Clustering:**
1. **🔍 DBSCAN**: Para descoberta de padrões + outliers
2. **🎯 K-means**: Para estruturação de categorias de negócio
3. **🔬 HDBSCAN**: Para casos avançados (hierárquico)
4. **📊 Gaussian Mixture**: Para clusters de formas irregulares

#### **Classificação:**
1. **⚡ XGBoost**: Primeira escolha (precisão + interpretabilidade)
2. **🤖 SVM**: Fallback robusto
3. **🌳 Random Forest**: Para alta interpretabilidade
4. **🧠 Neural Networks**: Para padrões muito complexos

#### **Detecção de Anomalias:**
1. **🌲 Isolation Forest**: Especializado e rápido
2. **🔍 DBSCAN outliers**: Como subproduto do clustering
3. **📈 Local Outlier Factor**: Para anomalias locais
4. **🧠 AutoEncoders**: Para padrões complexos

#### **Algoritmos Especializados para Estoque:**
1. **🌀 Time Series Clustering**: Para padrões sazonais
2. **🛒 Market Basket Analysis**: Para produtos relacionados
3. **📈 LSTM Forecasting**: Para previsão precisa de demanda
4. **🕸️ Graph Neural Networks**: Para relacionamentos complexos

#### **Algoritmos de Previsão de Demanda:**
1. **🚀 TimesFM**: Foundation model GRATUITO (IMPLEMENTAR IMEDIATAMENTE - ROI ∞)
2. **📊 SARIMA**: Para produtos com forte sazonalidade
3. **🔮 Prophet**: Robusto para dados problemáticos (Facebook Prophet)
4. **🌊 Holt-Winters**: Rápido para sazonalidade moderada
5. **📈 ARIMA**: Para séries temporais sem sazonalidade
6. **🛡️ Regressão Robusta**: Resistente a outliers
7. **💰 TimeGPT**: API multivariate (APENAS se budget $27k+/3anos aprovado)

#### **Algoritmos para Demanda Intermitente:**
1. **🎯 TSB Method**: Bias-corrected, melhor para spare parts
2. **🔧 Croston's Method**: Método clássico, padrão da indústria
3. **📈 ADIDA**: Aggregate-Disaggregate para casos sazonais
4. **🔍 Intermittent Detector**: Classificação automática ADI/CV²

#### **Transformers Estado da Arte:**
1. **🔬 PatchTST**: SOTA para long-horizon forecasting
2. **⚡ N-HiTS**: Hierarchical + 10x speedup vs outros deep models
3. **🎭 Model Router**: Seleção automática inteligente de algoritmos

#### **Otimização Dinâmica:**
1. **🎰 Multi-Armed Bandit**: Para A/B testing automático
2. **🧠 Reinforcement Learning**: Para agente inteligente
3. **🔄 AutoML Pipeline**: Para seleção automática de algoritmos

#### **🔗 INTEGRAÇÃO CLASSIFICAÇÃO ↔ FORECASTING (OBRIGATÓRIO)**

**REGRA PRINCIPAL:** Classificação não é análise separada - é o **cérebro que decide** qual método de forecasting usar!

**Fluxo de Integração:**
```python
INTEGRATION_RULES = {
    "DBSCAN_TO_FORECASTING": {
        "if_outlier": "TimesFM + validação_humana + confidence_reduzida",
        "if_normal": "usar_kmeans_strategy + confidence_normal"
    },
    "KMEANS_TO_FORECASTING": {
        "A_X": "SARIMA + horizonte_12_meses + confidence_85%",  # Crítico
        "A_Y": "Prophet + horizonte_6_meses + confidence_80%",  # Alto valor
        "A_Z": "TimesFM + horizonte_3_meses + confidence_75%",  # Complexo
        "C_Z": "TSB + horizonte_6_meses + confidence_60%"      # Intermitente
    },
    "XGBOOST_ROUTER": {
        "objetivo": "aprender_melhor_método_por_produto",
        "features": ["dio", "abc_class", "xyz_class", "sazonalidade", "intermittency"],
        "target": "best_forecasting_method_historical",
        "explanation": "sempre_explicar_porque_método_escolhido"
    }
}
```

**Implementação Obrigatória:**
- **Router XGBoost**: Treinar para selecionar método automático
- **Matriz Decisão**: Mapear cluster → estratégia forecasting  
- **Feedback Loop**: Performance forecasting → melhora classificação
- **Explicabilidade**: Sempre explicar por que método foi escolhido

### **4. Aproveitamento de Infraestrutura Enterprise (OBRIGATÓRIO)**

**REGRA PRINCIPAL:** Aproveitar 100% dos ativos estratégicos existentes - **$0 infrastructure cost!**

#### **🏗️ Ativos Estratégicos Disponíveis:**
```python
STRATEGIC_ASSETS = {
    "postgresql": {
        "container": "ims_postgres_staging",
        "status": "healthy",
        "ml_usage": "Data Lake + Model Storage + Performance History",
        "advantage": "2+ anos dados históricos prontos para training"
    },
    "redis": {
        "container": "ims_redis_staging", 
        "status": "healthy",
        "ml_usage": "Model Cache + Feature Store + Results Cache",
        "advantage": "Performance 15-120x já implementada"
    },
    "celery": {
        "container": "ims_celery_worker_staging",
        "status": "healthy", 
        "ml_usage": "Async ML Training + Background Processing",
        "advantage": "Scaling horizontal + Non-blocking UI"
    },
    "django_api": {
        "container": "ims_django_staging",
        "status": "healthy",
        "ml_usage": "ML Endpoints + Model Serving",
        "advantage": "API centralizada + ORM pronto"
    },
    "keycloak": {
        "container": "ims_keycloak_staging", 
        "status": "healthy",
        "ml_usage": "Secure ML Access + User-based permissions",
        "advantage": "Enterprise security sem setup"
    }
}
```

#### **💡 Regras de Aproveitamento:**
- **PostgreSQL**: Sempre usar para datasets, model storage, performance tracking
- **Redis**: Cache obrigatório para modelos, features, results (db=1 dedicado ML)
- **Celery**: Training > 30s deve ser assíncrono com progress tracking
- **Django**: Todos endpoints ML via API existente + Keycloak integration
- **Development**: Usar `./run-development.sh` para ambiente completo

### **5. Interface de Usuário - Streamlit**
- **Transparência**: Sempre mostrar parâmetros em expanders
- **Configurabilidade**: Permitir ajuste de hiperparâmetros
- **Feedback visual**: Explicar impacto dos parâmetros
- **Progressão clara**: Barra de progresso com etapas nomeadas
- **🆕 Cache Integration**: Usar Redis para responses instantâneas
- **🆕 Async Tasks**: Integrar com Celery para operações pesadas

### **6. Estrutura de Dados**

#### **📊 Dados de Estoque (Existentes no PostgreSQL):**
- **Métricas obrigatórias**: `taxa_giro`, `dio`, `nivel_atendimento`, `custo_manutencao`, `valor_estoque`
- **Tratamento de outliers**: Quantis 2.5% e 97.5% ou capping no 95º percentil
- **Missing values**: Preenchimento com mediana
- **Normalização**: StandardScaler obrigatório para ML

#### **🧠 Estrutura ML (Aproveitar PostgreSQL existente):**
```python
# Tabelas ML a criar no PostgreSQL existente
ML_TABLES_STRUCTURE = {
    "ml_model_results": {
        "product_code": "CharField(50)",
        "model_name": "CharField(100)", 
        "classification_result": "JSONField()",
        "forecast_result": "JSONField()",
        "accuracy_score": "FloatField()",
        "created_at": "DateTimeField(auto_now_add=True)"
    },
    "ml_training_datasets": {
        "dataset_id": "AutoField(primary_key=True)",
        "dataset_name": "CharField(100)",
        "data": "JSONField()",
        "features_used": "JSONField()",
        "created_at": "DateTimeField(auto_now_add=True)"
    },
    "ml_performance_history": {
        "model_name": "CharField(100)",
        "method_used": "CharField(50)",
        "product_category": "CharField(50)",
        "accuracy_achieved": "FloatField()",
        "execution_time": "FloatField()",
        "created_at": "DateTimeField(auto_now_add=True)"
    }
}
```

#### **⚡ Cache Structure (Redis db=1 dedicado ML):**
```python
REDIS_ML_KEYS = {
    "ml:classification:{product_code}": "Resultado classificação cached",
    "ml:forecasting:{product_code}:{method}": "Resultado forecasting cached", 
    "features:{product_code}": "Features calculadas cached",
    "model:{model_name}": "Modelo treinado serializado",
    "performance:{model_name}": "Métricas de performance"
}
```

### **7. Contextos de Análise**
```python
ObjetivoAnalise = {
    "REDUZIR_CUSTOS": {
        "métricas_foco": ["dio", "custo_manutencao", "valor_estoque"],
        "algoritmo_preferido": "dbscan + kmeans",
        "categorias_resultado": ["Alto Potencial", "Médio Potencial", "Baixo Potencial", "Manutenção"]
    },
    "ACELERAR_GIRO": {
        "métricas_foco": ["taxa_giro", "dio", "frequencia_vendas"],
        "algoritmo_preferido": "dbscan",
        "foco_especial": "detecção_produtos_estagnados"
    },
    "MELHORAR_ATENDIMENTO": {
        "métricas_foco": ["nivel_atendimento", "coef_variacao_quantidade", "frequencia_vendas"],
        "categorias_fixas": 4,
        "labels": ["Excelente", "Bom", "Regular", "Crítico"]
    }
}
```

## 🔧 **PADRÕES DE IMPLEMENTAÇÃO**

### **1. Estrutura de Classe Principal**
```python
class HybridClusteringEngine:
    def __init__(self):
        self.phase1_results = None  # DBSCAN
        self.phase2_results = None  # K-means
        self.phase3_model = None    # SVM/XGBoost
        
    def execute_hybrid_analysis_with_params(self, data, context, custom_params):
        # Implementação das 3 fases com parâmetros customizados
        pass
```

### **2. Interface de Transparência**
- **Seção obrigatória**: "🎛️ Configuração Transparente de Parâmetros"
- **Explicações contextuais**: Para cada parâmetro, explicar o impacto
- **Seção de resultados**: "🎛️ Parâmetros Utilizados" com valores exatos

### **3. Validação e Testes**
- **Métricas de qualidade**: Silhouette Score, Cross-validation accuracy
- **Testes de sanidade**: Verificar se clusters fazem sentido para negócio
- **Validação de entrada**: Verificar métricas mínimas necessárias

### **4. Documentação de Algoritmos**
Para cada algoritmo novo, documentar:
- **Quando usar**: Contextos específicos
- **Vantagens vs atual**: Comparação clara
- **Parâmetros críticos**: Quais ajustar e por quê
- **Interpretação de resultados**: Como explicar para gestores

## 📊 **MÉTRICAS E AVALIAÇÃO**

### **Métricas de Qualidade Técnica**
- **Clustering**: Silhouette Score > 0.3
- **Classificação**: Accuracy > 80%, Cross-validation estável
- **Anomalias**: Recall > 70% para produtos realmente problemáticos

### **Métricas de Negócio**
- **Interpretabilidade**: Gestores conseguem entender as categorias
- **Actionable**: Cada cluster deve ter recomendações claras
- **ROI**: Impacto financeiro estimado das recomendações

## 🚀 **ROADMAP DE ALGORITMOS**

### **Fase Atual (Implementado)**
- ✅ DBSCAN contextual
- ✅ K-means com determinação automática de K
- ✅ SVM com transparência de parâmetros
- ✅ Interface de configuração

### **Fase 2 (Prioridade Alta)**
- [ ] **XGBoost** substitui SVM (maior precisão + interpretabilidade)
- [ ] **Isolation Forest** para detecção específica de anomalias
- [ ] **Feature importance** e explicabilidade SHAP

### **Fase 3 (Prioridade Média)**
- [ ] **Gaussian Mixture Models** para clustering flexível
- [ ] **HDBSCAN** para densidade hierárquica
- [ ] **Time Series Clustering** para sazonalidade

### **Fase 4 (Especialização - 6-9 meses)**
- [ ] **Time Series Clustering** para padrões sazonais
- [ ] **Market Basket Analysis** para produtos relacionados
- [ ] **Feature Engineering** avançado para estoque

### **Fase 5 (IA Avançada - 9-12 meses)**
- [ ] **LSTM Forecasting** para previsão ultra-precisa
- [ ] **Graph Neural Networks** para relacionamentos complexos
- [ ] **Ensemble Methods** para combinação inteligente

### **Fase 6 (Foundation Models GRATUITOS - PRIORIDADE ABSOLUTA)**
- [ ] **TimesFM Local** - Google foundation model GRATUITO (+25-40% accuracy)
- [ ] **TSB + Croston Local** - Demanda intermitente segura (50% SKUs)
- [ ] **Hybrid Fusion** - TimesFM + TSB combinação inteligente

### **Fase 7 (Demanda Intermitente - CRÍTICO)**
- [ ] **TSB Method** - Bias-corrected Croston (+15% accuracy)
- [ ] **Croston's Method** - Padrão indústria para spare parts
- [ ] **Intermittent Detection** - Classificação automática ADI/CV²

### **Fase 8 (Transformers Avançados)**
- [ ] **PatchTST** - SOTA para long-horizon forecasting
- [ ] **N-HiTS** - Hierarchical + 10x speedup
- [ ] **Ensemble Intelligence** - Combinação automática modelos

### **Fase 9 (Autonomia - 12+ meses)**
- [ ] **Multi-Armed Bandit** para otimização em tempo real
- [ ] **Reinforcement Learning** para agente inteligente
- [ ] **AutoML Pipeline** completamente autônomo

## 🎯 **CONTEXTOS ESPECÍFICOS DE ESTOQUE**

### **1. Produtos Problemáticos (Outliers)**
- **Algoritmo**: Isolation Forest > DBSCAN outliers
- **Critérios**: DIO > 300 dias, Taxa Giro < 1x/ano
- **Ação**: Investigação urgente, possível descontinuação

### **2. Segmentação ABC Inteligente**
- **Algoritmo**: K-means com K=3 fixo
- **Critérios**: Valor vendas + Margem + Frequência
- **Resultado**: Distribuição balanceada para gestão

### **3. Padrões Sazonais**
- **Algoritmo**: Time Series Clustering (futuro)
- **Critérios**: Coeficiente de variação temporal
- **Resultado**: Estratégias de estoque diferenciadas

## 🔍 **DEBUGGING E TROUBLESHOOTING**

### **Problemas Comuns**
1. **Todos clusters iguais**: Verificar normalização e outliers
2. **Muitos outliers DBSCAN**: Ajustar EPS para mais tolerante
3. **SVM baixa precisão**: Verificar desbalanceamento de classes
4. **K-means não converge**: Verificar dados escalados

### **Logs e Monitoramento**
- Log de parâmetros usados em cada execução
- Métricas de qualidade salvas para comparação
- Tempo de execução por algoritmo

## 📚 **RECURSOS E REFERÊNCIAS**

### **Documentação Técnica**
- **Scikit-learn**: Todos algoritmos base
- **XGBoost**: https://xgboost.readthedocs.io/
- **HDBSCAN**: https://hdbscan.readthedocs.io/
- **Streamlit**: Interface de usuário

### **Padrões de Estoque**
- **ABC Analysis**: Classificação por valor
- **XYZ Analysis**: Classificação por variabilidade
- **VED Analysis**: Classificação por criticidade

---

## 💰 **REGRAS DE ANÁLISE CUSTO-BENEFÍCIO**

### **Matriz de Decisão Financeira:**
```python
COST_DECISION_MATRIX = {
    "GRATUITO": "Implementar imediatamente (TimesFM, TSB, SARIMA)",
    "BAIXO_CUSTO": "< $1000/ano - Avaliar ROI rapidamente",  
    "MÉDIO_CUSTO": "$1000-10000/ano - Business case necessário",
    "ALTO_CUSTO": "> $10000/ano - Aprovação executiva + ROI >300%"
}
```

### **Algoritmos por Categoria de Custo:**
- **💚 GRATUITOS**: TimesFM, TSB, Croston, SARIMA, Prophet (ROI ∞)
- **💛 BAIXO CUSTO ALTO VALOR**: OpenAI Corporate ($50-200/mês, ROI 300-500%)
- **💰 ALTO**: TimeGPT ($27k-72k/3anos) - Apenas se features únicas críticas

### **Arquitetura Triple Stack:**
```python
RECOMMENDED_STACK = {
    "quantitative_layer": "TimesFM + TSB (forecasts precisos, $0)",
    "qualitative_layer": "OpenAI Corporate (insights + recomendações, baixo custo)",
    "fusion_layer": "Combinação local (experiência transformacional)"
}
```

### **Regra de Ouro:** 
**Sempre priorizar algoritmos gratuitos SOTA antes de considerar pagos.**

---

## ⚡ **PRINCÍPIOS FUNDAMENTAIS**

1. **ROI Infinito > Custo Alto**: Priorizar algoritmos gratuitos estado da arte
2. **Transparência > Performance**: Sempre mostrar como decisões são tomadas
3. **Configurabilidade > Automação**: Permitir ajustes quando necessário  
4. **Interpretabilidade > Precisão**: Gestores precisam entender os resultados
5. **Modularidade > Monolito**: Algoritmos independentes e intercambiáveis
6. **Validação > Confiança**: Sempre validar resultados antes de apresentar

**Este documento é vivo e deve ser atualizado conforme o projeto evolui.** 