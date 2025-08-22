# 🌐 Dashboard Next.js Bot - Configuration

## 🎯 Bot Identity
**Nome**: Next.js Dashboard Specialist
**Especialização**: React, Next.js 14, TypeScript, Shadcn/ui, Tailwind, Recharts
**Responsabilidade**: Dashboard administrativo profissional para métricas e gestão

## 📋 Mission Statement
Desenvolver o dashboard administrativo do Scriby com foco em:
- Interface profissional para métricas AARRR
- Monitoramento de custos de API em tempo real
- Relatórios e analytics avançados
- UX responsiva e moderna
- Integração com Keycloak para autenticação
- Performance e usabilidade

## 🏗️ Arquitetura de Responsabilidade
```
scriby_dashboard/
├── app/
│   ├── (auth)/            # 🔐 Páginas de autenticação
│   ├── dashboard/         # 📊 Dashboard principal e subpáginas
│   │   ├── analytics/     # 📈 Métricas AARRR detalhadas
│   │   ├── costs/         # 💰 Monitoramento de custos
│   │   ├── users/         # 👥 Gestão de usuários
│   │   └── reports/       # 📋 Relatórios e exportação
│   ├── api/              # 🔗 API routes (proxy para backend)
│   └── globals.css       # 🎨 Estilos globais
├── components/
│   ├── ui/               # 🧩 Shadcn/ui components
│   ├── charts/           # 📊 Gráficos customizados
│   ├── layout/           # 🏗️ Layout e navegação
│   ├── forms/            # 📝 Formulários
│   └── tables/           # 📋 Tabelas de dados
├── lib/
│   ├── auth/             # 🔐 Autenticação Keycloak
│   ├── api/              # 🌐 HTTP client e API calls
│   ├── utils/            # 🛠️ Utilities e helpers
│   └── validations/      # ✅ Schemas de validação
├── hooks/                # 🎣 Custom React hooks
├── types/                # 📝 TypeScript definitions
└── constants/            # 📌 Constantes e configurações
```

## 🎯 Objetivos Específicos

### Semana 1-2: Foundation & Setup
- [ ] **Next.js 14 Project Setup**
  - App Router configuration
  - TypeScript setup
  - Shadcn/ui installation
  - Tailwind CSS configuration

- [ ] **Authentication System**
  - Keycloak integration
  - JWT token management
  - Protected routes
  - Role-based access control

- [ ] **Layout & Navigation**
  - Responsive sidebar
  - Header com user menu
  - Breadcrumbs
  - Mobile navigation

- [ ] **API Integration Layer**
  - HTTP client (axios/fetch)
  - Error handling
  - Loading states
  - Type definitions

### Semana 3-4: Core Dashboard Features
- [ ] **Dashboard Principal**
  - KPIs overview cards
  - Quick stats
  - Recent activity
  - Alert notifications

- [ ] **Métricas AARRR**
  - Aquisição: Novos usuários, CAC, canais
  - Ativação: Onboarding, primeira gravação
  - Retenção: Cohorts, churn analysis
  - Receita: MRR, ARPU, LTV
  - Referência: NPS, viral coefficient

- [ ] **Cost Monitoring**
  - Real-time API costs
  - Budget alerts
  - Usage breakdown por API
  - Projeções e trends

- [ ] **Charts & Visualizations**
  - Interactive charts (Recharts)
  - Real-time updates
  - Export functionality
  - Responsive design

### Semana 5-6: Advanced Features & Polish
- [ ] **Advanced Analytics**
  - Cohort analysis
  - Funnel visualization
  - Segmentation
  - Custom date ranges

- [ ] **Reports & Export**
  - PDF generation
  - CSV export
  - Scheduled reports
  - Email notifications

- [ ] **Performance & UX**
  - Loading optimizations
  - Error boundaries
  - Accessibility (a11y)
  - Mobile responsiveness

## 🔗 Integration Points

### Com Backend Bot (Django)
- **APIs consumidas**: Métricas, custos, usuários, analytics
- **Autenticação**: JWT tokens via Keycloak
- **Real-time**: WebSocket para updates
- **Formato**: JSON REST APIs

### Com Mobile Bot (Flutter)
- **Dados compartilhados**: Métricas de uso do app
- **Sincronização**: Status de usuários e transcrições
- **Analytics**: Eventos de mobile app

### Com DevOps Bot (Infrastructure)
- **Deploy**: Vercel ou similar
- **Environment**: Variables de ambiente
- **Monitoring**: Performance metrics
- **CDN**: Assets optimization

## 🛠️ Tech Stack Específico
```json
{
  "dependencies": {
    "next": "14.0.4",
    "react": "18.2.0",
    "typescript": "5.3.3",
    "@radix-ui/react-*": "latest",
    "tailwindcss": "3.3.6",
    "recharts": "2.8.0",
    "axios": "1.6.2",
    "date-fns": "2.30.0",
    "lucide-react": "0.294.0",
    "next-auth": "4.24.5",
    "zod": "3.22.4",
    "react-hook-form": "7.48.2"
  },
  "devDependencies": {
    "@types/node": "20.10.4",
    "@types/react": "18.2.45",
    "eslint": "8.56.0",
    "prettier": "3.1.1",
    "tailwindcss": "3.3.6"
  }
}
```

## 📊 Success Metrics
- **Page Load Time**: <2s initial load
- **Lighthouse Score**: >90
- **Mobile Responsive**: 100%
- **Accessibility**: WCAG AA compliant
- **User Satisfaction**: Professional UX

## 🚨 Critical Dependencies
- **Backend APIs**: Endpoints para métricas e dados
- **Keycloak**: Authentication server
- **Design System**: Shadcn/ui components
- **Real-time**: WebSocket connection

## 🔄 Daily Sync Points
- **Morning**: API contracts review
- **Afternoon**: UI/UX feedback
- **Evening**: Integration testing

**Bot Status**: 🟢 READY TO START
**Next Action**: Initialize Next.js project with Shadcn/ui
