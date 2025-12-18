#!/bin/bash

# This script initializes Let's Encrypt SSL certificates for your domain
# Run this ONCE on your production server before starting the application

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

# Configuration
domains=(moviediary.live www.moviediary.live)
rsa_key_size=4096
data_path="./certbot"
email="your-email@example.com" # Replace with your email
staging=0 # Set to 1 for testing, 0 for production

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Let's Encrypt SSL Certificate Initialization ===${NC}"
echo ""
echo -e "${YELLOW}Domains:${NC} ${domains[@]}"
echo -e "${YELLOW}Email:${NC} $email"
echo ""

# Validate email
if [ "$email" = "your-email@example.com" ]; then
  echo -e "${RED}Error: Please replace 'your-email@example.com' with your actual email in this script${NC}"
  exit 1
fi

# Create directory for certbot files
if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo -e "${GREEN}### Downloading recommended TLS parameters...${NC}"
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo ""
fi

echo -e "${GREEN}### Creating dummy certificate for ${domains[0]}...${NC}"
path="/etc/letsencrypt/live/${domains[0]}"
mkdir -p "$data_path/conf/live/${domains[0]}"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo ""

echo -e "${GREEN}### Starting nginx...${NC}"
docker-compose up --force-recreate -d nginx
echo ""

echo -e "${GREEN}### Deleting dummy certificate for ${domains[0]}...${NC}"
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/${domains[0]} && \
  rm -Rf /etc/letsencrypt/archive/${domains[0]} && \
  rm -Rf /etc/letsencrypt/renewal/${domains[0]}.conf" certbot
echo ""

echo -e "${GREEN}### Requesting Let's Encrypt certificate for ${domains[0]}...${NC}"
# Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo ""

echo -e "${GREEN}### Reloading nginx...${NC}"
docker-compose exec nginx nginx -s reload

echo ""
echo -e "${GREEN}=== SSL Certificate Setup Complete! ===${NC}"
echo -e "${YELLOW}Your application is now secured with HTTPS${NC}"
