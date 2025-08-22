# 🏢 Integração ERP/Faturamento - Eskriba + EPIC Solutions

## 🎯 **Visão Geral Técnica**

Sistema integrado para automatizar vendas de livros EPIC, emissão de notas fiscais e gestão financeira através do Odoo ERP, garantindo compliance fiscal e eficiência operacional.

## 🛠️ **Arquitetura da Integração**

### **Stack Tecnológico**
```
📱 Frontend: Flutter (Eskriba App)
🌐 Backend: Django + PostgreSQL + Celery
🏢 ERP: Odoo (Community/Enterprise)
💳 Pagamentos: Stripe + PagSeguro + PIX
📊 Analytics: Metabase + Google Analytics
🔔 Notificações: Firebase + Email (SendGrid)
```

### **Fluxo de Dados**
```
[Eskriba App] → [Django API] → [Odoo ERP] → [Contabilidade]
      ↓              ↓             ↓            ↓
   [Usuário]    [Processamento]  [NF-e]    [Relatórios]
```

## 💰 **Sistema de Vendas EPIC**

### **Models Django**
```python
# models.py
class EPICBook(models.Model):
    title = models.CharField(max_length=300)
    isbn = models.CharField(max_length=13, unique=True)
    price_brl = models.DecimalField(max_digits=8, decimal_places=2)
    price_usd = models.DecimalField(max_digits=8, decimal_places=2)
    content_file = models.FileField(upload_to='epic_books/')
    cover_image = models.ImageField(upload_to='epic_covers/')
    description = models.TextField()
    category = models.CharField(max_length=100)
    publication_date = models.DateField()
    is_active = models.BooleanField(default=True)
    odoo_product_id = models.IntegerField(null=True, blank=True)
    
    class Meta:
        db_table = 'epic_books'

class BookPurchase(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    book = models.ForeignKey(EPICBook, on_delete=models.CASCADE)
    purchase_date = models.DateTimeField(auto_now_add=True)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='BRL')
    payment_method = models.CharField(max_length=50)
    payment_id = models.CharField(max_length=100)
    invoice_number = models.CharField(max_length=50, null=True)
    odoo_sale_order_id = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=20, default='pending')
    
    class Meta:
        db_table = 'book_purchases'
        unique_together = ['user', 'book']

class EPICSubscription(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    plan = models.CharField(max_length=50)  # epic_reader, epic_pro
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    is_active = models.BooleanField(default=True)
    auto_renew = models.BooleanField(default=True)
    stripe_subscription_id = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'epic_subscriptions'
```

### **API de Vendas**
```python
# views.py
class EPICBookPurchaseView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, book_id):
        try:
            book = EPICBook.objects.get(id=book_id, is_active=True)
            user = request.user
            
            # Verificar se já possui o livro
            if BookPurchase.objects.filter(user=user, book=book, status='completed').exists():
                return Response({'error': 'Livro já adquirido'}, status=400)
            
            # Processar pagamento
            payment_result = self.process_payment(request.data, book.price_brl)
            
            if payment_result['success']:
                # Criar registro de compra
                purchase = BookPurchase.objects.create(
                    user=user,
                    book=book,
                    amount_paid=book.price_brl,
                    payment_method=payment_result['method'],
                    payment_id=payment_result['id'],
                    status='completed'
                )
                
                # Trigger async para Odoo
                create_odoo_sale_order.delay(purchase.id)
                
                # Liberar acesso ao livro
                grant_book_access.delay(user.id, book.id)
                
                return Response({
                    'success': True,
                    'purchase_id': purchase.id,
                    'download_url': f'/api/books/{book.id}/download/'
                })
            
        except Exception as e:
            logger.error(f"Erro na compra: {e}")
            return Response({'error': 'Erro no processamento'}, status=500)
```

## 🏢 **Integração Odoo**

### **Configuração Odoo**
```python
# odoo_client.py
import xmlrpc.client

class OdooClient:
    def __init__(self):
        self.url = settings.ODOO_URL
        self.db = settings.ODOO_DB
        self.username = settings.ODOO_USERNAME
        self.password = settings.ODOO_PASSWORD
        self.uid = None
        self.authenticate()
    
    def authenticate(self):
        common = xmlrpc.client.ServerProxy(f'{self.url}/xmlrpc/2/common')
        self.uid = common.authenticate(self.db, self.username, self.password, {})
        
    def execute(self, model, method, *args, **kwargs):
        models = xmlrpc.client.ServerProxy(f'{self.url}/xmlrpc/2/object')
        return models.execute_kw(
            self.db, self.uid, self.password,
            model, method, args, kwargs
        )

    def create_customer(self, user_data):
        """Criar cliente no Odoo"""
        customer_data = {
            'name': user_data['full_name'],
            'email': user_data['email'],
            'phone': user_data.get('phone', ''),
            'is_company': False,
            'customer_rank': 1,
            'category_id': [(6, 0, [settings.ODOO_CUSTOMER_TAG_ID])]
        }
        return self.execute('res.partner', 'create', [customer_data])
    
    def create_product(self, book_data):
        """Criar produto (livro) no Odoo"""
        product_data = {
            'name': book_data['title'],
            'default_code': book_data['isbn'],
            'type': 'service',  # E-book é serviço
            'categ_id': settings.ODOO_EBOOK_CATEGORY_ID,
            'list_price': float(book_data['price_brl']),
            'taxes_id': [(6, 0, [settings.ODOO_EBOOK_TAX_ID])],
            'description': book_data['description']
        }
        return self.execute('product.product', 'create', [product_data])
    
    def create_sale_order(self, purchase_data):
        """Criar pedido de venda no Odoo"""
        order_data = {
            'partner_id': purchase_data['customer_id'],
            'date_order': purchase_data['purchase_date'],
            'order_line': [(0, 0, {
                'product_id': purchase_data['product_id'],
                'product_uom_qty': 1,
                'price_unit': float(purchase_data['amount_paid'])
            })]
        }
        order_id = self.execute('sale.order', 'create', [order_data])
        
        # Confirmar pedido automaticamente
        self.execute('sale.order', 'action_confirm', [order_id])
        
        return order_id
    
    def create_invoice(self, sale_order_id):
        """Criar e validar fatura"""
        # Criar fatura a partir do pedido
        invoice_data = self.execute(
            'sale.order', 'action_invoice_create', [sale_order_id]
        )
        
        invoice_id = invoice_data[0] if invoice_data else None
        
        if invoice_id:
            # Validar fatura automaticamente
            self.execute('account.move', 'action_post', [invoice_id])
            
            # Obter número da fatura
            invoice = self.execute(
                'account.move', 'read', [invoice_id], 
                {'fields': ['name', 'amount_total']}
            )[0]
            
            return {
                'invoice_id': invoice_id,
                'invoice_number': invoice['name'],
                'amount_total': invoice['amount_total']
            }
        
        return None
```

### **Tasks Celery para Integração**
```python
# tasks.py
from celery import shared_task
from .odoo_client import OdooClient

@shared_task
def create_odoo_sale_order(purchase_id):
    """Criar pedido de venda no Odoo após compra"""
    try:
        purchase = BookPurchase.objects.get(id=purchase_id)
        odoo = OdooClient()
        
        # Verificar/criar cliente
        customer_id = get_or_create_odoo_customer(purchase.user, odoo)
        
        # Verificar/criar produto
        product_id = get_or_create_odoo_product(purchase.book, odoo)
        
        # Criar pedido de venda
        order_id = odoo.create_sale_order({
            'customer_id': customer_id,
            'product_id': product_id,
            'amount_paid': purchase.amount_paid,
            'purchase_date': purchase.purchase_date.isoformat()
        })
        
        # Atualizar registro de compra
        purchase.odoo_sale_order_id = order_id
        purchase.save()
        
        # Criar fatura
        create_odoo_invoice.delay(purchase_id, order_id)
        
        logger.info(f"Pedido Odoo criado: {order_id} para compra {purchase_id}")
        
    except Exception as e:
        logger.error(f"Erro ao criar pedido Odoo: {e}")
        # Retry em caso de erro
        raise self.retry(countdown=60, max_retries=3)

@shared_task
def create_odoo_invoice(purchase_id, sale_order_id):
    """Criar e processar fatura no Odoo"""
    try:
        purchase = BookPurchase.objects.get(id=purchase_id)
        odoo = OdooClient()
        
        # Criar fatura
        invoice_result = odoo.create_invoice(sale_order_id)
        
        if invoice_result:
            # Atualizar registro com número da nota fiscal
            purchase.invoice_number = invoice_result['invoice_number']
            purchase.save()
            
            # Enviar nota fiscal por email
            send_invoice_email.delay(purchase_id, invoice_result)
            
            logger.info(f"Fatura criada: {invoice_result['invoice_number']}")
        
    except Exception as e:
        logger.error(f"Erro ao criar fatura: {e}")
        raise self.retry(countdown=120, max_retries=2)

@shared_task
def sync_odoo_data():
    """Sincronização periódica de dados com Odoo"""
    try:
        odoo = OdooClient()
        
        # Sincronizar vendas do último dia
        yesterday = timezone.now() - timedelta(days=1)
        purchases = BookPurchase.objects.filter(
            purchase_date__gte=yesterday,
            odoo_sale_order_id__isnull=True
        )
        
        for purchase in purchases:
            create_odoo_sale_order.delay(purchase.id)
        
        # Verificar status de faturas
        pending_invoices = BookPurchase.objects.filter(
            invoice_number__isnull=True,
            odoo_sale_order_id__isnull=False
        )
        
        for purchase in pending_invoices:
            check_invoice_status.delay(purchase.id)
            
    except Exception as e:
        logger.error(f"Erro na sincronização: {e}")
```

## 💳 **Sistema de Pagamentos**

### **Integração Multi-Gateway**
```python
# payment_service.py
class PaymentService:
    def __init__(self):
        self.stripe = stripe
        self.stripe.api_key = settings.STRIPE_SECRET_KEY
    
    def process_payment(self, payment_data, amount_brl):
        """Processar pagamento com múltiplos gateways"""
        method = payment_data.get('method', 'card')
        
        if method == 'card':
            return self.process_stripe_payment(payment_data, amount_brl)
        elif method == 'pix':
            return self.process_pix_payment(payment_data, amount_brl)
        elif method == 'boleto':
            return self.process_boleto_payment(payment_data, amount_brl)
        else:
            raise ValueError(f"Método de pagamento não suportado: {method}")
    
    def process_stripe_payment(self, payment_data, amount_brl):
        """Pagamento via cartão (Stripe)"""
        try:
            intent = stripe.PaymentIntent.create(
                amount=int(amount_brl * 100),  # Centavos
                currency='brl',
                payment_method=payment_data['payment_method_id'],
                confirm=True,
                return_url=settings.STRIPE_RETURN_URL
            )
            
            return {
                'success': True,
                'method': 'card',
                'id': intent.id,
                'status': intent.status
            }
            
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def process_pix_payment(self, payment_data, amount_brl):
        """Pagamento via PIX (PagSeguro/Mercado Pago)"""
        # Implementar integração PIX
        pass
    
    def create_subscription(self, user, plan_type):
        """Criar assinatura EPIC Library"""
        price_map = {
            'epic_reader': settings.EPIC_READER_PRICE_ID,
            'epic_pro': settings.EPIC_PRO_PRICE_ID
        }
        
        try:
            subscription = stripe.Subscription.create(
                customer=user.stripe_customer_id,
                items=[{'price': price_map[plan_type]}],
                payment_behavior='default_incomplete',
                expand=['latest_invoice.payment_intent']
            )
            
            return {
                'success': True,
                'subscription_id': subscription.id,
                'client_secret': subscription.latest_invoice.payment_intent.client_secret
            }
            
        except stripe.error.StripeError as e:
            return {'success': False, 'error': str(e)}
```

## 📊 **Relatórios e Analytics**

### **Dashboard Financeiro**
```python
# analytics.py
class EPICAnalytics:
    def get_sales_report(self, start_date, end_date):
        """Relatório de vendas EPIC"""
        purchases = BookPurchase.objects.filter(
            purchase_date__range=[start_date, end_date],
            status='completed'
        )
        
        return {
            'total_sales': purchases.count(),
            'total_revenue': purchases.aggregate(Sum('amount_paid'))['amount_paid__sum'],
            'top_books': self.get_top_selling_books(purchases),
            'revenue_by_day': self.get_daily_revenue(purchases),
            'conversion_rate': self.calculate_conversion_rate(start_date, end_date)
        }
    
    def get_subscription_metrics(self):
        """Métricas de assinatura EPIC Library"""
        active_subs = EPICSubscription.objects.filter(is_active=True)
        
        return {
            'total_subscribers': active_subs.count(),
            'mrr': self.calculate_mrr(active_subs),
            'churn_rate': self.calculate_churn_rate(),
            'ltv': self.calculate_ltv(),
            'plan_distribution': active_subs.values('plan').annotate(count=Count('id'))
        }
    
    def get_odoo_sync_status(self):
        """Status da sincronização com Odoo"""
        total_purchases = BookPurchase.objects.filter(status='completed').count()
        synced_purchases = BookPurchase.objects.filter(
            status='completed',
            odoo_sale_order_id__isnull=False
        ).count()
        
        return {
            'sync_percentage': (synced_purchases / total_purchases) * 100,
            'pending_sync': total_purchases - synced_purchases,
            'last_sync': cache.get('last_odoo_sync'),
            'sync_errors': self.get_sync_errors()
        }
```

## 🔧 **Configuração e Deploy**

### **Variáveis de Ambiente**
```bash
# .env
# Odoo Configuration
ODOO_URL=https://seu-odoo.com
ODOO_DB=eskriba_production
ODOO_USERNAME=api_user
ODOO_PASSWORD=secure_password
ODOO_CUSTOMER_TAG_ID=1
ODOO_EBOOK_CATEGORY_ID=2
ODOO_EBOOK_TAX_ID=3

# Payment Gateways
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# EPIC Pricing
EPIC_READER_PRICE_ID=price_epic_reader
EPIC_PRO_PRICE_ID=price_epic_pro
```

### **Celery Configuration**
```python
# celery.py
from celery import Celery
from celery.schedules import crontab

app = Celery('eskriba')

app.conf.beat_schedule = {
    'sync-odoo-data': {
        'task': 'books.tasks.sync_odoo_data',
        'schedule': crontab(minute=0, hour='*/2'),  # A cada 2 horas
    },
    'process-pending-invoices': {
        'task': 'books.tasks.process_pending_invoices',
        'schedule': crontab(minute=30, hour='*/6'),  # A cada 6 horas
    },
    'generate-daily-reports': {
        'task': 'analytics.tasks.generate_daily_reports',
        'schedule': crontab(minute=0, hour=8),  # 8h da manhã
    },
}
```

## 🚀 **Próximos Passos de Implementação**

### **Sprint 1 (2 semanas)**
- [ ] Configurar modelos Django para livros EPIC
- [ ] Implementar API de compras básica
- [ ] Integração Stripe para pagamentos
- [ ] Setup inicial Odoo + conexão

### **Sprint 2 (2 semanas)**
- [ ] Tasks Celery para sincronização Odoo
- [ ] Sistema de emissão de notas fiscais
- [ ] Testes automatizados da integração
- [ ] Dashboard básico de vendas

### **Sprint 3 (2 semanas)**
- [ ] Sistema de assinaturas EPIC Library
- [ ] Relatórios avançados e analytics
- [ ] Integração PIX e outros métodos
- [ ] Monitoramento e alertas

---

**Responsável Técnico:** EPIC Solutions  
**Data de Criação:** 21 de Agosto de 2025  
**Status:** Planejamento Técnico  
**Estimativa:** 6-8 semanas para MVP completo
