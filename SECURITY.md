# Production Security Guide

## Basic Security Measures

This application includes basic security features for production deployment:

### 🔒 Implemented Security Features

1. **JWT Authentication**

   - Secure token-based authentication
   - Access tokens: 5 hour lifetime
   - Refresh tokens: 7 day lifetime

2. **Django Security Settings**

   - XSS filtering enabled
   - Clickjacking protection (X-Frame-Options)
   - MIME type sniffing prevention
   - HTTP-only cookies
   - CSRF protection

3. **Nginx Security**

   - Rate limiting (10 req/s general, 30 req/s API)
   - Basic security headers
   - Server version hidden
   - Request size limits (10MB)

4. **CORS Configuration**
   - Restricted to specified origins
   - Credentials support enabled

### ⚙️ Configuration

**Environment Variables (.env):**

```env
DEBUG=False  # Always False in production
DJANGO_KEY=<strong-random-secret-key>
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DB_PASSWORD=<strong-password>
CORS_ALLOWED_ORIGINS=http://yourdomain.com,http://www.yourdomain.com
```

**Generate Secret Key:**

```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 📝 Production Checklist

- [ ] `DEBUG=False` in .env
- [ ] Strong `DJANGO_KEY` generated
- [ ] Strong database password
- [ ] `ALLOWED_HOSTS` configured
- [ ] CORS origins properly set
- [ ] Firewall configured (ports 80, 443 if using HTTPS)

### 🔐 Recommended Additional Security

For production environments, consider:

- **HTTPS/SSL**: Use a reverse proxy (Cloudflare, AWS ALB, etc.) or Let's Encrypt
- **Firewall**: Configure UFW or cloud provider security groups
- **Database**: Regular backups and restricted access
- **Monitoring**: Setup logging and error tracking
- **Updates**: Keep dependencies updated

### 📚 Resources

- [Django Security](https://docs.djangoproject.com/en/stable/topics/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
