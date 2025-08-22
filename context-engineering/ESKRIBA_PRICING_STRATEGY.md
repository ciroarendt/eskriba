# Eskriba - Estratégia de Pricing e Custos Operacionais

## Resumo Executivo

Estratégia de pricing dual para atender mercados internacional (USD) e brasileiro (BRL), baseada em análise detalhada de custos operacionais e benchmarking competitivo no segmento de transcrição e apps religiosos.

## Análise de Custos Operacionais (Base USD)

### Custos Fixos Mensais
- **PostgreSQL Managed (DigitalOcean)**: $15/mês (Basic)
- **Object Storage (DO Spaces)**: $5/mês (250GB)
- **Total Fixo**: $20/mês

### Custos Variáveis por Usuário (10h/mês)
- **Transcrição (OpenAI Whisper)**: $3.60/mês ($0.006/minuto × 600min)
- **Análise IA (GPT-4o Mini)**: $0.03/mês
- **Storage adicional**: ~$0/mês (dentro da franquia)
- **Bandwidth**: $0/mês (1TB grátis)
- **Total Variável**: $3.63/usuário/mês

### Economia de Escala
| Usuários | Custo Fixo/Usuário | Custo Variável | **Total/Usuário** |
|----------|-------------------|----------------|-------------------|
| 1        | $20.00           | $3.63          | **$23.63**        |
| 10       | $2.00            | $3.63          | **$5.63**         |
| 50       | $0.40            | $3.63          | **$4.03**         |
| 100+     | $0.20            | $3.63          | **$3.83**         |

## Estratégia de Pricing Dual

### 🌍 Mercado Internacional (USD)

| Plano | Preço | Horas/Mês | Features | Margem |
|-------|-------|-----------|----------|---------|
| **🆓 Free** | $0 | 2h | Transcrição básica, notas simples | - |
| **📱 Personal** | **$14.99** | 15h | Anotações ricas + Bible + Export | **73%** |
| **⭐ Pro** | **$24.99** | Ilimitado | PDF upload + Priority support | **84%** |
| **⛪ Church** | **$99.00** | 10 usuários | Admin dashboard + Bulk features | **80%** |

### 🇧🇷 Mercado Brasileiro (BRL)

| Plano | Preço | Horas/Mês | Features | Margem* |
|-------|-------|-----------|----------|---------|
| **🆓 Grátis** | R$ 0 | 2h | Transcrição básica, notas simples | - |
| **📱 Pessoal** | **R$ 29,90** | 15h | Anotações ricas + Bíblia + Export | **26%** |
| **⭐ Pro** | **R$ 49,90** | Ilimitado | PDF upload + Suporte prioritário | **56%** |
| **⛪ Igreja** | **R$ 199,90** | 10 usuários | Dashboard admin + Recursos em lote | **72%** |

*Margem calculada com custos em USD (R$ 29,90 ≈ $5.44 USD na cotação R$ 5,50)

## Benchmarking Competitivo

### Concorrentes Internacionais
- **Otter.ai**: $8.33-20/mês (individual), $20-40/usuário (business)
- **Rev.com**: $22/mês (individual), $25/usuário (business)
- **Trint**: $15-60/usuário/mês
- **Descript**: $12-24/usuário/mês

### Apps Religiosos
- **Logos Bible Software**: $15-100+/mês
- **Faithlife**: $9.99/mês
- **RightNow Media**: $12.99/mês (família)

### Posicionamento
- **Internacional**: Competitivo vs Otter.ai, premium vs apps religiosos
- **Brasil**: Acessível para classe média, premium para igrejas

## Justificativa de Pricing

### Por que $14.99 USD / R$ 29,90 BRL?

#### Mercado Internacional (USD)
- ✅ **Sweet spot** do mercado religioso ($12-20)
- ✅ **Margem saudável** de 73%
- ✅ **Competitivo** vs Otter ($8.33) com diferencial religioso
- ✅ **Valor percebido alto** pelo nicho específico

#### Mercado Brasileiro (BRL)
- ✅ **Poder de compra ajustado** (R$ 29,90 vs $14.99 direto = R$ 82,45)
- ✅ **Margem positiva** mesmo com custos em USD
- ✅ **Psicologicamente atrativo** (abaixo de R$ 30)
- ✅ **Acessível** para público religioso brasileiro

## Estratégia de Lançamento

### Fase Beta (6 meses)
- **50% desconto** em todos os planos pagos
- **Early adopters**: Lifetime deal por R$ 499 / $199 (limitado)
- **Referral program**: 1 mês grátis por indicação

### Segmentação de Público
1. **Indivíduos** → Personal/Pessoal
2. **Líderes religiosos** → Pro
3. **Igrejas/Instituições** → Church/Igreja

### Localização
- **Interface**: Português (Brasil) e Inglês
- **Pagamentos**: PIX, cartão, boleto (BR) | Stripe internacional
- **Suporte**: Horário comercial brasileiro + internacional

## Projeções Financeiras

### Cenário Conservador (12 meses)
- **100 usuários ativos**
- **Conversão**: 30% para planos pagos
- **Distribuição**: 80% Personal, 15% Pro, 5% Church

#### Brasil (70% dos usuários)
- **21 usuários Personal**: R$ 627,90/mês
- **3 usuários Pro**: R$ 149,70/mês
- **1 usuário Church**: R$ 199,90/mês
- **Subtotal BR**: R$ 977,50/mês

#### Internacional (30% dos usuários)
- **9 usuários Personal**: $134,91/mês
- **1 usuário Pro**: $24,99/mês
- **Subtotal INT**: $159,90/mês

#### Total MRR
- **Brasil**: R$ 977,50 (≈ $177,73 USD)
- **Internacional**: $159,90
- **Total**: $337,63/mês
- **Custo operacional**: ~$120/mês
- **Lucro líquido**: ~$217/mês (64% margem)

### Break-even: ~35 usuários pagantes

## Implementação Técnica

### Sistema de Cobrança
- **Internacional**: Stripe (USD, EUR)
- **Brasil**: Stripe + PIX via PagSeguro/Mercado Pago
- **Moedas**: USD, BRL (conversão automática)

### Features por Plano
```json
{
  "free": {
    "hours_per_month": 2,
    "transcription": true,
    "basic_notes": true,
    "bible_integration": false,
    "export": false
  },
  "personal": {
    "hours_per_month": 15,
    "transcription": true,
    "rich_notes": true,
    "bible_integration": true,
    "export": ["txt", "pdf"],
    "audio_snippets": true
  },
  "pro": {
    "hours_per_month": -1,
    "transcription": true,
    "rich_notes": true,
    "bible_integration": true,
    "pdf_upload": true,
    "export": ["txt", "pdf", "docx"],
    "audio_snippets": true,
    "priority_support": true
  },
  "church": {
    "users": 10,
    "hours_per_month": -1,
    "admin_dashboard": true,
    "bulk_features": true,
    "custom_branding": true,
    "dedicated_support": true
  }
}
```

## Próximos Passos

1. **Implementar sistema de billing** (Stripe + PagSeguro)
2. **Criar landing pages** com pricing localizado
3. **Configurar feature flags** por plano
4. **Testar com beta users** brasileiros e internacionais
5. **Ajustar preços** baseado em feedback e conversão

## Conclusão

A estratégia dual permite:
- **Competitividade global** com preços em USD
- **Acessibilidade local** com preços ajustados ao Brasil
- **Margens saudáveis** em ambos mercados
- **Escalabilidade** com economia de escala clara

**Recomendação**: Iniciar com mercado brasileiro (menor CAC, maior afinidade cultural) e expandir internacionalmente após validação do product-market fit.
