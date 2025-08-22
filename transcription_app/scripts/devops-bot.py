#!/usr/bin/env python3
"""
DevOps Bot - Infrastructure & Deployment Automation
Specialized bot for DevOps and infrastructure tasks
"""

import os
import sys
import subprocess
import time
import argparse
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('DevOpsBot')

class DevOpsBot:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.infra_path = self.project_path / 'scriby-infra'
        
    def setup_docker_containers(self):
        """Setup Docker containers for all services"""
        logger.info("🔧 Setting up Docker containers...")
        
        # Create infra directory
        self.infra_path.mkdir(exist_ok=True)
        
        # Main docker-compose.yml
        docker_compose = '''version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: scriby_db
      POSTGRES_USER: scriby_user
      POSTGRES_PASSWORD: scriby_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    ports:
      - "5432:5432"
    networks:
      - scriby-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U scriby_user -d scriby_db"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis for Celery
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - scriby-network
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Django Backend
  backend:
    build:
      context: ../scriby-backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=postgresql://scriby_user:scriby_pass@postgres:5432/scriby_db
      - REDIS_URL=redis://redis:6379/0
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - KEYCLOAK_URL=http://keycloak:8080
    volumes:
      - ../scriby-backend:/app
      - media_files:/app/media
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - scriby-network
    command: >
      sh -c "python manage.py migrate &&
             python manage.py collectstatic --noinput &&
             gunicorn scriby_backend.wsgi:application --bind 0.0.0.0:8000"

  # Celery Worker
  celery-worker:
    build:
      context: ../scriby-backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=postgresql://scriby_user:scriby_pass@postgres:5432/scriby_db
      - REDIS_URL=redis://redis:6379/0
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    volumes:
      - ../scriby-backend:/app
      - media_files:/app/media
    depends_on:
      - postgres
      - redis
      - backend
    networks:
      - scriby-network
    command: celery -A scriby_backend worker -l info

  # Celery Beat (Scheduler)
  celery-beat:
    build:
      context: ../scriby-backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=postgresql://scriby_user:scriby_pass@postgres:5432/scriby_db
      - REDIS_URL=redis://redis:6379/0
    volumes:
      - ../scriby-backend:/app
    depends_on:
      - postgres
      - redis
      - backend
    networks:
      - scriby-network
    command: celery -A scriby_backend beat -l info

  # Next.js Dashboard
  dashboard:
    build:
      context: ../scriby-dashboard
      dockerfile: Dockerfile
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000/api
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=http://localhost:3000
    volumes:
      - ../scriby-dashboard:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    networks:
      - scriby-network
    command: npm run dev

  # Keycloak (Authentication)
  keycloak:
    image: quay.io/keycloak/keycloak:22.0
    environment:
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=admin123
      - KC_DB=postgres
      - KC_DB_URL=jdbc:postgresql://postgres:5432/scriby_db
      - KC_DB_USERNAME=scriby_user
      - KC_DB_PASSWORD=scriby_pass
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - scriby-network
    command: start-dev

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend
      - dashboard
    networks:
      - scriby-network

  # Monitoring with Prometheus
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - scriby-network

  # Grafana for Dashboards
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - scriby-network

volumes:
  postgres_data:
  redis_data:
  media_files:
  prometheus_data:
  grafana_data:

networks:
  scriby-network:
    driver: bridge
'''
        
        # Nginx configuration
        nginx_config = '''events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }
    
    upstream dashboard {
        server dashboard:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        # Dashboard
        location / {
            proxy_pass http://dashboard;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Admin
        location /admin/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Static files
        location /static/ {
            proxy_pass http://backend;
        }
        
        # Media files
        location /media/ {
            proxy_pass http://backend;
        }
    }
}'''
        
        # Prometheus configuration
        prometheus_config = '''global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'django'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
      
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']
'''
        
        # Write configuration files
        with open(self.infra_path / 'docker-compose.yml', 'w') as f:
            f.write(docker_compose)
            
        with open(self.infra_path / 'nginx.conf', 'w') as f:
            f.write(nginx_config)
            
        with open(self.infra_path / 'prometheus.yml', 'w') as f:
            f.write(prometheus_config)
            
        logger.info("✅ Docker containers setup completed")
        
    def create_dockerfiles(self):
        """Create Dockerfiles for services"""
        logger.info("🔧 Creating Dockerfiles...")
        
        # Backend Dockerfile
        backend_dockerfile = '''FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    libpq-dev \\
    ffmpeg \\
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create media directory
RUN mkdir -p media/recordings

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:8000/health/ || exit 1

# Default command
CMD ["gunicorn", "scriby_backend.wsgi:application", "--bind", "0.0.0.0:8000"]
'''
        
        # Dashboard Dockerfile
        dashboard_dockerfile = '''FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["npm", "start"]
'''
        
        # Write Dockerfiles
        backend_path = self.project_path / 'scriby-backend'
        dashboard_path = self.project_path / 'scriby-dashboard'
        
        backend_path.mkdir(exist_ok=True)
        dashboard_path.mkdir(exist_ok=True)
        
        with open(backend_path / 'Dockerfile', 'w') as f:
            f.write(backend_dockerfile)
            
        with open(dashboard_path / 'Dockerfile', 'w') as f:
            f.write(dashboard_dockerfile)
            
        logger.info("✅ Dockerfiles created")
        
    def setup_cicd_pipeline(self):
        """Setup CI/CD pipeline with GitHub Actions"""
        logger.info("🔧 Setting up CI/CD pipeline...")
        
        github_workflow = '''name: Scriby CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
          
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Install Python dependencies
      run: |
        cd scriby-backend
        pip install -r requirements.txt
        
    - name: Install Node.js dependencies
      run: |
        cd scriby-dashboard
        npm ci
        
    - name: Run Python tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        REDIS_URL: redis://localhost:6379/0
      run: |
        cd scriby-backend
        python manage.py test
        
    - name: Run Node.js tests
      run: |
        cd scriby-dashboard
        npm test
        
    - name: Run Flutter tests
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.8'
      run: |
        cd scriby
        flutter test

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Build and push Backend image
      uses: docker/build-push-action@v5
      with:
        context: ./scriby-backend
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-backend:latest
        
    - name: Build and push Dashboard image
      uses: docker/build-push-action@v5
      with:
        context: ./scriby-dashboard
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-dashboard:latest
        
    - name: Deploy to Production
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.PROD_HOST }}
        username: ${{ secrets.PROD_USER }}
        key: ${{ secrets.PROD_SSH_KEY }}
        script: |
          cd /opt/scriby
          docker-compose pull
          docker-compose up -d
          docker system prune -f
'''
        
        # Create .github/workflows directory
        workflows_dir = self.project_path / '.github/workflows'
        workflows_dir.mkdir(parents=True, exist_ok=True)
        
        with open(workflows_dir / 'ci-cd.yml', 'w') as f:
            f.write(github_workflow)
            
        logger.info("✅ CI/CD pipeline setup completed")
        
    def setup_monitoring(self):
        """Setup monitoring and logging"""
        logger.info("🔧 Setting up monitoring...")
        
        # Grafana dashboard configuration
        grafana_dashboard = '''{
  "dashboard": {
    "id": null,
    "title": "Scriby Application Metrics",
    "tags": ["scriby"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "API Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "django_http_requests_latency_seconds_histogram_quantile{quantile=\"0.95\"}",
            "legendFormat": "95th percentile"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "Active connections"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Celery Task Queue",
        "type": "graph",
        "targets": [
          {
            "expr": "celery_tasks_total",
            "legendFormat": "Total tasks"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 4,
        "title": "Redis Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "redis_memory_used_bytes",
            "legendFormat": "Memory used"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {"from": "now-1h", "to": "now"},
    "refresh": "30s"
  }
}'''
        
        # Create monitoring directories
        grafana_dir = self.infra_path / 'grafana/dashboards'
        grafana_dir.mkdir(parents=True, exist_ok=True)
        
        with open(grafana_dir / 'scriby-dashboard.json', 'w') as f:
            f.write(grafana_dashboard)
            
        # Logging configuration
        logging_config = '''version: 1
disable_existing_loggers: False

formatters:
  verbose:
    format: '{levelname} {asctime} {module} {process:d} {thread:d} {message}'
    style: '{'
  simple:
    format: '{levelname} {message}'
    style: '{'

handlers:
  file:
    level: INFO
    class: logging.FileHandler
    filename: /app/logs/django.log
    formatter: verbose
  console:
    level: DEBUG
    class: logging.StreamHandler
    formatter: simple

loggers:
  django:
    handlers: [file, console]
    level: INFO
    propagate: True
  scriby_backend:
    handlers: [file, console]
    level: DEBUG
    propagate: True

root:
  level: INFO
  handlers: [console]
'''
        
        with open(self.infra_path / 'logging.yml', 'w') as f:
            f.write(logging_config)
            
        logger.info("✅ Monitoring setup completed")
        
    def create_deployment_scripts(self):
        """Create deployment and management scripts"""
        logger.info("🔧 Creating deployment scripts...")
        
        # Deployment script
        deploy_script = '''#!/bin/bash
set -e

echo "🚀 Deploying Scriby Application..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create necessary directories
mkdir -p logs
mkdir -p media/recordings
mkdir -p ssl

# Set environment variables
export OPENAI_API_KEY=${OPENAI_API_KEY:-"your-openai-key-here"}
export NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-$(openssl rand -base64 32)}

# Build and start services
echo "📦 Building containers..."
docker-compose build

echo "🔄 Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run migrations
echo "🗄️ Running database migrations..."
docker-compose exec -T backend python manage.py migrate

# Create superuser if it doesn't exist
echo "👤 Creating admin user..."
docker-compose exec -T backend python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@scriby.com', 'admin123')
    print('Admin user created')
else:
    print('Admin user already exists')
"

# Collect static files
echo "📁 Collecting static files..."
docker-compose exec -T backend python manage.py collectstatic --noinput

echo "✅ Deployment completed successfully!"
echo ""
echo "🌐 Services are now available at:"
echo "  - Dashboard: http://localhost:3000"
echo "  - API: http://localhost:8000/api"
echo "  - Admin: http://localhost:8000/admin"
echo "  - Keycloak: http://localhost:8080"
echo "  - Grafana: http://localhost:3001"
echo "  - Prometheus: http://localhost:9090"
echo ""
echo "📊 To view logs: docker-compose logs -f [service-name]"
echo "🛑 To stop: docker-compose down"
'''
        
        # Backup script
        backup_script = '''#!/bin/bash
set -e

BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "💾 Creating backup..."

# Backup database
docker-compose exec -T postgres pg_dump -U scriby_user scriby_db > $BACKUP_DIR/database.sql

# Backup media files
docker cp $(docker-compose ps -q backend):/app/media $BACKUP_DIR/

# Backup configuration
cp -r . $BACKUP_DIR/config/

echo "✅ Backup completed: $BACKUP_DIR"
'''
        
        # Health check script
        health_script = '''#!/bin/bash

echo "🏥 Scriby Health Check"
echo "===================="

# Check services
services=("postgres" "redis" "backend" "dashboard" "keycloak")

for service in "${services[@]}"; do
    if docker-compose ps $service | grep -q "Up"; then
        echo "✅ $service: Running"
    else
        echo "❌ $service: Not running"
    fi
done

# Check endpoints
endpoints=(
    "http://localhost:8000/health/"
    "http://localhost:3000/api/health"
    "http://localhost:8080/health"
)

for endpoint in "${endpoints[@]}"; do
    if curl -f -s $endpoint > /dev/null; then
        echo "✅ $endpoint: Healthy"
    else
        echo "❌ $endpoint: Unhealthy"
    fi
done
'''
        
        # Write scripts
        scripts_dir = self.infra_path / 'scripts'
        scripts_dir.mkdir(exist_ok=True)
        
        scripts = {
            'deploy.sh': deploy_script,
            'backup.sh': backup_script,
            'health-check.sh': health_script
        }
        
        for script_name, script_content in scripts.items():
            script_path = scripts_dir / script_name
            with open(script_path, 'w') as f:
                f.write(script_content)
            # Make executable
            os.chmod(script_path, 0o755)
            
        logger.info("✅ Deployment scripts created")

def main():
    parser = argparse.ArgumentParser(description='DevOps Bot - Infrastructure Setup')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    args = parser.parse_args()
    
    bot = DevOpsBot("/Users/ciroarendt/CURSOR/APP_11me/transcription_app")
    
    print("🤖 DevOps Bot - Starting Infrastructure Setup")
    print("=" * 50)
    
    if args.continuous:
        print("🔄 Running in CONTINUOUS mode...")
        cycle = 0
        while True:
            try:
                cycle += 1
                print(f"\n🔄 Continuous cycle #{cycle}")
                
                # Run infrastructure tasks
                bot.setup_docker_containers()
                bot.create_dockerfiles()
                bot.setup_cicd_pipeline()
                bot.setup_monitoring()
                bot.create_deployment_scripts()
                
                print(f"✅ Cycle #{cycle} completed")
                time.sleep(30)  # Wait 30 seconds between cycles
                
            except KeyboardInterrupt:
                print("\n🛑 Continuous mode stopped")
                break
            except Exception as e:
                print(f"❌ Error in cycle #{cycle}: {e}")
                time.sleep(10)  # Wait before retry
    else:
        # Single run mode
        try:
            bot.setup_docker_containers()
            bot.create_dockerfiles()
            bot.setup_cicd_pipeline()
            bot.setup_monitoring()
            bot.create_deployment_scripts()
            
            print("🎉 DevOps Bot completed successfully!")
            print("📋 Next steps:")
            print("  1. cd scriby-infra")
            print("  2. ./scripts/deploy.sh")
            print("  3. ./scripts/health-check.sh")
            
        except Exception as e:
            logger.error(f"❌ DevOps Bot failed: {e}")
            sys.exit(1)

if __name__ == "__main__":
    main()
