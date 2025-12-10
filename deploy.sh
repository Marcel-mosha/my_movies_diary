#!/bin/bash

# Production Deployment Script for moviediary.live

echo "🚀 Starting deployment for moviediary.live..."

# Step 1: Initial SSL certificate setup (first time only)
echo "📜 Setting up SSL certificates..."
docker-compose up -d nginx
docker-compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email your-email@example.com \
    --agree-tos \
    --no-eff-email \
    -d moviediary.live \
    -d www.moviediary.live

# Step 2: Start all services
echo "🐳 Starting all Docker containers..."
docker-compose down
docker-compose up -d --build

# Step 3: Wait for database
echo "⏳ Waiting for database to be ready..."
sleep 10

# Step 4: Run migrations
echo "📊 Running database migrations..."
docker-compose exec backend python manage.py migrate

# Step 5: Collect static files
echo "📁 Collecting static files..."
docker-compose exec backend python manage.py collectstatic --noinput

# Step 6: Create superuser (optional - comment out after first run)
echo "👤 Creating superuser..."
docker-compose exec backend python manage.py createsuperuser

# Step 7: Check status
echo "✅ Checking container status..."
docker-compose ps

echo ""
echo "🎉 Deployment complete!"
echo "Your app should be accessible at:"
echo "  - https://moviediary.live"
echo "  - https://www.moviediary.live"
echo ""
echo "Admin panel: https://moviediary.live/admin/"
echo ""
echo "To view logs: docker-compose logs -f"
