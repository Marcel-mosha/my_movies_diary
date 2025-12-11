#!/bin/bash

# Quick deployment script for production with SSL

echo "=========================================="
echo "  Production Deployment with SSL/TLS"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "   Copy .env.example to .env and configure it first:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
fi

# Check if init-letsencrypt.sh has been configured
if grep -q "your-email@example.com" init-letsencrypt.sh; then
    echo "⚠️  Warning: init-letsencrypt.sh still has default email!"
    echo "   Please edit init-letsencrypt.sh and set your email address"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Building Docker images..."
docker-compose build

echo ""
echo "Step 2: Setting up SSL certificates..."
./init-letsencrypt.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "Step 3: Starting all services..."
    docker-compose up -d
    
    echo ""
    echo "Step 4: Running database migrations..."
    docker-compose exec backend python manage.py migrate
    
    echo ""
    echo "Step 5: Collecting static files..."
    docker-compose exec backend python manage.py collectstatic --noinput
    
    echo ""
    echo "=========================================="
    echo "✅ Deployment Complete!"
    echo "=========================================="
    echo ""
    echo "Your application should now be running at:"
    echo "🔗 https://moviediary.live"
    echo ""
    echo "Useful commands:"
    echo "  View logs:           docker-compose logs -f"
    echo "  Check status:        docker-compose ps"
    echo "  Restart services:    docker-compose restart"
    echo "  Stop services:       docker-compose down"
    echo "  View SSL cert info:  docker-compose run --rm certbot certificates"
    echo ""
else
    echo ""
    echo "❌ SSL setup failed! Please check the errors above."
    exit 1
fi
