# 🔒 Safe HTTPS Migration Guide - Zero Downtime

## 📋 Quick Overview

Your application is **already live** at http://moviediary.live. This guide shows how to add HTTPS with **zero downtime** using Let's Encrypt (free SSL certificates).

**Migration Time**: ~20 minutes | **Downtime**: 0 seconds | **Cost**: Free

---

## 🎯 Migration Strategy

We use a **progressive 5-stage approach**:

```
Stage 1 → Prepare nginx for SSL validation (HTTP keeps working)
Stage 2 → Obtain SSL certificates (HTTP keeps working)
Stage 3 → Enable HTTPS alongside HTTP (both work)
Stage 4 → Test HTTPS thoroughly (10-15 min, both work)
Stage 5 → Redirect HTTP to HTTPS (full HTTPS migration)
```

**You can rollback at ANY stage instantly!**

---

## 🚀 Quick Start (3 Commands)

```bash
# 1. Edit your email in the script
nano init-letsencrypt.sh
# Change: email="your-email@example.com"

# 2. Run automated migration (Stages 1-3)
chmod +x migrate-to-https.sh
bash migrate-to-https.sh

# 3. After testing, complete migration (Stage 5)
chmod +x migrate-to-https-final.sh
bash migrate-to-https-final.sh
```

That's it! Your application will be on HTTPS.

---

## 📖 Detailed Step-by-Step Guide

### Prerequisites

- ✅ Application running at http://moviediary.live
- ✅ SSH access to production server
- ✅ Ports 80 and 443 open on firewall
- ✅ Docker and Docker Compose installed

### Stage 1: Prepare Configuration (2 min, HTTP keeps working)

```bash
# On your production server
cd /path/to/my_movies_diary

# Backup current config (automatic in script)
cp nginx/nginx.conf nginx/nginx.conf.backup

# Use Step 1 config (HTTP + SSL validation path)
cp nginx/nginx.conf.step1 nginx/nginx.conf

# Restart nginx
docker-compose up -d nginx
```

**Status**: ✅ HTTP works | ❌ HTTPS not yet
**User Impact**: None, everything works normally

### Stage 2: Obtain SSL Certificates (2 min, HTTP keeps working)

```bash
# Edit the script with YOUR email
nano init-letsencrypt.sh
```

Update these lines:

```bash
domains=(moviediary.live www.moviediary.live)
email="your-actual-email@example.com"  # ← Change this!
```

```bash
# Make executable and run
chmod +x init-letsencrypt.sh
./init-letsencrypt.sh
```

This will:

1. Download TLS parameters
2. Create temporary dummy certificate
3. Start nginx
4. Request real certificates from Let's Encrypt
5. Reload nginx with real certificates

**Status**: ✅ HTTP works | 🔄 SSL certificates obtained
**User Impact**: None

### Stage 3: Enable HTTPS (1 min, both HTTP and HTTPS work)

```bash
# Use Step 2 config (both HTTP and HTTPS)
cp nginx/nginx.conf.step2 nginx/nginx.conf

# Reload nginx
docker-compose exec nginx nginx -s reload
```

**Test both**:

- Visit http://moviediary.live ✅ Works
- Visit https://moviediary.live ✅ Works (with padlock!)

**Status**: ✅ HTTP works | ✅ HTTPS works
**User Impact**: None, users can use either

### Stage 4: Test Thoroughly (10-15 min)

Test HTTPS extensively before redirecting:

```bash
# Test HTTPS endpoint
curl -I https://moviediary.live

# Check certificate
docker-compose run --rm certbot certificates

# Test SSL connection
echo | openssl s_client -servername moviediary.live -connect moviediary.live:443 2>/dev/null | openssl x509 -noout -dates
```

**Manual testing checklist**:

- [ ] https://moviediary.live loads correctly
- [ ] Login/logout works
- [ ] API calls work
- [ ] Admin panel accessible
- [ ] No mixed content warnings in console
- [ ] Test on mobile device

**Status**: ✅ Both HTTP and HTTPS fully functional
**User Impact**: None

### Stage 5: Redirect HTTP to HTTPS (1 min)

Once you're confident HTTPS works:

```bash
# Use final config (HTTP redirects to HTTPS)
# The main nginx.conf already has this configuration
docker-compose exec nginx nginx -s reload

# Update .env to enable Django HTTPS settings
echo "USE_HTTPS=True" >> .env

# Restart backend
docker-compose restart backend
```

**Test redirect**:

- Visit http://moviediary.live → Should redirect to https://
- Visit https://moviediary.live → Should work normally

**Status**: ✅ HTTP redirects to HTTPS | ✅ HTTPS works
**User Impact**: Users automatically moved to HTTPS

🎉 **Migration Complete!**

---

## 🛠️ Automated Scripts

### Option 1: Use Automated Scripts (Recommended)

```bash
# Run stages 1-3 automatically
bash migrate-to-https.sh

# Test for 10-15 minutes
# Then run stage 5
bash migrate-to-https-final.sh
```

### Option 2: Manual Step-by-Step

Follow the detailed guide above for full control.

---

## 🔄 Rollback (If Needed)

At any stage, instantly rollback to HTTP-only:

```bash
# Restore backup
cp nginx/nginx.conf.backup.* nginx/nginx.conf

# Reload nginx
docker-compose exec nginx nginx -s reload
```

Your site immediately returns to HTTP-only mode!

---

## 📊 Configuration Files Reference

| File               | Purpose              | HTTP         | HTTPS    |
| ------------------ | -------------------- | ------------ | -------- |
| `nginx.conf.step1` | Stage 1: Prepare     | ✅ Works     | ❌ None  |
| `nginx.conf.step2` | Stage 3: Both active | ✅ Works     | ✅ Works |
| `nginx.conf`       | Stage 5: Final       | ➡️ Redirects | ✅ Works |

---

## 🎁 What You Get After Migration

- 🔒 **TLS 1.2/1.3 encryption** - Industry standard
- 🔄 **Auto HTTP redirect** - All traffic uses HTTPS
- 🛡️ **Security headers** - HSTS, XSS protection
- 🔐 **Secure cookies** - Session & CSRF protected
- ♻️ **Auto certificate renewal** - Renews every 90 days (no manual work!)
- ⚡ **HTTP/2 support** - Faster page loads
- 🆓 **Free SSL** - Let's Encrypt certificates
- 📱 **SEO boost** - Google favors HTTPS sites
- ✅ **Browser trust** - Padlock icon displayed

---

## 🆘 Troubleshooting

### Certificate Request Fails

```bash
# Check DNS points to your server
dig moviediary.live

# Check certbot logs
docker-compose logs certbot

# Verify ports 80 and 443 are open
sudo ufw status
sudo netstat -tlnp | grep ':80\|:443'

# Check if nginx is running
docker-compose ps
```

### HTTPS Not Loading

```bash
# Check nginx logs
docker-compose logs nginx

# Test nginx configuration
docker-compose exec nginx nginx -t

# Verify certificates exist
docker-compose run --rm certbot certificates

# Check if port 443 is accessible
curl -I https://moviediary.live
```

### Mixed Content Warnings

Update your `.env` file:

```bash
CORS_ALLOWED_ORIGINS=https://moviediary.live,https://www.moviediary.live
```

Then restart:

```bash
docker-compose restart backend
```

### Force Certificate Renewal

```bash
docker-compose run --rm certbot renew --force-renewal
docker-compose exec nginx nginx -s reload
```

---

## ✅ Post-Migration Verification

### Check Your SSL Configuration

1. **Browser test**: Visit https://moviediary.live

   - Should show padlock icon 🔒
   - No security warnings

2. **Redirect test**: Visit http://moviediary.live

   - Should redirect to https://

3. **SSL rating**: Test at https://www.ssllabs.com/ssltest/

   - Target: A or A+ rating

4. **Certificate validity**:
   ```bash
   docker-compose run --rm certbot certificates
   ```

### Verification Checklist

- [ ] https://moviediary.live shows padlock icon
- [ ] http://moviediary.live redirects to HTTPS
- [ ] Login/authentication works
- [ ] API calls work
- [ ] Admin panel accessible
- [ ] No mixed content warnings
- [ ] Mobile devices work
- [ ] SSL Labs rating A/A+
- [ ] Certificate auto-renewal configured

---

## ♻️ Certificate Management

### Automatic Renewal

Certificates are **automatically renewed** by the Certbot container:

- **Validity**: 90 days
- **Auto-renewal**: 30 days before expiry
- **Check frequency**: Every 12 hours
- **Nginx reload**: Every 6 hours (picks up renewed certs)

**No manual intervention required!**

### Manual Commands

```bash
# View certificate info
docker-compose run --rm certbot certificates

# Force renewal (for testing)
docker-compose run --rm certbot renew --force-renewal
docker-compose exec nginx nginx -s reload

# Check renewal logs
docker-compose logs certbot
```

---

## 🎓 What Changed in Your Application

### 1. Docker Compose (`docker-compose.yml`)

- Added **Certbot service** for SSL management
- Added **port 443** for HTTPS traffic
- Added **SSL volumes** for certificate persistence
- Configured **auto-renewal** every 12 hours

### 2. Nginx Configuration (`nginx/nginx.conf`)

- **HTTP server (port 80)**: Redirects to HTTPS (except Let's Encrypt validation)
- **HTTPS server (port 443)**: Handles secure connections with:
  - SSL certificate paths
  - TLS 1.2/1.3 protocols
  - Strong cipher suites
  - HSTS security header
  - HTTP/2 support

### 3. Django Settings (`settings.py`)

- Added **HTTPS security settings** (controlled by `USE_HTTPS` env variable):
  - `SECURE_SSL_REDIRECT`: Redirect HTTP to HTTPS
  - `SESSION_COOKIE_SECURE`: Secure session cookies
  - `CSRF_COOKIE_SECURE`: Secure CSRF tokens
  - `SECURE_HSTS_SECONDS`: HTTP Strict Transport Security
  - `SECURE_PROXY_SSL_HEADER`: Trust nginx's HTTPS forwarding

---

## 📞 Quick Commands Reference

```bash
# View all containers
docker-compose ps

# Check certificate expiry
docker-compose run --rm certbot certificates

# Reload nginx (after config change)
docker-compose exec nginx nginx -s reload

# Test nginx config
docker-compose exec nginx nginx -t

# View nginx logs
docker-compose logs nginx --tail=100

# View certbot logs
docker-compose logs certbot --tail=100

# Force certificate renewal
docker-compose run --rm certbot renew --force-renewal

# Restart all services
docker-compose restart
```

---

## 📚 Additional Resources

- **Let's Encrypt**: https://letsencrypt.org/docs/
- **Certbot**: https://certbot.eff.org/docs/
- **SSL Test**: https://www.ssllabs.com/ssltest/
- **Mozilla SSL Config**: https://ssl-config.mozilla.org/

---

## 🎉 Success!

Your application is now secured with HTTPS!

**Access your site**: https://moviediary.live 🔒

All HTTP traffic automatically redirects to HTTPS, and your SSL certificates will renew automatically every 90 days. No further action needed!
