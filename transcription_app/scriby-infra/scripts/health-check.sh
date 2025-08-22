#!/bin/bash

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
