# 🏗️ SSL/TLS Architecture Overview

## System Architecture with HTTPS

```
┌─────────────────────────────────────────────────────────────────┐
│                          INTERNET                                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTPS (Port 443)
                         │ HTTP (Port 80) → Redirects to HTTPS
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                      NGINX (Reverse Proxy)                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • HTTP → HTTPS Redirect (Port 80)                        │  │
│  │  • HTTPS Server (Port 443)                                │  │
│  │  • SSL/TLS Termination                                    │  │
│  │  • Security Headers (HSTS, CSP, X-Frame-Options, etc.)    │  │
│  │  • Rate Limiting                                           │  │
│  │  • Gzip Compression                                        │  │
│  │  • Load Balancing                                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  SSL Certificates: /etc/letsencrypt/live/moviediary.live/       │
└────────────┬───────────────────────┬─────────────────────────────┘
             │                       │
             │                       │
   ┌─────────▼─────────┐   ┌────────▼────────┐
   │  React Frontend   │   │ Django Backend  │
   │  (Port 80)        │   │ (Port 8000)     │
   │                   │   │                 │
   │  • Vite Built     │   │  • Gunicorn     │
   │  • Nginx Served   │   │  • DRF API      │
   │  • Static Files   │   │  • JWT Auth     │
   └───────────────────┘   └────────┬────────┘
                                    │
                                    │
                           ┌────────▼────────┐
                           │   PostgreSQL    │
                           │   (Port 5432)   │
                           │                 │
                           │  • User Data    │
                           │  • Movies       │
                           └─────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                    Certbot (SSL Manager)                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Obtains SSL Certificates from Let's Encrypt            │ │
│  │  • Auto-Renewal every 12 hours                            │ │
│  │  • ACME Challenge via /.well-known/acme-challenge/        │ │
│  │  • Certificate Storage: /etc/letsencrypt/                 │ │
│  └───────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

## Request Flow

### HTTPS Request (Port 443)
```
1. Client → https://moviediary.live
2. Nginx receives on port 443
3. SSL/TLS handshake
4. Nginx decrypts request
5. Nginx applies security headers
6. Nginx proxies to backend/frontend
7. Response encrypted by Nginx
8. Client receives encrypted response
```

### HTTP Request (Port 80)
```
1. Client → http://moviediary.live
2. Nginx receives on port 80
3. Nginx returns 301 redirect
4. Client redirects to https://moviediary.live
5. Follows HTTPS flow above
```

### API Request Flow
```
Client (Browser/App)
    │
    │ HTTPS POST /api/token/
    │ { username, password }
    ▼
Nginx (Port 443)
    │
    │ Decrypt SSL
    │ Add headers
    │ Rate limit
    ▼
Django Backend
    │
    │ Validate credentials
    │ Generate JWT tokens
    ▼
PostgreSQL
    │
    │ User lookup
    ▼
Response
    │
    │ { access, refresh }
    ▼
Nginx
    │
    │ Encrypt SSL
    │ Add security headers
    ▼
Client
```

## SSL/TLS Handshake Process

```
1. Client Hello
   ├─ Supported TLS versions
   ├─ Cipher suites
   └─ Random data

2. Server Hello
   ├─ Selected TLS version (1.2 or 1.3)
   ├─ Selected cipher suite
   ├─ Certificate (from Let's Encrypt)
   └─ Random data

3. Certificate Verification
   ├─ Client validates certificate
   ├─ Checks expiry date
   ├─ Verifies domain name
   └─ Validates certificate chain

4. Key Exchange
   ├─ Client generates pre-master secret
   ├─ Encrypts with server's public key
   └─ Sends to server

5. Session Keys Generated
   ├─ Both sides derive session keys
   └─ From pre-master secret and random data

6. Encrypted Connection Established
   └─ All traffic now encrypted
```

## Security Layers

```
┌─────────────────────────────────────────────┐
│         Application Layer Security          │
│  • JWT Authentication                       │
│  • CSRF Protection                          │
│  • XSS Prevention                           │
│  • SQL Injection Prevention (ORM)           │
└─────────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────────┐
│          HTTP Security Headers              │
│  • HSTS (Force HTTPS)                       │
│  • CSP (Content Security Policy)            │
│  • X-Frame-Options (Clickjacking)           │
│  • X-Content-Type-Options (MIME Sniffing)   │
└─────────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────────┐
│          TLS/SSL Encryption                 │
│  • TLS 1.2 and 1.3                          │
│  • Strong Cipher Suites                     │
│  • Perfect Forward Secrecy                  │
│  • OCSP Stapling                            │
└─────────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────────┐
│          Network Layer Security             │
│  • Rate Limiting                            │
│  • DDoS Protection                          │
│  • Firewall Rules                           │
│  • Private Docker Network                   │
└─────────────────────────────────────────────┘
```

## Certificate Renewal Flow

```
Every 12 hours:
    │
    ▼
Certbot Container
    │
    │ Check certificate expiry
    │
    ├─ > 30 days remaining?
    │   └─ Skip renewal
    │
    └─ < 30 days remaining?
        │
        │ Request new certificate
        │
        ▼
    Let's Encrypt
        │
        │ ACME Challenge
        │ (via /.well-known/acme-challenge/)
        │
        ▼
    Verify Domain Ownership
        │
        │ Domain verified?
        │
        ├─ Yes
        │   │
        │   │ Issue new certificate
        │   │
        │   ▼
        │   Save to /etc/letsencrypt/
        │       │
        │       │ Reload Nginx
        │       │
        │       ▼
        │   Certificate Updated ✓
        │
        └─ No
            │
            │ Log error
            │ Retry later
```

## Data Flow Diagram

```
┌──────────┐
│  Client  │
└────┬─────┘
     │
     │ 1. https://moviediary.live/api/movies/
     │    Authorization: Bearer <jwt>
     │
     ▼
┌────────────────┐
│  Nginx:443     │ ◄─── SSL Certificate
└────┬───────────┘
     │
     │ 2. Decrypt TLS
     │    Verify request
     │    Add security headers
     │    Rate limit check
     │
     ▼
┌────────────────┐
│  Django:8000   │
└────┬───────────┘
     │
     │ 3. Verify JWT token
     │    Check permissions
     │    Filter user's movies
     │
     ▼
┌────────────────┐
│ PostgreSQL     │
└────┬───────────┘
     │
     │ 4. Query movies
     │    Apply filters
     │
     ▼
     Response
     │
     │ 5. Serialize data
     │    Build JSON response
     │
     ▼
┌────────────────┐
│  Django:8000   │
└────┬───────────┘
     │
     │ 6. Add CORS headers
     │    Return JSON
     │
     ▼
┌────────────────┐
│  Nginx:443     │
└────┬───────────┘
     │
     │ 7. Add security headers
     │    Encrypt with TLS
     │    Compress (gzip)
     │
     ▼
┌──────────┐
│  Client  │ ◄─── { movies: [...] }
└──────────┘
```

## Port Configuration

| Port | Protocol | Service | Purpose |
|------|----------|---------|---------|
| 80 | HTTP | Nginx | Redirects to HTTPS |
| 443 | HTTPS | Nginx | Main application entry (encrypted) |
| 8000 | HTTP | Django | Backend API (internal only) |
| 5432 | TCP | PostgreSQL | Database (internal only) |

## Volume Mounts

```
Host System                     Container
─────────────────────────────────────────────────────
./nginx/nginx.conf         →    /etc/nginx/nginx.conf
./certbot/conf/           →    /etc/letsencrypt/
./certbot/www/            →    /var/www/certbot/
staticfiles/               →    /app/staticfiles/
media/                     →    /app/media/
postgres_data/             →    /var/lib/postgresql/data/
```

## Security Headers Applied

| Header | Value | Purpose |
|--------|-------|---------|
| Strict-Transport-Security | max-age=63072000 | Force HTTPS for 2 years |
| Content-Security-Policy | default-src 'self'... | Prevent XSS attacks |
| X-Frame-Options | SAMEORIGIN | Prevent clickjacking |
| X-Content-Type-Options | nosniff | Prevent MIME sniffing |
| X-XSS-Protection | 1; mode=block | Enable XSS filter |
| Referrer-Policy | no-referrer-when-downgrade | Privacy protection |
| Permissions-Policy | geolocation=()... | Disable unnecessary APIs |

## TLS Configuration

### Protocols Supported
- ✅ TLS 1.3 (Preferred)
- ✅ TLS 1.2 (Fallback)
- ❌ TLS 1.1 (Disabled - insecure)
- ❌ TLS 1.0 (Disabled - insecure)
- ❌ SSL 3.0 (Disabled - insecure)

### Cipher Suites (in order of preference)
1. ECDHE-ECDSA-AES128-GCM-SHA256
2. ECDHE-RSA-AES128-GCM-SHA256
3. ECDHE-ECDSA-AES256-GCM-SHA384
4. ECDHE-RSA-AES256-GCM-SHA384
5. ECDHE-ECDSA-CHACHA20-POLY1305
6. ECDHE-RSA-CHACHA20-POLY1305

### Security Features
- ✅ Perfect Forward Secrecy
- ✅ OCSP Stapling
- ✅ Session Resumption
- ✅ HTTP/2 Support

## Monitoring Points

```
Certbot Logs
    │
    ├─ Certificate request status
    ├─ Renewal attempts
    └─ Errors/warnings

Nginx Logs
    │
    ├─ Access logs (requests)
    ├─ Error logs (failures)
    └─ SSL handshake errors

Django Logs
    │
    ├─ API requests
    ├─ Authentication events
    └─ Application errors

Database Logs
    │
    ├─ Query performance
    └─ Connection issues
```

---

**This architecture provides enterprise-grade security for your Django Movies Diary application! 🔒**
