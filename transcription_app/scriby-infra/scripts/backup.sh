#!/bin/bash
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
