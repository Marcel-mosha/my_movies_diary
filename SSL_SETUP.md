# SSL/TLS Security Configuration Guide

## Overview
This project has been configured with comprehensive SSL/TLS security for production deployment. All HTTP traffic is automatically redirected to HTTPS, and modern security headers are implemented.

## 🔐 Security Features Implemented

### 1. **HTTPS/SSL Configuration**
- ✅ Let's Encrypt SSL certificates with Certbot
- ✅ Automatic HTTP to HTTPS redirect
- ✅ TLS 1.2 and TLS 1.3 support only
- ✅ Modern cipher suites
- ✅ OCSP stapling for certificate validation

### 2. **Security Headers**
- ✅ HSTS (HTTP Strict Transport Security) - 2 years
- ✅ X-Frame-Options (Clickjacking protection)
- ✅ X-Content-Type-Options (MIME sniffing protection)
- ✅ X-XSS-Protection
- ✅ Content Security Policy (CSP)
- ✅ Referrer-Policy
- ✅ Permissions-Policy

### 3. **Django Security Settings**
- ✅ Secure SSL redirect
- ✅ Secure cookies (HTTPS only)
- ✅ CSRF protection
- ✅ Session security
- ✅ XSS filtering

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Domain Name**: A registered domain pointing to your server
2. **Server**: A server with Docker and Docker Compose installed
3. **Ports Open**: Ports 80 and 443 accessible from the internet
4. **DNS Configuration**: A and AAAA records pointing to your server IP

## 🚀 Initial SSL Setup

### Step 1: Update Environment Variables

Create or update your `.env` file with the following production settings:

```bash
# Django Settings
DEBUG=False
DJANGO_KEY=your-very-long-and-random-secret-key-here-change-this
ALLOWED_HOSTS=moviediary.live,www.moviediary.live

# Database
DB=movies
DB_USER=postgres
DB_PASSWORD=your-secure-database-password
DB_HOST=db
DB_PORT=5432

# CORS & CSRF for Production (HTTPS URLs)
CORS_ALLOWED_ORIGINS=https://moviediary.live,https://www.moviediary.live
CSRF_TRUSTED_ORIGINS=https://moviediary.live,https://www.moviediary.live

# TMDB API
API_KEY=your-tmdb-api-key
MOVIE_ENDPOINT=your-movie-endpoint
```

### Step 2: Configure the SSL Script

Edit `init-letsencrypt.sh` and update:

```bash
DOMAIN="moviediary.live"              # Your domain
WWW_DOMAIN="www.moviediary.live"      # Your www subdomain
EMAIL="your-email@example.com"         # Your email for Let's Encrypt
```

### Step 3: Make Script Executable

```bash
chmod +x init-letsencrypt.sh
```

### Step 4: Run SSL Initialization

```bash
./init-letsencrypt.sh
```

This script will:
- Create necessary directories
- Download TLS parameters
- Create a temporary certificate
- Start nginx
- Request real certificates from Let's Encrypt
- Reload nginx with the new certificates

### Step 5: Start All Services

```bash
docker-compose up -d
```

## 🔄 Certificate Renewal

Certificates automatically renew every 12 hours via the Certbot container. No manual intervention required!

To manually renew:

```bash
docker-compose run --rm certbot renew
docker-compose exec nginx nginx -s reload
```

## 🧪 Testing SSL Configuration

### 1. Test HTTPS Access
```bash
curl -I https://moviediary.live
```

### 2. Test HTTP Redirect
```bash
curl -I http://moviediary.live
# Should return 301 redirect to HTTPS
```

### 3. SSL Labs Test
Visit: https://www.ssllabs.com/ssltest/analyze.html?d=moviediary.live

Aim for an **A+ rating**!

### 4. Security Headers Check
Visit: https://securityheaders.com/?q=moviediary.live

## 🛠️ Troubleshooting

### Certificate Request Fails

**Problem**: Let's Encrypt certificate request fails

**Solutions**:
1. Ensure ports 80 and 443 are open
2. Verify DNS records are correct and propagated
3. Check domain is accessible: `ping moviediary.live`
4. Use staging mode first: Set `STAGING=1` in `init-letsencrypt.sh`

### Nginx Won't Start

**Problem**: Nginx fails to start with SSL errors

**Solutions**:
1. Check certificate paths in `nginx/nginx.conf` match your domain
2. Ensure certbot volumes are mounted correctly
3. View logs: `docker-compose logs nginx`

### 502 Bad Gateway

**Problem**: Getting 502 errors after SSL setup

**Solutions**:
1. Ensure backend is running: `docker-compose ps`
2. Check backend logs: `docker-compose logs backend`
3. Verify network connectivity between containers

### CSRF Errors

**Problem**: CSRF verification failed errors

**Solutions**:
1. Add your domain to `CSRF_TRUSTED_ORIGINS` in `.env`
2. Ensure `CORS_ALLOWED_ORIGINS` uses HTTPS URLs
3. Clear browser cookies and try again

## 📁 File Structure

```
my_movies_diary/
├── certbot/
│   ├── conf/          # Let's Encrypt certificates
│   └── www/           # ACME challenge files
├── nginx/
│   └── nginx.conf     # Nginx SSL configuration
├── docker-compose.yml # Updated with SSL services
├── init-letsencrypt.sh # SSL initialization script
└── my_movies_diary/
    └── settings.py    # Django security settings
```

## 🔒 Security Best Practices

### 1. Keep Secrets Secret
- Never commit `.env` file to Git
- Use strong, random passwords
- Rotate secrets regularly

### 2. Monitor Certificates
- Check certificate expiry: `docker-compose run --rm certbot certificates`
- Monitor certbot logs for renewal issues

### 3. Regular Updates
```bash
# Update Docker images
docker-compose pull

# Rebuild and restart
docker-compose up -d --build
```

### 4. Backup Certificates
```bash
# Backup certificate directory
tar -czf certbot-backup-$(date +%Y%m%d).tar.gz certbot/conf/
```

### 5. Rate Limits
Let's Encrypt has rate limits:
- 50 certificates per domain per week
- Use staging mode (`STAGING=1`) for testing

## 📊 Security Headers Explained

### HSTS (Strict-Transport-Security)
Forces browsers to only use HTTPS for 2 years, including subdomains.

### CSP (Content-Security-Policy)
Controls which resources can be loaded, preventing XSS attacks.

### X-Frame-Options
Prevents clickjacking by controlling iframe embedding.

### X-Content-Type-Options
Prevents MIME-type sniffing.

## 🌐 Production Deployment Checklist

- [ ] Domain DNS configured and propagated
- [ ] `.env` file updated with production values
- [ ] `DEBUG=False` in `.env`
- [ ] Strong `DJANGO_KEY` generated
- [ ] Email configured in `init-letsencrypt.sh`
- [ ] Ports 80 and 443 open on firewall
- [ ] SSL certificates obtained successfully
- [ ] HTTPS redirect working
- [ ] Security headers present (check with curl)
- [ ] SSL Labs test shows A+ rating
- [ ] CORS origins use HTTPS URLs
- [ ] Database password is strong and secure
- [ ] Static files serving correctly over HTTPS
- [ ] Admin panel accessible over HTTPS
- [ ] API endpoints working over HTTPS

## 📞 Support

If you encounter issues:
1. Check docker logs: `docker-compose logs`
2. Test nginx config: `docker-compose exec nginx nginx -t`
3. Verify certificate: `docker-compose run --rm certbot certificates`

## 🔗 Useful Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Django Security Settings](https://docs.djangoproject.com/en/stable/topics/security/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)

## 📝 Notes

- Certificates are valid for 90 days
- Auto-renewal runs twice daily
- Keep backup of `certbot/conf` directory
- Monitor `docker-compose logs certbot` for renewal status
