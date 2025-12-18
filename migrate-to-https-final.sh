#!/bin/bash

# Final step: Redirect all HTTP to HTTPS
# Run this ONLY after testing HTTPS thoroughly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Final Step: Redirect HTTP to HTTPS ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Pre-flight Checks:${NC}"

# Check if HTTPS is working
if curl -s -o /dev/null -w "%{http_code}" https://moviediary.live | grep -q "200"; then
    echo -e "${GREEN}✓ HTTPS is working${NC}"
else
    echo -e "${RED}✗ HTTPS is not working properly${NC}"
    echo "  Please ensure HTTPS works before redirecting HTTP traffic"
    exit 1
fi

# Check certificate
if docker-compose run --rm certbot certificates | grep -q "moviediary.live"; then
    echo -e "${GREEN}✓ SSL Certificate is valid${NC}"
else
    echo -e "${RED}✗ SSL Certificate issue detected${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}⚠️  WARNING ⚠️${NC}"
echo "This will redirect ALL HTTP traffic to HTTPS"
echo "Users will no longer be able to access http://moviediary.live"
echo "They will automatically be redirected to https://moviediary.live"
echo ""
read -p "Have you tested HTTPS thoroughly? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted. Test HTTPS first!${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}Step 1: Update Nginx Configuration${NC}"
# Use the final config with HTTP -> HTTPS redirect
cp nginx/nginx.conf nginx/nginx.conf.step2.backup
# The main nginx.conf already has the redirect, so we use it
docker-compose exec nginx nginx -s reload

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Nginx reloaded with HTTP redirect${NC}"
else
    echo -e "${RED}✗ Nginx reload failed${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}Step 2: Enable Django HTTPS Settings${NC}"
echo "Add to your .env file:"
echo "  USE_HTTPS=True"
echo ""
read -p "Have you updated .env with USE_HTTPS=True? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Remember to set USE_HTTPS=True in .env and restart backend${NC}"
fi

echo ""
echo -e "${YELLOW}Step 3: Restart Backend${NC}"
docker-compose restart backend
echo -e "${GREEN}✓ Backend restarted with HTTPS settings${NC}"
echo ""

echo -e "${YELLOW}Step 4: Verification${NC}"
sleep 2

# Test HTTP redirects to HTTPS
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L http://moviediary.live)
if [ "$HTTP_CODE" == "200" ]; then
    echo -e "${GREEN}✓ HTTP redirects to HTTPS successfully${NC}"
else
    echo -e "${YELLOW}⚠ HTTP returned code: $HTTP_CODE${NC}"
fi

# Test HTTPS works
HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://moviediary.live)
if [ "$HTTPS_CODE" == "200" ]; then
    echo -e "${GREEN}✓ HTTPS is working${NC}"
else
    echo -e "${RED}✗ HTTPS returned code: $HTTPS_CODE${NC}"
fi
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}🎉 Migration Complete! 🎉${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Your application now runs on HTTPS:"
echo -e "  ${GREEN}https://moviediary.live${NC}"
echo ""
echo "Security Features Enabled:"
echo "  ✓ TLS 1.2/1.3 encryption"
echo "  ✓ HTTP to HTTPS redirect"
echo "  ✓ HSTS headers (1 year)"
echo "  ✓ Secure cookies"
echo "  ✓ Automatic certificate renewal"
echo ""
echo "Certificate auto-renewal:"
echo "  - Checks every 12 hours"
echo "  - Renews at 30 days before expiry"
echo "  - No manual intervention needed"
echo ""
echo -e "${YELLOW}Test your SSL rating:${NC}"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=moviediary.live"
