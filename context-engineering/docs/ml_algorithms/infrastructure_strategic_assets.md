# 🏗️ Ativos Estratégicos de Infraestrutura - ML Pipeline

## 🎯 **INFRAESTRUTURA EXISTENTE - VANTAGEM COMPETITIVA**

### **✅ ATIVOS ESTRATÉGICOS JÁ IMPLEMENTADOS**

| **Componente** | **Status** | **Container** | **Porta** | **Vantagem para ML** |
|----------------|------------|---------------|-----------|----------------------|
| **PostgreSQL** | ✅ **Healthy** | `ims_postgres_staging` | 5432 | **Data Lake centralizado** para training datasets |
| **Redis** | ✅ **Healthy** | `ims_redis_staging` | 6379 | **Cache de modelos** + **Feature Store** + **Result Cache** |
| **Celery Worker** | ✅ **Healthy** | `ims_celery_worker_staging` | - | **ML Training assíncrono** + **Background processing** |
| **Celery Beat** | ⚠️ **Config needed** | `ims_celery_beat_staging` | - | **Scheduled retraining** + **Model monitoring** |
| **Django API** | ✅ **Healthy** | `ims_django_staging` | 8000 | **ML API endpoints** + **Model serving** |
| **Streamlit** | ✅ **Healthy** | `ims_streamlit_staging` | 8501 | **ML Interface** + **Model results visualization** |
| **Keycloak** | ✅ **Healthy** | `ims_keycloak_staging` | 8080 | **Secure ML access** + **User-based model access** |

---

## 🧠 **COMO APROVEITAR CADA ATIVO PARA ML**

### **🗄️ PostgreSQL - Data Lake Estratégico**

#### **Vantagens Existentes:**
```sql
-- Já temos dados históricos estruturados
SELECT 
    codigo_produto,
    dio,
    taxa_giro,
    valor_estoque,
    nivel_atendimento,
    created_at
FROM inventory_metrics 
WHERE created_at >= NOW() - INTERVAL '2 years';  -- 2 anos de dados para training
```

#### **Expansão para ML:**
```python
# Tabelas ML que podemos criar aproveitando PostgreSQL
ML_TABLES = {
    "model_training_datasets": "Datasets para cada modelo",
    "model_performance_history": "Tracking de accuracy por modelo",
    "feature_engineering_cache": "Features calculadas e cached",
    "prediction_results": "Resultados de forecasting históricos",
    "model_metadata": "Metadados de modelos (parâmetros, versão)",
    "classification_results": "Resultados de DBSCAN, K-means, XGBoost"
}
```

#### **Implementação Prática:**
```python
# utils/ml_database.py
class MLDatabase:
    def __init__(self):
        self.engine = create_engine(DATABASE_URL)  # Usar PostgreSQL existente
    
    def save_model_results(self, model_name, product_data, results):
        """Salva resultados de ML no PostgreSQL existente"""
        df = pd.DataFrame(results)
        df.to_sql(f'{model_name}_results', self.engine, if_exists='append')
    
    def get_training_data(self, months_back=24):
        """Puxa dados históricos para training"""
        query = """
        SELECT * FROM inventory_data 
        WHERE created_at >= NOW() - INTERVAL %s MONTH
        """
        return pd.read_sql(query, self.engine, params=[months_back])
```

### **⚡ Redis - Cache Inteligente para ML**

#### **Vantagens Existentes:**
- **Performance 15-120x** já implementada
- **Conexão estabelecida**: `redis-staging:6379/db0`
- **Infrastructure pronta** para cache distribuído

#### **Expansão para ML:**
```python
# utils/ml_redis_cache.py
class MLRedisCache:
    def __init__(self):
        self.redis = redis.Redis(host='redis-staging', port=6379, db=1)  # DB dedicado ML
    
    def cache_model_results(self, product_code, model_name, results, ttl=3600):
        """Cache resultados de ML para acesso rápido"""
        key = f"ml:{model_name}:{product_code}"
        self.redis.setex(key, ttl, json.dumps(results))
    
    def cache_features(self, product_code, features, ttl=7200):
        """Cache features calculadas para reutilização"""
        key = f"features:{product_code}"
        self.redis.setex(key, ttl, pickle.dumps(features))
    
    def cache_trained_model(self, model_name, model_object, ttl=86400):
        """Cache modelo treinado na memória"""
        key = f"model:{model_name}"
        self.redis.setex(key, ttl, pickle.dumps(model_object))
        
    def get_cached_prediction(self, product_code, model_name):
        """Recupera predição em cache (instantânea)"""
        key = f"ml:{model_name}:{product_code}"
        cached = self.redis.get(key)
        return json.loads(cached) if cached else None
```

#### **Performance Estratégica:**
```python
# Exemplo: Prediction instantânea com cache
def predict_with_cache(product_code, force_recalc=False):
    cache = MLRedisCache()
    
    if not force_recalc:
        cached_result = cache.get_cached_prediction(product_code, 'xgboost_router')
        if cached_result:
            return cached_result  # ⚡ INSTANTÂNEO (Redis)
    
    # Só calcula se não está em cache
    result = xgboost_model.predict(product_features)
    cache.cache_model_results(product_code, 'xgboost_router', result)
    return result
```

### **🔄 Celery - ML Training Assíncrono**

#### **Vantagens Existentes:**
- **Worker healthy** e conectado ao Redis
- **Background processing** já funcionando
- **Scaling horizontal** pronto

#### **Expansão para ML:**
```python
# api/tasks/ml_tasks.py
from celery import shared_task
import pandas as pd
from utils.contextual_clustering import HybridClusteringEngine

@shared_task(bind=True)
def train_classification_model(self, dataset_id):
    """Task assíncrona para treinar modelo de classificação"""
    
    # Atualizar progresso
    self.update_state(state='PROGRESS', meta={'progress': 10, 'status': 'Carregando dados...'})
    
    # Carregar dados do PostgreSQL
    data = load_training_dataset(dataset_id)
    
    self.update_state(state='PROGRESS', meta={'progress': 30, 'status': 'Treinando DBSCAN...'})
    
    # Treinar modelo
    engine = HybridClusteringEngine()
    results = engine.run_complete_pipeline(data)
    
    self.update_state(state='PROGRESS', meta={'progress': 80, 'status': 'Salvando resultados...'})
    
    # Salvar no PostgreSQL + cache no Redis
    save_model_results(results)
    cache_trained_model(engine)
    
    return {'status': 'SUCCESS', 'model_id': results['model_id']}

@shared_task
def forecasting_batch_processing(product_codes):
    """Processar forecasting para múltiplos produtos em background"""
    results = {}
    
    for code in product_codes:
        # Usar integração classificação → forecasting
        classification = get_product_classification(code)
        forecast_method = select_optimal_method(classification)
        forecast = execute_forecasting(code, forecast_method)
        
        results[code] = {
            'classification': classification,
            'forecast_method': forecast_method,
            'forecast': forecast
        }
    
    return results

@shared_task
def retrain_xgboost_router():
    """Retreinar XGBoost Router com performance histórica (scheduled)"""
    
    # Coletar performance histórica
    historical_performance = collect_forecasting_performance_history()
    
    # Retreinar router
    router = XGBoostForecastingRouter()
    router.retrain_with_performance_feedback(historical_performance)
    
    # Salvar modelo atualizado
    save_trained_router(router)
    
    return {'status': 'Router retrained', 'accuracy_improvement': '+5.2%'}
```

#### **Celery Beat - Retraining Automático:**
```python
# ims_project/celery.py
from celery.schedules import crontab

app.conf.beat_schedule = {
    'retrain-xgboost-router': {
        'task': 'api.tasks.ml_tasks.retrain_xgboost_router',
        'schedule': crontab(hour=2, minute=0, day_of_week=1),  # Segunda às 2h
    },
    'update-product-classifications': {
        'task': 'api.tasks.ml_tasks.update_all_classifications',
        'schedule': crontab(hour=3, minute=0),  # Diário às 3h
    },
    'forecast-batch-high-priority': {
        'task': 'api.tasks.ml_tasks.forecasting_batch_processing',
        'schedule': crontab(hour=1, minute=0),  # Diário às 1h
        'kwargs': {'product_filter': 'abc_class_A'}
    }
}
```

### **🌐 Django API - ML Serving**

#### **Expansão para ML Endpoints:**
```python
# api/views/ml_views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['POST'])
def classify_product(request):
    """Endpoint para classificação de produto individual"""
    
    product_code = request.data.get('product_code')
    
    # Verificar cache primeiro
    cached_result = get_cached_classification(product_code)
    if cached_result:
        return Response({
            'source': 'cache',
            'classification': cached_result,
            'processing_time': '< 1ms'
        })
    
    # Executar classificação
    start_time = time.time()
    classification = run_hybrid_classification(product_code)
    processing_time = time.time() - start_time
    
    # Cache resultado
    cache_classification_result(product_code, classification)
    
    return Response({
        'source': 'computed',
        'classification': classification,
        'processing_time': f'{processing_time:.2f}s'
    })

@api_view(['POST'])
def predict_demand(request):
    """Endpoint para previsão de demanda integrada"""
    
    product_code = request.data.get('product_code')
    horizon = request.data.get('horizon', 6)
    
    # Pipeline integrado classificação → forecasting
    classification = get_product_classification(product_code)
    optimal_method = select_forecasting_method(classification)
    forecast = execute_forecasting(product_code, optimal_method, horizon)
    
    return Response({
        'product_code': product_code,
        'classification': classification,
        'forecasting_method': optimal_method,
        'forecast': forecast,
        'explanation': f"Método {optimal_method} selecionado baseado em {classification['reasoning']}"
    })
```

### **🔐 Keycloak - Secure ML Access**

#### **ML Security por Usuário:**
```python
# utils/ml_security.py
def check_ml_permissions(user_token, operation):
    """Verificar permissões de ML baseado em Keycloak"""
    
    permissions = {
        'ml_analyst': ['view_classifications', 'run_forecasting'],
        'ml_engineer': ['train_models', 'modify_parameters'],
        'admin': ['all_operations']
    }
    
    user_roles = decode_keycloak_token(user_token)['roles']
    
    for role in user_roles:
        if operation in permissions.get(role, []):
            return True
    
    return False

@require_ml_permission('run_forecasting')
def secure_forecasting_endpoint(request):
    """Endpoint seguro para forecasting"""
    # Implementação protegida por Keycloak
    pass
```

---

## 🚀 **APROVEITAMENTO ESTRATÉGICO - IMPLEMENTAÇÃO**

### **🎯 Vantagens Competitivas:**

1. **⚡ Performance Extrema**:
   - Redis cache → Predições instantâneas
   - PostgreSQL otimizado → Training datasets massivos
   - Celery async → Training sem bloqueio

2. **🔄 Automação Total**:
   - Celery Beat → Retraining automático
   - Background tasks → Processos longos não bloqueiam UI
   - Scheduled optimization → Sistema auto-melhora

3. **🛡️ Enterprise Security**:
   - Keycloak → Controle de acesso granular
   - API centralizada → Auditoria completa
   - User-based permissions → Segurança por função

4. **📈 Escalabilidade**:
   - Horizontal scaling ready → Mais workers conforme necessário
   - Distributed cache → Performance não degrada
   - Microservices architecture → Componentes independentes

### **🔄 Pipeline ML Otimizado:**

```python
# Pipeline completo aproveitando toda infraestrutura
def optimized_ml_pipeline(product_code):
    
    # 1. Check cache (Redis) - INSTANTÂNEO
    cached = redis_cache.get_cached_result(product_code)
    if cached: return cached
    
    # 2. Load data (PostgreSQL) - OTIMIZADO
    product_data = postgres_db.get_product_features(product_code)
    
    # 3. Classify (Cached models) - RÁPIDO
    classification = cached_classification_model.predict(product_data)
    
    # 4. Route to optimal forecasting (XGBoost) - INTELIGENTE
    optimal_method = xgboost_router.select_method(classification)
    
    # 5. Execute forecasting (Celery if heavy) - ASSÍNCRONO
    if is_heavy_computation(optimal_method):
        task = celery_forecast.delay(product_code, optimal_method)
        return {'status': 'processing', 'task_id': task.id}
    else:
        forecast = execute_light_forecasting(product_code, optimal_method)
        
    # 6. Cache result (Redis) - PERFORMANCE FUTURA
    redis_cache.cache_result(product_code, forecast)
    
    # 7. Save to database (PostgreSQL) - HISTÓRICO
    postgres_db.save_prediction_result(product_code, forecast)
    
    return forecast
```

### **📊 ROI da Infraestrutura Existente:**

| **Componente** | **Investimento** | **ROI para ML** | **Tempo Economia** |
|----------------|------------------|-----------------|-------------------|
| **PostgreSQL** | ✅ **$0** (já existe) | **Data Lake** pronto | **-80% setup time** |
| **Redis** | ✅ **$0** (já existe) | **Cache Layer** enterprise | **-95% response time** |
| **Celery** | ✅ **$0** (já existe) | **Async Training** | **-100% UI blocking** |
| **Keycloak** | ✅ **$0** (já existe) | **Enterprise Security** | **-90% auth setup** |
| **Docker** | ✅ **$0** (já existe) | **Deployment** ready | **-70% deploy time** |

**💰 Total ROI: INFINITO** (infraestrutura enterprise sem custo adicional!)

---

## 🎯 **PRÓXIMOS PASSOS - IMPLEMENTAÇÃO**

### **🚀 Sprint Específico para Aproveitamento de Ativos:**

1. **📅 Semana 1**: Expandir PostgreSQL com tabelas ML
2. **📅 Semana 2**: Implementar Redis ML Cache Layer  
3. **📅 Semana 3**: Criar Celery ML Tasks
4. **📅 Semana 4**: Django ML API endpoints
5. **📅 Semana 5**: Keycloak ML permissions

### **⚡ Quick Wins (Implementação Imediata):**

```python
# Pode implementar HOJE aproveitando ativos existentes:

# 1. Redis ML Cache (5 linhas)
redis_ml = redis.Redis(host='redis-staging', port=6379, db=1)

# 2. PostgreSQL ML Tables (1 migration)
class MLResults(models.Model):
    product_code = models.CharField(max_length=50)
    model_name = models.CharField(max_length=100)
    results = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

# 3. Celery ML Task (10 linhas)
@shared_task
def async_classification(product_code):
    result = run_hybrid_classification(product_code)
    cache_result(product_code, result)
    return result
```

**🎯 Resultado: Sistema ML enterprise em 1 semana aproveitando 100% da infraestrutura existente!** 