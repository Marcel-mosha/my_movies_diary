# 🚀 Quick Reference Card

## One-Command Deployment
```bash
./deploy-production.sh
```

## Essential Commands

### Initial Setup
```bash
# 1. Configure environment
cp .env.example .env
nano .env

# 2. Configure SSL
nano init-letsencrypt.sh

# 3. Make executable
chmod +x init-letsencrypt.sh deploy-production.sh

# 4. Deploy
./deploy-production.sh
```

### Docker Management
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart services
docker-compose restart

# View logs (all)
docker-compose logs -f

# View specific service logs
docker-compose logs backend
docker-compose logs nginx
docker-compose logs certbot

# Check status
docker-compose ps

# Rebuild and restart
docker-compose up -d --build
```

### SSL Certificate Management
```bash
# Check certificate info
docker-compose run --rm certbot certificates

# Force renewal
docker-compose run --rm certbot renew

# Reload nginx after renewal
docker-compose exec nginx nginx -s reload

# View certbot logs
docker-compose logs certbot
```

### Django Management
```bash
# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Collect static files
docker-compose exec backend python manage.py collectstatic --noinput

# Django shell
docker-compose exec backend python manage.py shell
```

### Nginx Management
```bash
# Test configuration
docker-compose exec nginx nginx -t

# Reload nginx
docker-compose exec nginx nginx -s reload

# Restart nginx
docker-compose restart nginx

# View nginx logs
docker-compose logs nginx
```

### Database Management
```bash
# Access PostgreSQL
docker-compose exec db psql -U postgres -d movies

# Backup database
docker-compose exec db pg_dump -U postgres movies > backup.sql

# Restore database
docker-compose exec -T db psql -U postgres movies < backup.sql
```

## Testing & Verification

### Local Testing
```bash
# Test HTTPS
curl -I https://yourdomain.com

# Test HTTP redirect
curl -I http://yourdomain.com

# Test with headers
curl -v https://yourdomain.com

# Test API endpoint
curl -X GET https://yourdomain.com/api/movies/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Online Tests
```bash
# SSL Labs Test
https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com

# Security Headers
https://securityheaders.com/?q=yourdomain.com

# Mozilla Observatory
https://observatory.mozilla.org/analyze/yourdomain.com
```

## Troubleshooting

### View Logs
```bash
# All logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Specific service with timestamp
docker-compose logs -f --timestamps backend
```

### Common Fixes
```bash
# Restart everything
docker-compose restart

# Rebuild containers
docker-compose up -d --build

# Remove and recreate
docker-compose down
docker-compose up -d

# Clean Docker cache
docker system prune -a
```

### SSL Issues
```bash
# Check certificate
docker-compose run --rm certbot certificates

# Re-run SSL setup
./init-letsencrypt.sh

# Check nginx config
docker-compose exec nginx nginx -t

# View SSL errors
docker-compose logs nginx | grep -i ssl
```

## Environment Variables (.env)

```env
# Django (REQUIRED)
DJANGO_KEY=<generate-strong-key>
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database (REQUIRED)
DB=movies
DB_USER=postgres
DB_PASSWORD=<strong-password>
DB_HOST=db
DB_PORT=5432

# CORS & CSRF (REQUIRED - HTTPS!)
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
CSRF_TRUSTED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# TMDB (REQUIRED)
API_KEY=<your-tmdb-api-key>
MOVIE_ENDPOINT=https://api.themoviedb.org/3/search/movie
```

## SSL Script Configuration

```bash
# init-letsencrypt.sh
DOMAIN="yourdomain.com"
WWW_DOMAIN="www.yourdomain.com"
EMAIL="your-email@example.com"
STAGING=0  # Set to 1 for testing
```

## Security Checklist

- [ ] DEBUG=False in .env
- [ ] Strong DJANGO_KEY generated
- [ ] ALLOWED_HOSTS configured
- [ ] Database password is strong
- [ ] CORS_ALLOWED_ORIGINS uses HTTPS
- [ ] CSRF_TRUSTED_ORIGINS uses HTTPS
- [ ] Domain DNS configured
- [ ] Ports 80 and 443 open
- [ ] Email set in init-letsencrypt.sh
- [ ] SSL certificates obtained
- [ ] HTTPS working
- [ ] HTTP redirects to HTTPS
- [ ] SSL Labs test: A+
- [ ] Security Headers test: A+

## File Locations

```
Project Root
├── .env                      # Environment variables
├── docker-compose.yml         # Production compose file
├── init-letsencrypt.sh        # SSL setup script
├── deploy-production.sh       # Deployment script
├── nginx/
│   └── nginx.conf            # Nginx configuration
├── certbot/
│   ├── conf/                 # SSL certificates
│   └── www/                  # ACME challenge
├── SSL_SETUP.md              # SSL setup guide
├── SECURITY_CHECKLIST.md     # Security checklist
└── ARCHITECTURE.md           # System architecture
```

## Useful URLs

### Application
- **Frontend**: https://yourdomain.com
- **API**: https://yourdomain.com/api/
- **Admin**: https://yourdomain.com/admin/

### Testing
- **SSL Labs**: https://www.ssllabs.com/ssltest/
- **Security Headers**: https://securityheaders.com/
- **Mozilla Observatory**: https://observatory.mozilla.org/

### Documentation
- **Django Security**: https://docs.djangoproject.com/en/stable/topics/security/
- **Let's Encrypt**: https://letsencrypt.org/docs/
- **Nginx SSL**: https://nginx.org/en/docs/http/configuring_https_servers.html

## Support & Monitoring

### Health Checks
```bash
# Check all containers
docker-compose ps

# Check certificate expiry
docker-compose run --rm certbot certificates

# Check disk space
df -h

# Check memory
free -h

# Check logs for errors
docker-compose logs | grep -i error
```

### Monitoring
```bash
# Watch logs in real-time
docker-compose logs -f

# Monitor certbot renewals
docker-compose logs -f certbot

# Monitor nginx access
docker-compose logs -f nginx | grep -v "health"

# Monitor backend API
docker-compose logs -f backend
```

## Emergency Procedures

### Site Down
```bash
# 1. Check container status
docker-compose ps

# 2. Restart all services
docker-compose restart

# 3. Check logs
docker-compose logs --tail=100
```

### SSL Certificate Expired
```bash
# 1. Check expiry
docker-compose run --rm certbot certificates

# 2. Force renewal
docker-compose run --rm certbot renew --force-renewal

# 3. Reload nginx
docker-compose exec nginx nginx -s reload
```

### Database Issues
```bash
# 1. Check database
docker-compose exec db psql -U postgres -d movies -c "SELECT 1;"

# 2. Restart database
docker-compose restart db

# 3. Check logs
docker-compose logs db
```

## Performance

### View Resource Usage
```bash
# Container stats
docker stats

# Disk usage
docker system df

# Clean unused resources
docker system prune
```

### Optimize
```bash
# Clear old logs
docker-compose logs --tail=0 > /dev/null

# Rebuild images
docker-compose build --no-cache

# Restart services
docker-compose restart
```

## Backup & Restore

### Backup
```bash
# Backup database
docker-compose exec db pg_dump -U postgres movies > backup-$(date +%Y%m%d).sql

# Backup certificates
tar -czf certbot-backup-$(date +%Y%m%d).tar.gz certbot/conf/

# Backup .env
cp .env .env.backup
```

### Restore
```bash
# Restore database
docker-compose exec -T db psql -U postgres movies < backup-20231211.sql

# Restore certificates
tar -xzf certbot-backup-20231211.tar.gz
```

## Quick Wins

### Generate Django Secret Key
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### Check Security Headers
```bash
curl -I https://yourdomain.com | grep -i "strict-transport-security\|x-frame-options\|x-content-type-options"
```

### Test Rate Limiting
```bash
for i in {1..20}; do curl -I https://yourdomain.com; done
```

### View Certificate Details
```bash
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com | openssl x509 -noout -dates
```

---

**Keep this card handy for quick reference! 📋**

**Need detailed help? Check:**
- SSL_SETUP.md - Complete SSL guide
- SECURITY_CHECKLIST.md - Security verification
- ARCHITECTURE.md - System architecture
- README.md - Full documentation
