# 🐍 Backend Django Bot - Configuration

## 🎯 Bot Identity
**Nome**: Django Backend Specialist
**Especialização**: Python, Django, DRF, Celery, PostgreSQL, OpenAI APIs
**Responsabilidade**: Backend completo com APIs robustas para transcrição e análise

## 📋 Mission Statement
Desenvolver o backend completo do Scriby com foco em:
- APIs REST robustas com Django REST Framework
- Processamento assíncrono de áudio com Celery
- Integração com OpenAI Whisper e GPT-4o
- Sistema de métricas AARRR
- Autenticação enterprise com Keycloak
- Performance e escalabilidade

## 🏗️ Arquitetura de Responsabilidade
```
scriby_backend/
├── apps/
│   ├── users/              # 👤 Gestão de usuários e perfis
│   ├── transcriptions/     # 🎙️ Upload, processamento e armazenamento de áudio
│   ├── analytics/          # 📊 Métricas AARRR e business intelligence
│   ├── billing/            # 💰 Tracking de custos de API e billing
│   └── notifications/      # 🔔 Sistema de notificações
├── celery_app/            # ⚡ Configuração e tasks do Celery
├── config/                # ⚙️ Settings e configurações Django
├── integrations/          # 🔗 APIs externas (OpenAI, Google, etc)
├── utils/                 # 🛠️ Utilities e helpers
└── requirements/          # 📦 Dependências por ambiente
```

## 🎯 Objetivos Específicos

### Semana 1-2: Foundation & Setup
- [ ] **Django Project Setup**
  - Estrutura modular com apps separadas
  - Settings por ambiente (dev/staging/prod)
  - Database configuration (PostgreSQL)
  - Django REST Framework setup

- [ ] **Models & Database**
  - User model customizado
  - Transcription model (áudio + metadata)
  - Analytics models (métricas AARRR)
  - Billing models (API costs tracking)
  - Migrations e fixtures

- [ ] **Celery Configuration**
  - Redis como message broker
  - Task routing e queues
  - Monitoring com Flower
  - Error handling e retry logic

### Semana 3-4: Core APIs & Integrations
- [ ] **Authentication & Authorization**
  - Keycloak integration
  - JWT token handling
  - Permission classes
  - User management APIs

- [ ] **Transcription APIs**
  - File upload endpoints
  - OpenAI Whisper integration
  - Celery tasks para processamento
  - Status tracking e webhooks

- [ ] **AI Analysis APIs**
  - GPT-4o Mini integration
  - Text analysis e summarization
  - Topic extraction
  - Action items identification

- [ ] **Analytics APIs**
  - AARRR metrics endpoints
  - Real-time data aggregation
  - Cost tracking APIs
  - Dashboard data endpoints

### Semana 5-6: Optimization & Production
- [ ] **Performance Optimization**
  - Database query optimization
  - Caching strategies (Redis)
  - API response optimization
  - Pagination e filtering

- [ ] **Security & Monitoring**
  - Security audit
  - Rate limiting
  - Logging e monitoring
  - Error tracking (Sentry)

- [ ] **Documentation & Testing**
  - API documentation (Swagger/OpenAPI)
  - Unit tests (>80% coverage)
  - Integration tests
  - Load testing

## 🔗 Integration Points

### Com Dashboard Bot (Next.js)
- **APIs fornecidas**: Métricas AARRR, custos, analytics
- **Formato**: JSON REST APIs
- **Autenticação**: JWT tokens via Keycloak
- **Real-time**: WebSocket para updates em tempo real

### Com Mobile Bot (Flutter)
- **APIs fornecidas**: Upload, transcrição, sincronização
- **Formato**: JSON REST APIs
- **Offline**: Sync endpoints para dados offline
- **Push**: Notificações via FCM

### Com DevOps Bot (Infrastructure)
- **Containers**: Docker images para Django + Celery
- **Database**: PostgreSQL migrations
- **Cache**: Redis configuration
- **Monitoring**: Health check endpoints

## 🛠️ Tech Stack Específico
```python
# Core Framework
Django==4.2.7
djangorestframework==3.14.0
django-cors-headers==4.3.1

# Database & Cache
psycopg2-binary==2.9.7
redis==5.0.1
django-redis==5.4.0

# Async Processing
celery==5.3.4
flower==2.0.1

# Authentication
django-oauth-toolkit==1.7.1
PyJWT==2.8.0

# AI/ML Integrations
openai==1.3.5
requests==2.31.0

# Monitoring & Utils
sentry-sdk==1.38.0
django-extensions==3.2.3
python-decouple==3.8
```

## 📊 Success Metrics
- **API Response Time**: <200ms average
- **Test Coverage**: >80%
- **Uptime**: 99.9%
- **Concurrent Users**: Support 1000+
- **Audio Processing**: <30s for 10min audio

## 🚨 Critical Dependencies
- **Database**: PostgreSQL deve estar configurado primeiro
- **Cache**: Redis para Celery e caching
- **External APIs**: OpenAI API keys configuradas
- **Authentication**: Keycloak instance running

## 🔄 Daily Sync Points
- **Morning**: Status update e blockers
- **Afternoon**: Integration checkpoints
- **Evening**: Code review e merge conflicts

**Bot Status**: 🟢 READY TO START
**Next Action**: Initialize Django project structure
