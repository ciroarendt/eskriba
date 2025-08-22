"""
Exemplo: Configuração Transparente de Parâmetros ML

Este exemplo demonstra como implementar transparência total de parâmetros
conforme especificado em CLAUDE.md, permitindo que usuários vejam e ajustem
todos os parâmetros dos algoritmos com explicações em tempo real.

Autor: Sistema de ML para Análise de Estoque
Data: 2024-07-18
Baseado em: context-engineering/CLAUDE.md
"""

import streamlit as st
from typing import Dict, Any, Tuple

class ParameterTransparencyConfig:
    """
    Classe para configuração transparente de parâmetros ML
    
    Implementa os padrões definidos em CLAUDE.md:
    - Transparência obrigatória de parâmetros
    - Explicações contextuais para cada parâmetro
    - Feedback visual do impacto dos ajustes
    """
    
    def __init__(self):
        self.algorithm_configs = self._load_default_configs()
        
    def _load_default_configs(self) -> Dict[str, Dict]:
        """
        Carrega configurações padrão para todos algoritmos
        conforme especificado em CLAUDE.md
        """
        return {
            'dbscan': {
                'eps': {
                    'default': 0.3,
                    'range': (0.1, 1.0),
                    'step': 0.05,
                    'explanation': "Distância máxima entre produtos para serem considerados similares",
                    'impact': {
                        'low': "EPS baixo (<0.3) = grupos mais rígidos, mais outliers detectados",
                        'medium': "EPS médio (0.3-0.5) = equilíbrio entre grupos e outliers",
                        'high': "EPS alto (>0.5) = grupos mais tolerantes, menos outliers"
                    }
                },
                'min_samples': {
                    'default': 5,
                    'range': (3, 15),
                    'step': 1,
                    'explanation': "Número mínimo de produtos necessários para formar um grupo",
                    'impact': {
                        'low': "Min_samples baixo (3-5) = mais grupos pequenos formados",
                        'medium': "Min_samples médio (6-10) = grupos de tamanho moderado",
                        'high': "Min_samples alto (>10) = apenas grupos muito densos"
                    }
                }
            },
            'kmeans': {
                'n_clusters': {
                    'default': 'auto',
                    'range': (2, 8),
                    'step': 1,
                    'explanation': "Número de categorias finais para gestão de negócio",
                    'impact': {
                        'auto': "Automático = baseado nos insights do DBSCAN",
                        'manual': "Manual = você define quantas categorias quer"
                    }
                },
                'init': {
                    'default': 'k-means++',
                    'options': ['k-means++', 'random'],
                    'explanation': "Estratégia de inicialização dos centroides",
                    'impact': {
                        'k-means++': "k-means++ = inicialização inteligente (recomendado)",
                        'random': "Random = inicialização aleatória (menos estável)"
                    }
                },
                'max_iter': {
                    'default': 300,
                    'range': (100, 1000),
                    'step': 50,
                    'explanation': "Número máximo de iterações do algoritmo",
                    'impact': {
                        'low': "Max_iter baixo (<200) = convergência mais rápida, menos precisão",
                        'medium': "Max_iter médio (200-500) = bom equilíbrio",
                        'high': "Max_iter alto (>500) = maior precisão, mais lento"
                    }
                }
            },
            'svm': {
                'kernel': {
                    'default': 'rbf',
                    'options': ['rbf', 'linear', 'poly'],
                    'explanation': "Tipo de transformação para separar as categorias",
                    'impact': {
                        'rbf': "RBF = captura padrões curvos (recomendado para estoque)",
                        'linear': "Linear = assume separação linear simples",
                        'poly': "Polynomial = padrões complexos, risco de overfitting"
                    }
                },
                'C': {
                    'default': 1.0,
                    'range': (0.1, 10.0),
                    'step': 0.1,
                    'explanation': "Controle do equilíbrio entre precisão e generalização",
                    'impact': {
                        'low': "C baixo (<1.0) = generalização alta, precisão menor",
                        'medium': "C médio (1.0-3.0) = equilíbrio ideal",
                        'high': "C alto (>3.0) = precisão alta, risco de overfitting"
                    }
                }
            },
            'xgboost': {
                'n_estimators': {
                    'default': 100,
                    'range': (50, 300),
                    'step': 25,
                    'explanation': "Número de árvores de decisão no modelo",
                    'impact': {
                        'low': "N_estimators baixo (<100) = modelo simples, rápido",
                        'medium': "N_estimators médio (100-200) = boa performance",
                        'high': "N_estimators alto (>200) = modelo complexo, pode overfitting"
                    }
                },
                'learning_rate': {
                    'default': 0.1,
                    'range': (0.01, 0.3),
                    'step': 0.01,
                    'explanation': "Velocidade de aprendizado do modelo",
                    'impact': {
                        'low': "Learning_rate baixo (<0.05) = aprendizado lento e estável",
                        'medium': "Learning_rate médio (0.05-0.15) = equilíbrio ideal",
                        'high': "Learning_rate alto (>0.15) = aprendizado rápido, instável"
                    }
                },
                'max_depth': {
                    'default': 6,
                    'range': (3, 12),
                    'step': 1,
                    'explanation': "Profundidade máxima das árvores de decisão",
                    'impact': {
                        'low': "Max_depth baixo (<5) = modelo simples, menos overfitting",
                        'medium': "Max_depth médio (5-8) = complexidade balanceada",
                        'high': "Max_depth alto (>8) = modelo muito complexo"
                    }
                }
            }
        }
    
    def show_transparent_config_interface(self, algorithm: str) -> Dict[str, Any]:
        """
        Exibe interface transparente para configuração de algoritmo específico
        
        Args:
            algorithm: Nome do algoritmo ('dbscan', 'kmeans', 'svm', 'xgboost')
            
        Returns:
            Dict com parâmetros configurados pelo usuário
        """
        if algorithm not in self.algorithm_configs:
            st.error(f"Algoritmo '{algorithm}' não encontrado!")
            return {}
        
        config = self.algorithm_configs[algorithm]
        user_params = {}
        
        st.markdown(f"#### 🔧 **{algorithm.upper()} - Configuração Transparente**")
        
        with st.expander(f"🎛️ Ajustar Parâmetros {algorithm.upper()}", expanded=True):
            for param_name, param_config in config.items():
                user_params[param_name] = self._render_parameter_control(
                    algorithm, param_name, param_config
                )
        
        # Mostrar impacto combinado dos parâmetros
        self._show_combined_impact(algorithm, user_params)
        
        return user_params
    
    def _render_parameter_control(self, algorithm: str, param_name: str, 
                                param_config: Dict) -> Any:
        """
        Renderiza controle individual para um parâmetro
        """
        st.markdown(f"**{param_name}**")
        st.info(f"📝 {param_config['explanation']}")
        
        # Diferentes tipos de controles baseados no parâmetro
        if 'options' in param_config:
            # Parâmetro categórico
            value = st.selectbox(
                f"Escolha {param_name}:",
                param_config['options'],
                index=param_config['options'].index(param_config['default']),
                key=f"{algorithm}_{param_name}"
            )
            
            # Mostrar impacto da escolha
            impact_key = value
            if impact_key in param_config['impact']:
                st.success(f"📊 {param_config['impact'][impact_key]}")
                
        elif param_config['default'] == 'auto':
            # Parâmetro automático vs manual
            auto_mode = st.checkbox(
                f"Determinação automática de {param_name}",
                value=True,
                key=f"{algorithm}_{param_name}_auto"
            )
            
            if auto_mode:
                value = 'auto'
                st.success(f"📊 {param_config['impact']['auto']}")
            else:
                value = st.slider(
                    f"Valor manual para {param_name}:",
                    min_value=param_config['range'][0],
                    max_value=param_config['range'][1],
                    value=4,  # Valor padrão manual
                    step=param_config['step'],
                    key=f"{algorithm}_{param_name}_manual"
                )
                st.info(f"📊 {param_config['impact']['manual']}")
                
        else:
            # Parâmetro numérico
            value = st.slider(
                f"Valor para {param_name}:",
                min_value=param_config['range'][0],
                max_value=param_config['range'][1],
                value=param_config['default'],
                step=param_config['step'],
                key=f"{algorithm}_{param_name}"
            )
            
            # Determinar categoria do impacto
            range_size = param_config['range'][1] - param_config['range'][0]
            if value <= param_config['range'][0] + range_size * 0.33:
                impact_key = 'low'
            elif value <= param_config['range'][0] + range_size * 0.66:
                impact_key = 'medium'
            else:
                impact_key = 'high'
            
            if impact_key in param_config['impact']:
                # Cores diferentes para diferentes impactos
                if impact_key == 'low':
                    st.info(f"📊 {param_config['impact'][impact_key]}")
                elif impact_key == 'medium':
                    st.success(f"📊 {param_config['impact'][impact_key]}")
                else:
                    st.warning(f"📊 {param_config['impact'][impact_key]}")
        
        st.markdown("---")
        return value
    
    def _show_combined_impact(self, algorithm: str, user_params: Dict):
        """
        Mostra impacto combinado dos parâmetros escolhidos
        """
        st.markdown("#### 📊 **Impacto Combinado dos Parâmetros**")
        
        if algorithm == 'dbscan':
            eps = user_params.get('eps', 0.3)
            min_samples = user_params.get('min_samples', 5)
            
            if eps < 0.3 and min_samples < 6:
                st.warning("⚠️ Configuração RIGOROSA: Muitos outliers serão detectados")
            elif eps > 0.5 and min_samples > 10:
                st.info("ℹ️ Configuração TOLERANTE: Poucos outliers, grupos grandes")
            else:
                st.success("✅ Configuração EQUILIBRADA: Boa detecção de padrões")
                
        elif algorithm == 'kmeans':
            n_clusters = user_params.get('n_clusters', 'auto')
            max_iter = user_params.get('max_iter', 300)
            
            if n_clusters == 'auto':
                st.success("✅ Modo INTELIGENTE: Categorias baseadas em dados reais")
            else:
                st.info(f"ℹ️ Modo MANUAL: {n_clusters} categorias fixas")
                
        elif algorithm == 'svm':
            kernel = user_params.get('kernel', 'rbf')
            C = user_params.get('C', 1.0)
            
            if kernel == 'rbf' and 0.5 <= C <= 2.0:
                st.success("✅ Configuração RECOMENDADA para dados de estoque")
            elif C > 5.0:
                st.warning("⚠️ Risco de OVERFITTING: C muito alto")
            else:
                st.info("ℹ️ Configuração EXPERIMENTAL: Monitore performance")
    
    def show_parameters_used_section(self, algorithm_params: Dict[str, Dict]):
        """
        Mostra seção "Parâmetros Utilizados" nos resultados
        conforme exigido pelo padrão de transparência
        """
        st.markdown("#### 🎛️ **Parâmetros Utilizados na Análise**")
        
        with st.expander("Ver parâmetros detalhados", expanded=False):
            for algorithm, params in algorithm_params.items():
                st.markdown(f"**{algorithm.upper()}:**")
                
                for param, value in params.items():
                    if param != 'reasoning':
                        st.write(f"• **{param}**: {value}")
                
                # Mostrar raciocínio se disponível
                if 'reasoning' in params:
                    st.info(f"🧠 **Raciocínio**: {params['reasoning']}")
                
                st.markdown("---")


def exemplo_interface_transparencia():
    """
    Exemplo de como usar a interface de transparência no Streamlit
    """
    st.title("🧠 Configuração Transparente de Algoritmos ML")
    st.markdown("Baseado em: `context-engineering/CLAUDE.md`")
    
    # Instanciar configurador
    config = ParameterTransparencyConfig()
    
    # Seletor de algoritmo
    algoritmo = st.selectbox(
        "🔬 Escolha o algoritmo para configurar:",
        ['dbscan', 'kmeans', 'svm', 'xgboost'],
        help="Cada algoritmo tem parâmetros específicos com explicações detalhadas"
    )
    
    # Interface transparente
    parametros_usuario = config.show_transparent_config_interface(algoritmo)
    
    # Botão para executar análise
    if st.button(f"🚀 Executar {algoritmo.upper()} com parâmetros configurados"):
        st.success("✅ Análise executada com transparência total!")
        
        # Simular seção "Parâmetros Utilizados"
        config.show_parameters_used_section({
            algoritmo: {
                **parametros_usuario,
                'reasoning': f"Parâmetros otimizados para contexto de estoque"
            }
        })

if __name__ == "__main__":
    # Exemplo standalone
    print("🧠 Sistema de Transparência de Parâmetros ML")
    print("📋 Baseado em: context-engineering/CLAUDE.md")
    print("")
    print("Este exemplo demonstra como implementar transparência total")
    print("conforme especificado na documentação de engenharia contextual.")
    print("")
    print("Para usar no Streamlit:")
    print("streamlit run context-engineering/examples/parameter_transparency_config.py") 