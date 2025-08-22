# 📚 Estratégia de Marketplace de Livros - Eskriba

## 🎯 **Visão Geral**

O Eskriba evoluirá de um app de transcrição com integração bíblica para uma **plataforma completa de leitura e anotações**, implementando um modelo híbrido de marketplace de conteúdo e publisher partner.

## 🚀 **Modelo Híbrido Implementado**

### **Opção A: Marketplace de Conteúdo**
```
📚 Livros Gratuitos
├── Open Library API (3M+ livros)
├── Project Gutenberg (60K+ clássicos)
├── Internet Archive Books
└── Bibliotecas digitais brasileiras

💰 Livros Premium
├── Redirecionamento para Google Play Books
├── Parcerias diretas com editoras
├── Livros EPIC Solutions (próprios)
└── Autores independentes (70/30 split)

📱 Funcionalidades Premium
├── Transcrição ilimitada
├── IA avançada para análise
├── Sincronização multi-dispositivo
└── Anotações ricas com formatação
```

### **Opção B: Publisher Partner (EPIC Solutions)**
```
✍️ Conteúdo Próprio EPIC
├── Quick Wins (já publicado)
├── Futuros e-books sobre produtividade
├── Livros sobre metodologia bot-orquestrada
└── Conteúdo educacional/empresarial

📖 Curadoria Especializada
├── Biblioteca premium selecionada
├── Coleções temáticas (negócios, produtividade)
├── Conteúdo exclusivo para assinantes
└── Materiais de treinamento corporativo

💎 Assinatura Premium "EPIC Library"
├── Acesso a todos os livros EPIC
├── Conteúdo exclusivo e antecipado
├── Webinars e materiais complementares
└── Suporte premium e consultoria

🤝 Parcerias Estratégicas
├── Autores independentes (70/30 split)
├── Editoras parceiras (negociação caso a caso)
├── Universidades e instituições
└── Empresas para conteúdo corporativo
```

## 💰 **Estrutura de Preços Estratégica**

### **Freemium Base**
- **Grátis:** 2h transcrição/mês + livros domínio público
- **Pessoal:** R$ 29,90/mês - 15h + previews + anotações
- **Pro:** R$ 49,90/mês - Ilimitado + upload PDFs + IA avançada

### **EPIC Library Premium**
- **EPIC Reader:** R$ 19,90/mês - Todos os livros EPIC + curadoria
- **EPIC Pro:** R$ 39,90/mês - EPIC Reader + funcionalidades Pro
- **EPIC Enterprise:** R$ 99,90/mês - Até 10 usuários + suporte

### **Vendas Individuais (Livros EPIC)**
- **E-books EPIC:** R$ 29,90 - R$ 49,90 (dependendo do conteúdo)
- **Bundles temáticos:** R$ 79,90 (3-4 livros relacionados)
- **Edições especiais:** R$ 69,90 (com materiais extras)

## 🛠️ **Arquitetura Técnica**

### **Backend (Django + PostgreSQL)**
```python
# Models principais
class Publisher(models.Model):
    name = models.CharField(max_length=200)
    is_epic = models.BooleanField(default=False)
    revenue_split = models.DecimalField(max_digits=5, decimal_places=2)

class Book(models.Model):
    title = models.CharField(max_length=300)
    publisher = models.ForeignKey(Publisher, on_delete=CASCADE)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    is_free = models.BooleanField(default=False)
    content_type = models.CharField(choices=CONTENT_TYPES)
    
class BookPurchase(models.Model):
    user = models.ForeignKey(User, on_delete=CASCADE)
    book = models.ForeignKey(Book, on_delete=CASCADE)
    purchase_date = models.DateTimeField(auto_now_add=True)
    price_paid = models.DecimalField(max_digits=8, decimal_places=2)
    invoice_number = models.CharField(max_length=50)
```

### **Integração com ERP (Odoo)**
```python
class OdooIntegration:
    def create_invoice(self, purchase_data):
        """Criar nota fiscal no Odoo automaticamente"""
        
    def sync_sales_data(self):
        """Sincronizar dados de vendas"""
        
    def update_inventory(self, book_id, quantity):
        """Atualizar estoque de e-books"""
```

### **APIs de Livros Integradas**
```python
class BookService:
    # APIs gratuitas
    async def search_open_library(self, query)
    async def get_gutenberg_book(self, book_id)
    
    # Google Books (OAuth)
    async def get_user_library(self, access_token)
    async def get_book_preview(self, book_id)
    
    # EPIC Books (próprio)
    async def get_epic_catalog(self)
    async def purchase_epic_book(self, user, book_id)
```

## 📊 **Projeção de Revenue**

### **Cenário Conservador (Ano 1)**
```
👥 Usuários: 5.000 ativos/mês
💰 Assinaturas: R$ 50.000/mês (1.000 usuários × R$ 35 médio)
📚 Vendas EPIC: R$ 15.000/mês (500 livros × R$ 30 médio)
🤝 Parcerias: R$ 5.000/mês (comissões de terceiros)
📈 Total: R$ 70.000/mês = R$ 840.000/ano
```

### **Cenário Otimista (Ano 2)**
```
👥 Usuários: 25.000 ativos/mês
💰 Assinaturas: R$ 400.000/mês (8.000 usuários × R$ 50 médio)
📚 Vendas EPIC: R$ 100.000/mês (2.500 livros × R$ 40 médio)
🤝 Parcerias: R$ 50.000/mês (marketplace consolidado)
🏢 Enterprise: R$ 150.000/mês (50 empresas × R$ 3.000)
📈 Total: R$ 700.000/mês = R$ 8.400.000/ano
```

## 🎯 **Roadmap de Implementação**

### **Fase 1: Fundação (2-3 meses)**
- [x] Google Books API + OAuth
- [x] Open Library + Project Gutenberg
- [ ] Sistema de compras EPIC
- [ ] Integração básica com Odoo
- [ ] Upload e leitura de PDFs

### **Fase 2: Marketplace (3-4 meses)**
- [ ] Sistema de parcerias com autores
- [ ] Curadoria de conteúdo
- [ ] Assinatura EPIC Library
- [ ] Analytics de leitura e engajamento
- [ ] Sistema de recomendações

### **Fase 3: Escala (6+ meses)**
- [ ] Parcerias com editoras
- [ ] Conteúdo corporativo/enterprise
- [ ] IA para curadoria automática
- [ ] Marketplace internacional
- [ ] Programa de afiliados

## 🔧 **Integração ERP/Faturamento**

### **Fluxo de Compra EPIC**
```
1. Usuário seleciona livro EPIC no app
2. Processamento de pagamento (Stripe/PagSeguro)
3. Trigger automático para Odoo:
   - Criar cliente (se novo)
   - Gerar nota fiscal
   - Registrar venda
   - Atualizar relatórios
4. Liberação automática do conteúdo no app
5. Email de confirmação + nota fiscal
```

### **Relatórios Automatizados**
- **Vendas por período** (diário/mensal/anual)
- **Performance por livro** (mais vendidos, revenue)
- **Análise de usuários** (LTV, churn, conversão)
- **Comissões de parceiros** (cálculo automático)
- **Compliance fiscal** (relatórios para contabilidade)

## 🎨 **UX/UI do Marketplace**

### **Tela Principal de Livros**
```
📚 Biblioteca Eskriba
├── 🆓 Livros Gratuitos
├── 🌟 EPIC Collection
├── 📖 Minha Biblioteca
├── 🔍 Buscar Livros
└── 💎 Assinatura Premium
```

### **Página do Livro**
```
📖 [Capa do Livro]
📝 Descrição + Preview
⭐ Avaliações dos usuários
💰 Preço / "Incluído na assinatura"
🛒 [Comprar] [Ler Preview] [Adicionar à Lista]
📊 Estatísticas de leitura
💬 Comentários da comunidade
```

## 🚀 **Diferenciais Competitivos**

### **Únicos no Mercado**
1. **Transcrição + Leitura** integradas
2. **Anotações sincronizadas** com áudio
3. **IA para análise** de conteúdo lido
4. **Marketplace híbrido** (gratuito + premium)
5. **Integração bíblica** + literatura geral
6. **Curadoria especializada** EPIC

### **Vantagens sobre Concorrentes**
- **Kindle:** Não tem transcrição nem anotações de áudio
- **Google Books:** Não tem marketplace próprio
- **Audible:** Foco apenas em audiolivros
- **Skoob:** Apenas rede social, sem leitura integrada

## 📈 **Métricas de Sucesso**

### **KPIs Principais**
- **MAU** (Monthly Active Users)
- **Conversion Rate** (free → paid)
- **ARPU** (Average Revenue Per User)
- **Book Completion Rate**
- **NPS** (Net Promoter Score)

### **Métricas EPIC Específicas**
- **Revenue per EPIC book**
- **EPIC Library subscription growth**
- **Cross-selling rate** (app → livros)
- **Author partnership ROI**

---

**Data de Criação:** 21 de Agosto de 2025  
**Responsável:** EPIC Solutions  
**Status:** Em Desenvolvimento  
**Próxima Revisão:** Setembro 2025
