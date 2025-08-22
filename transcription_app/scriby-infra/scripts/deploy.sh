#!/bin/bash
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
