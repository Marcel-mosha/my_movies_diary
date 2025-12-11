#!/bin/bash

# Fixed SSL Setup Script - Handles the connection refused issue

# Configuration
DOMAIN="moviediary.live"
WWW_DOMAIN="www.moviediary.live"
EMAIL="your-email@example.com"  # Replace with your email
STAGING=0  # Set to 1 for testing with Let's Encrypt staging server (to avoid rate limits)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Let's Encrypt SSL Certificate Setup (Fixed) ===${NC}"
echo ""

# Check if email is set
if [ "$EMAIL" == "your-email@example.com" ]; then
    echo -e "${RED}Error: Please set your email address in the script${NC}"
    echo "Edit the EMAIL variable in this script"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: docker-compose not found${NC}"
    exit 1
fi

# Create required directories
echo -e "${YELLOW}Step 2: Creating directories...${NC}"
mkdir -p certbot/conf certbot/www

# Download recommended TLS parameters
echo -e "${YELLOW}Step 3: Downloading TLS parameters...${NC}"
if [ ! -e "certbot/conf/options-ssl-nginx.conf" ] || [ ! -e "certbot/conf/ssl-dhparams.pem" ]; then
    mkdir -p certbot/conf
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "certbot/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "certbot/conf/ssl-dhparams.pem"
    echo -e "${GREEN}✓ Downloaded TLS parameters${NC}"
fi

# Stop any running containers
echo -e "${YELLOW}Step 4: Stopping existing containers...${NC}"
docker-compose down

# Backup SSL nginx config
echo -e "${YELLOW}Step 5: Switching to HTTP-only nginx config...${NC}"
if [ -f "nginx/nginx.conf" ]; then
    cp nginx/nginx.conf nginx/nginx.conf.ssl-backup
    echo -e "${GREEN}✓ Backed up SSL config to nginx.conf.ssl-backup${NC}"
fi

# Use HTTP-only config for initial setup
if [ -f "nginx/nginx.conf.http-only" ]; then
    cp nginx/nginx.conf.http-only nginx/nginx.conf
    echo -e "${GREEN}✓ Using HTTP-only config for certificate request${NC}"
else
    echo -e "${RED}Error: nginx/nginx.conf.http-only not found${NC}"
    exit 1
fi

# Start nginx and other services
echo -e "${YELLOW}Step 6: Starting services with HTTP-only config...${NC}"
docker-compose up -d nginx frontend backend db
sleep 5

# Check if nginx is running
if ! docker-compose ps nginx | grep -q "Up"; then
    echo -e "${RED}Error: Nginx failed to start${NC}"
    docker-compose logs nginx
    exit 1
fi
echo -e "${GREEN}✓ Nginx is running${NC}"

# Test if port 80 is accessible
echo -e "${YELLOW}Step 7: Testing port 80 accessibility...${NC}"
sleep 2
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 > /dev/null; then
    echo -e "${GREEN}✓ Port 80 is accessible locally${NC}"
else
    echo -e "${YELLOW}Warning: Cannot reach port 80 locally${NC}"
fi

# Request Let's Encrypt certificate
echo -e "${YELLOW}Step 8: Requesting Let's Encrypt certificate...${NC}"

# Join domains with -d flag
domain_args="-d $DOMAIN -d $WWW_DOMAIN"

# Select appropriate email arg
case "$EMAIL" in
    "") email_arg="--register-unsafely-without-email" ;;
    *) email_arg="--email $EMAIL" ;;
esac

# Enable staging mode if necessary
if [ $STAGING != "0" ]; then 
    staging_arg="--staging"
    echo -e "${YELLOW}Using Let's Encrypt staging server (for testing)${NC}"
else
    staging_arg=""
fi

# Run certbot
docker-compose run --rm certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size 4096 \
    --agree-tos \
    --non-interactive

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Successfully obtained SSL certificate!${NC}"
    
    # Restore SSL nginx config
    echo -e "${YELLOW}Step 9: Restoring SSL nginx configuration...${NC}"
    if [ -f "nginx/nginx.conf.ssl-backup" ]; then
        cp nginx/nginx.conf.ssl-backup nginx/nginx.conf
        echo -e "${GREEN}✓ Restored SSL config${NC}"
    fi
    
    # Restart nginx with SSL config
    echo -e "${YELLOW}Step 10: Restarting nginx with SSL...${NC}"
    docker-compose restart nginx
    sleep 3
    
    echo ""
    echo -e "${GREEN}=== SSL Setup Complete! ===${NC}"
    echo -e "${GREEN}Your site should now be accessible via HTTPS${NC}"
    echo -e "Visit: ${GREEN}https://$DOMAIN${NC}"
    echo ""
    echo -e "${YELLOW}Note: Certificates will auto-renew every 12 hours${NC}"
else
    echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting steps:${NC}"
    echo "1. Verify DNS: nslookup $DOMAIN"
    echo "2. Check if port 80 is open: curl -I http://$DOMAIN"
    echo "3. Check nginx logs: docker-compose logs nginx"
    echo "4. Check firewall: sudo ufw status"
    echo "5. Try staging mode: Set STAGING=1 in this script"
    exit 1
fi
