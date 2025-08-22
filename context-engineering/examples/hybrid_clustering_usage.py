"""
Exemplo de Uso: Abordagem Tripla Inteligente para Análise de Estoque

Este exemplo demonstra como usar o HybridClusteringEngine seguindo os padrões
definidos em CLAUDE.md para implementar a análise contextual de estoque.

Autor: Sistema de ML para Análise de Estoque
Data: 2024-07-18
Baseado em: context-engineering/INITIAL.md
"""

import pandas as pd
import numpy as np
from utils.contextual_clustering import HybridClusteringEngine, ContextualClusterEngine

def exemplo_analise_tripla_completa():
    """
    Exemplo completo da Abordagem Tripla Inteligente:
    🔍 DBSCAN → 🎯 K-means → 🤖 SVM/XGBoost
    """
    
    # 1. Preparar dados de exemplo
    dados_estoque = gerar_dados_exemplo()
    
    # 2. Configurar contexto de análise
    contexto = {
        'objetivo': 'REDUZIR_CUSTOS',
        'metricas_foco': ['dio', 'custo_manutencao', 'valor_estoque'],
        'algoritmo_preferido': 'dbscan + kmeans',
        'usuarios_alvo': ['gestor_compras', 'analista_estoque']
    }
    
    # 3. Configurar parâmetros transparentes
    parametros_customizados = {
        'dbscan': {
            'eps': 0.3,  # "Distância entre produtos similares"
            'min_samples': 5,  # "Mínimo de produtos por grupo"
            'reasoning': "EPS baixo = grupos mais rígidos, mais outliers detectados"
        },
        'kmeans': {
            'n_clusters': 'auto',  # Determinação automática baseada em DBSCAN
            'max_iter': 300,
            'random_state': 42  # Reproducibilidade obrigatória
        },
        'svm': {
            'kernel': 'rbf',  # "Captura padrões não-lineares"
            'C': 1.0,  # "Balanceamento entre precisão e generalização"
            'expected_accuracy': "80-90%"
        }
    }
    
    # 4. Executar análise tripla
    print("🔍 Executando Abordagem Tripla Inteligente...")
    
    engine = HybridClusteringEngine()
    resultado = engine.execute_hybrid_analysis_with_params(
        data=dados_estoque,
        context=contexto,
        custom_params=parametros_customizados
    )
    
    # 5. Interpretar resultados de cada fase
    interpretar_resultados_fases(resultado)
    
    # 6. Testar classificação de novos produtos
    testar_classificacao_automatica(engine)
    
    return resultado

def gerar_dados_exemplo():
    """
    Gera dados de exemplo seguindo o padrão definido em CLAUDE.md
    """
    np.random.seed(42)  # Reproducibilidade obrigatória
    
    # Métricas obrigatórias conforme CLAUDE.md
    dados = {
        'produto_id': [f'PROD_{i:03d}' for i in range(1, 401)],
        'taxa_giro': np.random.gamma(2, 2, 400),  # Concentra em valores baixos
        'dio': np.random.exponential(90, 400),  # Dias em estoque
        'nivel_atendimento': np.random.normal(85, 15, 400),  # %
        'custo_manutencao': np.random.gamma(3, 100, 400),  # R$
        'valor_estoque': np.random.lognormal(8, 1.5, 400),  # R$
        'frequencia_vendas': np.random.poisson(5, 400),  # vendas/mês
    }
    
    # Tratamento de outliers conforme padrão (quantis 2.5% e 97.5%)
    df = pd.DataFrame(dados)
    for col in ['taxa_giro', 'dio', 'custo_manutencao', 'valor_estoque']:
        q_low = df[col].quantile(0.025)
        q_high = df[col].quantile(0.975)
        df[col] = df[col].clip(q_low, q_high)
    
    # Garantir que nivel_atendimento está entre 0-100
    df['nivel_atendimento'] = df['nivel_atendimento'].clip(0, 100)
    
    return df

def interpretar_resultados_fases(resultado):
    """
    Interpreta e exibe resultados de cada fase da análise
    """
    print("\n📊 RESULTADOS DA ANÁLISE TRIPLA")
    print("=" * 50)
    
    # Fase 1: DBSCAN Discovery
    fase1 = resultado['phase1_dbscan']
    print(f"\n🔍 FASE 1 - DBSCAN (Descoberta)")
    print(f"   • Clusters naturais encontrados: {fase1['n_clusters']}")
    print(f"   • Outliers detectados: {fase1['n_outliers']} ({fase1['outlier_percentage']:.1f}%)")
    print(f"   • Insight: {fase1['business_insight']}")
    
    # Fase 2: K-means Structure
    fase2 = resultado['phase2_kmeans']
    print(f"\n🎯 FASE 2 - K-means (Estruturação)")
    print(f"   • Categorias criadas: {fase2['n_categories']}")
    print(f"   • Labels de negócio: {', '.join(fase2['business_labels'])}")
    print(f"   • Distribuição balanceada: {fase2['balanced_distribution']}")
    
    # Fase 3: SVM Automation
    fase3 = resultado['phase3_svm']
    print(f"\n🤖 FASE 3 - SVM (Automação)")
    print(f"   • Precisão do modelo: {fase3['accuracy']:.1f}%")
    print(f"   • Cross-validation score: {fase3['cv_score']:.3f}")
    print(f"   • Modelo pronto para novos produtos: {'✅' if fase3['model_trained'] else '❌'}")
    
    # Parâmetros utilizados (transparência total)
    parametros = resultado['parameters_used']
    print(f"\n🎛️ PARÂMETROS UTILIZADOS")
    for algoritmo, params in parametros.items():
        print(f"   {algoritmo.upper()}:")
        for param, valor in params.items():
            print(f"     • {param}: {valor}")

def testar_classificacao_automatica(engine):
    """
    Demonstra a classificação automática de novos produtos
    """
    print(f"\n🔮 TESTE DE CLASSIFICAÇÃO AUTOMÁTICA")
    print("=" * 50)
    
    # Exemplos de novos produtos
    novos_produtos = [
        {
            'produto_id': 'NOVO_001',
            'taxa_giro': 0.8,  # Produto com giro baixo
            'dio': 450,  # Muitos dias em estoque
            'nivel_atendimento': 60,  # Atendimento ruim
            'custo_manutencao': 800,
            'valor_estoque': 15000,
            'expected_category': 'Crítico'
        },
        {
            'produto_id': 'NOVO_002', 
            'taxa_giro': 4.2,  # Giro alto
            'dio': 87,  # Poucos dias em estoque
            'nivel_atendimento': 95,  # Excelente atendimento
            'custo_manutencao': 200,
            'valor_estoque': 8000,
            'expected_category': 'Alto Potencial'
        }
    ]
    
    for produto in novos_produtos:
        resultado_pred = engine.predict_new_product(produto)
        print(f"\n📦 Produto: {produto['produto_id']}")
        print(f"   • Categoria predita: {resultado_pred['predicted_category']}")
        print(f"   • Confiança: {resultado_pred['confidence']:.1f}%")
        print(f"   • Probabilidades: {resultado_pred['probabilities']}")
        print(f"   • Esperado: {produto['expected_category']}")

def exemplo_contextos_especificos():
    """
    Demonstra diferentes contextos de análise conforme CLAUDE.md
    """
    contextos = {
        'REDUZIR_CUSTOS': {
            'métricas_foco': ['dio', 'custo_manutencao', 'valor_estoque'],
            'algoritmo_preferido': 'dbscan + kmeans',
            'categorias_resultado': ['Alto Potencial', 'Médio Potencial', 'Baixo Potencial', 'Manutenção']
        },
        'ACELERAR_GIRO': {
            'métricas_foco': ['taxa_giro', 'dio', 'frequencia_vendas'],
            'algoritmo_preferido': 'dbscan',
            'foco_especial': 'detecção_produtos_estagnados'
        },
        'MELHORAR_ATENDIMENTO': {
            'métricas_foco': ['nivel_atendimento', 'coef_variacao_quantidade', 'frequencia_vendas'],
            'categorias_fixas': 4,
            'labels': ['Excelente', 'Bom', 'Regular', 'Crítico']
        }
    }
    
    print("\n🎯 CONTEXTOS ESPECÍFICOS DE ANÁLISE")
    print("=" * 50)
    
    for contexto, config in contextos.items():
        print(f"\n📋 {contexto}:")
        for key, value in config.items():
            print(f"   • {key}: {value}")

if __name__ == "__main__":
    print("🧠 Sistema de ML para Análise de Estoque")
    print("📋 Exemplo de Uso - Abordagem Tripla Inteligente")
    print("🔗 Baseado em: context-engineering/INITIAL.md")
    print("")
    
    # Executar exemplo completo
    resultado = exemplo_analise_tripla_completa()
    
    # Mostrar contextos disponíveis
    exemplo_contextos_especificos()
    
    print("\n✅ Exemplo executado com sucesso!")
    print("📖 Para mais detalhes, consulte: context-engineering/README.md") 