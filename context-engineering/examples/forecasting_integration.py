"""
Integração da Previsão Avançada ao App Principal

Este exemplo mostra como integrar a nova página de previsão avançada
(pages/forecasting_advanced.py) ao sistema principal (app.py).

Baseado em: documentacao_predicoes/modelos_previsao_fungicidas.md
Autor: Sistema de ML para Análise de Estoque
Data: 2024-07-18
"""

import streamlit as st

def integrar_previsao_avancada_ao_menu():
    """
    Exemplo de como adicionar a previsão avançada ao menu principal do app.py
    """
    
    # Código para adicionar no app.py principal
    menu_code = '''
    # No arquivo app.py, adicionar na seção de páginas:
    
    elif page == "Previsão Avançada":
        from pages.forecasting_advanced import main as forecasting_main
        forecasting_main()
    '''
    
    # Configuração do menu sidebar
    sidebar_code = '''
    # No sidebar do app.py, adicionar:
    
    page = st.sidebar.selectbox(
        "📑 Selecione a página:",
        [
            "Dashboard", 
            "Inventário", 
            "Métricas", 
            "ABC Analysis",
            "Previsão Avançada",  # 🆕 NOVA PÁGINA
            "Configurações"
        ]
    )
    '''
    
    return menu_code, sidebar_code

def exemplo_uso_api_previsao():
    """
    Exemplo de como usar as funções de previsão como API
    """
    
    api_code = '''
    # Exemplo de uso das funções de previsão independentemente
    
    from pages.forecasting_advanced import (
        carregar_dados_produto,
        executar_previsoes,
        tratar_outliers
    )
    
    # Carregar dados para um produto específico
    produto = "FUNG APPROVE 5KG"
    dados = carregar_dados_produto(produto, periodo_meses=24)
    
    # Executar previsões com múltiplos algoritmos
    algoritmos = ["SARIMA", "Prophet", "Holt-Winters"]
    resultados = executar_previsoes(dados, algoritmos, horizonte=6)
    
    # Extrair previsão de um algoritmo específico
    previsao_sarima = resultados["SARIMA"]["previsao"]
    intervalos_confianca = resultados["SARIMA"]["conf_int_upper"]
    
    print(f"Previsão SARIMA para 6 meses: {previsao_sarima}")
    '''
    
    return api_code

def dependencias_necessarias():
    """
    Lista de dependências necessárias para a funcionalidade completa
    """
    
    requirements = '''
    # Adicionar ao requirements.txt:
    
    # Algoritmos de previsão
    statsmodels>=0.14.0      # SARIMA, ARIMA, Holt-Winters
    prophet>=1.1.4           # Prophet (Facebook)
    scikit-learn>=1.3.0      # Regressão Robusta
    
    # Visualizações avançadas
    plotly>=5.15.0           # Gráficos interativos
    seaborn>=0.12.0          # Visualizações estatísticas
    
    # Processamento de dados
    pandas>=2.0.0            # Séries temporais
    numpy>=1.24.0            # Computação numérica
    '''
    
    return requirements

def configuracao_ambiente():
    """
    Configurações necessárias no ambiente
    """
    
    config = '''
    # Configurações de ambiente necessárias:
    
    1. **Instalar Prophet**:
       pip install prophet
       
    2. **Configurar PostgreSQL** (se usando dados reais):
       - Criar view vw_movimentacao_estoque
       - Configurar conexão em utils/database.py
       
    3. **Variáveis de ambiente**:
       DATABASE_URL=postgresql://user:pass@host:port/db
       ENABLE_FORECASTING=true
       
    4. **Estrutura de dados mínima**:
       - Tabela de movimentações com data_movimento, codigo_material, quantidade
       - Pelo menos 12 meses de dados históricos
    '''
    
    return config

def exemplo_personalizacao():
    """
    Exemplo de como personalizar algoritmos para produtos específicos
    """
    
    personalizacao = '''
    # Personalização de algoritmos por categoria de produto:
    
    def selecionar_algoritmo_otimo(produto_categoria, dados_historicos):
        """
        Seleciona o melhor algoritmo baseado na categoria do produto
        """
        
        # Calcular características dos dados
        cv = dados_historicos.std() / dados_historicos.mean()  # Coef. variação
        sazonalidade = detectar_sazonalidade(dados_historicos)
        
        if produto_categoria == "FUNGICIDA":
            if sazonalidade > 0.3:
                return "SARIMA"  # Forte sazonalidade
            else:
                return "Holt-Winters"
                
        elif produto_categoria == "FERTILIZANTE":
            if cv > 0.5:
                return "Prophet"  # Alta volatilidade
            else:
                return "ARIMA"
                
        elif produto_categoria == "SEMENTE":
            return "SARIMA"  # Sempre sazonal
            
        else:
            return "Prophet"  # Padrão para outros produtos
    
    def detectar_sazonalidade(serie):
        """
        Detecta grau de sazonalidade na série temporal
        """
        from statsmodels.tsa.seasonal import seasonal_decompose
        
        try:
            decomp = seasonal_decompose(serie, model='multiplicative', period=12)
            sazonalidade = decomp.seasonal.std() / serie.std()
            return sazonalidade
        except:
            return 0
    '''
    
    return personalizacao

def exemplo_integracao_completa():
    """
    Exemplo completo de integração com o sistema existente
    """
    
    integracao = '''
    # Integração completa com o sistema existente:
    
    # 1. Adicionar ao navigation.py
    def show_forecasting_menu():
        st.sidebar.markdown("### 📈 Previsão")
        
        if st.sidebar.button("🔮 Previsão Avançada"):
            st.session_state.page = "forecasting_advanced"
            
        if st.sidebar.button("📊 Comparar Algoritmos"):
            st.session_state.page = "algorithm_comparison"
    
    # 2. Conectar com dados reais em utils/database.py
    def get_product_sales_data(codigo_material, months_back=24):
        """
        Busca dados reais de vendas do produto
        """
        query = f"""
        SELECT 
            DATE_TRUNC('month', data_movimento) as mes,
            SUM(quantidade) as quantidade_vendida
        FROM movimentacao_estoque 
        WHERE codigo_material = '{codigo_material}'
            AND tipo_movimento = 'SAIDA'
            AND data_movimento >= CURRENT_DATE - INTERVAL '{months_back} months'
        GROUP BY mes
        ORDER BY mes
        """
        return execute_query(query)
    
    # 3. Adicionar cache para performance
    @st.cache_data(ttl=3600)  # Cache por 1 hora
    def cached_forecasting(produto, algoritmos, horizonte):
        """
        Versão com cache das previsões para melhor performance
        """
        dados = carregar_dados_produto(produto, 24)
        return executar_previsoes(dados, algoritmos, horizonte)
    
    # 4. Integração com alertas
    def criar_alertas_previsao(resultados_previsao, produto):
        """
        Cria alertas baseados nas previsões
        """
        for algoritmo, resultado in resultados_previsao.items():
            previsao = resultado['previsao']
            
            # Alerta de baixa demanda
            if np.mean(previsao) < 10:
                send_alert(f"⚠️ Baixa demanda prevista para {produto}")
                
            # Alerta de alta demanda  
            elif np.mean(previsao) > 1000:
                send_alert(f"📈 Alta demanda prevista para {produto}")
    '''
    
    return integracao

def documentar_novas_funcionalidades():
    """
    Documentação das novas funcionalidades implementadas
    """
    
    doc = '''
    # 📈 Nova Funcionalidade: Previsão Avançada de Estoque
    
    ## 🎯 O Que Foi Implementado
    
    1. **Interface Intuitiva de Previsão**:
       - Seleção de produtos via dropdown
       - Configuração de período histórico e horizonte
       - Seleção múltipla de algoritmos
       
    2. **Algoritmos Implementados**:
       - ✅ SARIMA (Seasonal ARIMA)
       - ✅ ARIMA (AutoRegressive Integrated Moving Average)  
       - ✅ Prophet (Facebook Prophet)
       - ✅ Holt-Winters (Exponential Smoothing)
       - ✅ Regressão Robusta (Huber Regressor)
    
    3. **Análise Exploratória**:
       - Decomposição sazonal automática
       - Estatísticas descritivas
       - Visualizações interativas
       
    4. **Comparação de Algoritmos**:
       - Métricas AIC, BIC, MAE, RMSE
       - Gráficos comparativos
       - Ranking de performance
       
    5. **Recomendações Inteligentes**:
       - Estratégia de estoque (Agressiva/Moderada/Conservadora)
       - Cálculo de estoque de segurança
       - Plano de compras detalhado
    
    ## 🚀 Como Usar
    
    1. Acesse "Previsão Avançada" no menu
    2. Selecione o produto na sidebar
    3. Configure período histórico e horizonte
    4. Escolha algoritmos para comparar
    5. Analise resultados nas 4 abas:
       - 📊 Análise Exploratória
       - 🔮 Previsões
       - 📈 Comparação
       - 📋 Recomendações
    
    ## 📊 Benefícios
    
    - ⚡ **Rapidez**: Previsões em segundos vs horas
    - 🎯 **Precisão**: Múltiplos algoritmos para comparação
    - 📈 **Insights**: Análise sazonal automática
    - 💡 **Ações**: Recomendações específicas
    - 🔄 **Escalabilidade**: Funciona para qualquer produto
    '''
    
    return doc

if __name__ == "__main__":
    print("📈 Guia de Integração - Previsão Avançada de Estoque")
    print("=" * 60)
    
    print("\n1. 🔧 Código para Menu Principal:")
    menu_code, sidebar_code = integrar_previsao_avancada_ao_menu()
    print(menu_code)
    
    print("\n2. 📦 Dependências Necessárias:")
    print(dependencias_necessarias())
    
    print("\n3. ⚙️ Configuração de Ambiente:")
    print(configuracao_ambiente())
    
    print("\n4. 🎨 Personalização por Produto:")
    print(exemplo_personalizacao())
    
    print("\n5. 📚 Documentação das Funcionalidades:")
    print(documentar_novas_funcionalidades()) 