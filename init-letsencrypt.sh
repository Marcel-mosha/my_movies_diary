#!/bin/bash

# Initialize Let's Encrypt SSL certificates for your domain
# This script will obtain SSL certificates from Let's Encrypt using Certbot

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

echo -e "${GREEN}=== Let's Encrypt SSL Certificate Setup ===${NC}"
echo ""

# Check if email is set
if [ "$EMAIL" == "your-email@example.com" ]; then
    echo -e "${RED}Error: Please set your email address in the script${NC}"
    echo "Edit the EMAIL variable in this script"
    exit 1
fi

# Check if domain is accessible
echo -e "${YELLOW}Checking if domain is accessible...${NC}"
if ! ping -c 1 $DOMAIN &> /dev/null; then
    echo -e "${YELLOW}Warning: Cannot ping $DOMAIN. Make sure your domain DNS is properly configured.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create required directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p certbot/conf certbot/www

# Download recommended TLS parameters
echo -e "${YELLOW}Downloading recommended TLS parameters...${NC}"
if [ ! -e "certbot/conf/options-ssl-nginx.conf" ] || [ ! -e "certbot/conf/ssl-dhparams.pem" ]; then
    mkdir -p certbot/conf
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "certbot/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "certbot/conf/ssl-dhparams.pem"
    echo -e "${GREEN}✓ Downloaded TLS parameters${NC}"
fi

# Create dummy certificate for nginx to start
echo -e "${YELLOW}Creating dummy certificate for $DOMAIN...${NC}"
path="/etc/letsencrypt/live/$DOMAIN"
mkdir -p "certbot/conf/live/$DOMAIN"

if [ ! -e "certbot/conf/live/$DOMAIN/fullchain.pem" ]; then
    docker-compose run --rm --entrypoint "\
        openssl req -x509 -nodes -newkey rsa:4096 -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
    echo -e "${GREEN}✓ Created dummy certificate${NC}"
else
    echo -e "${GREEN}✓ Dummy certificate already exists${NC}"
fi

# Start nginx
echo -e "${YELLOW}Starting nginx...${NC}"
docker-compose up -d nginx
echo -e "${GREEN}✓ Nginx started${NC}"

# Delete dummy certificate
echo -e "${YELLOW}Removing dummy certificate...${NC}"
docker-compose run --rm --entrypoint "\
    rm -rf /etc/letsencrypt/live/$DOMAIN && \
    rm -rf /etc/letsencrypt/archive/$DOMAIN && \
    rm -rf /etc/letsencrypt/renewal/$DOMAIN.conf" certbot
echo -e "${GREEN}✓ Dummy certificate removed${NC}"

# Request Let's Encrypt certificate
echo -e "${YELLOW}Requesting Let's Encrypt certificate for $DOMAIN...${NC}"

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

docker-compose run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal" certbot

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Successfully obtained SSL certificate!${NC}"
    
    # Reload nginx to use the new certificate
    echo -e "${YELLOW}Reloading nginx...${NC}"
    docker-compose exec nginx nginx -s reload
    echo -e "${GREEN}✓ Nginx reloaded${NC}"
    
    echo ""
    echo -e "${GREEN}=== SSL Setup Complete! ===${NC}"
    echo -e "${GREEN}Your site should now be accessible via HTTPS${NC}"
    echo -e "Visit: ${GREEN}https://$DOMAIN${NC}"
    echo ""
    echo -e "${YELLOW}Note: Certificates will auto-renew every 12 hours${NC}"
else
    echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
    echo "Please check the error messages above"
    exit 1
fi
