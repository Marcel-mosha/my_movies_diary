# 🔒 Production Security Checklist

Use this checklist before deploying to production to ensure your application is secure.

## Pre-Deployment Security Checklist

### 🔐 Django Security

- [ ] `DEBUG=False` in production `.env` file
- [ ] Strong `DJANGO_KEY` generated (64+ random characters)
- [ ] `ALLOWED_HOSTS` configured with your domain(s)
- [ ] `CSRF_TRUSTED_ORIGINS` set to HTTPS URLs only
- [ ] `SECURE_SSL_REDIRECT=True` (enabled when DEBUG=False)
- [ ] `SESSION_COOKIE_SECURE=True` (enabled when DEBUG=False)
- [ ] `CSRF_COOKIE_SECURE=True` (enabled when DEBUG=False)
- [ ] `SECURE_HSTS_SECONDS` set to 63072000 (2 years)
- [ ] Strong database password (16+ characters, mixed case, symbols)
- [ ] No sensitive data in version control (`.env` in `.gitignore`)

### 🌐 SSL/TLS Configuration

- [ ] Domain DNS configured and propagated
- [ ] A and AAAA records pointing to server IP
- [ ] Ports 80 and 443 open in firewall
- [ ] Email configured in `init-letsencrypt.sh`
- [ ] Domain configured in `init-letsencrypt.sh`
- [ ] SSL certificates obtained from Let's Encrypt
- [ ] HTTPS redirect working (HTTP → HTTPS)
- [ ] Certbot auto-renewal container running
- [ ] SSL Labs test shows A or A+ rating
- [ ] Security Headers test shows A or A+ rating

### 🔗 CORS and Frontend

- [ ] `CORS_ALLOWED_ORIGINS` uses HTTPS URLs only
- [ ] Only trusted domains in CORS origins
- [ ] No `CORS_ALLOW_ALL_ORIGINS=True` in production
- [ ] Frontend API calls use HTTPS
- [ ] JWT tokens stored securely (httpOnly preferred)

### 🐳 Docker Configuration

- [ ] Using production `docker-compose.yml` (not dev)
- [ ] Certbot container configured for auto-renewal
- [ ] Certificate volumes mounted correctly
- [ ] Nginx SSL configuration valid (`nginx -t`)
- [ ] Environment variables loaded from `.env`
- [ ] No hardcoded secrets in Docker files
- [ ] Container restart policies set to `unless-stopped`

### 🗄️ Database Security

- [ ] Strong PostgreSQL password
- [ ] Database not exposed to public internet
- [ ] Regular backups configured
- [ ] Database user has minimal required permissions
- [ ] Connection encrypted (within Docker network)

### 📊 Nginx Security

- [ ] Modern TLS protocols only (1.2 and 1.3)
- [ ] Strong cipher suites configured
- [ ] Security headers present (HSTS, CSP, X-Frame-Options, etc.)
- [ ] Rate limiting configured
- [ ] Server tokens hidden (`server_tokens off`)
- [ ] OCSP stapling enabled
- [ ] Gzip compression enabled
- [ ] Client body size limited (`client_max_body_size`)

### 🔑 Authentication & Authorization

- [ ] JWT access token lifetime reasonable (5 hours)
- [ ] JWT refresh token lifetime secure (7 days)
- [ ] Strong password requirements enforced
- [ ] User authentication required for protected routes
- [ ] Admin panel access restricted
- [ ] CSRF protection enabled

### 📝 Logging & Monitoring

- [ ] Application logs configured
- [ ] Error tracking setup
- [ ] SSL certificate expiry monitoring
- [ ] Uptime monitoring configured
- [ ] Log rotation enabled
- [ ] Certbot renewal logs monitored

### 🔄 Updates & Maintenance

- [ ] Deployment documentation complete
- [ ] Backup strategy in place
- [ ] Update process documented
- [ ] Rollback procedure defined
- [ ] Regular security updates planned
- [ ] Dependency updates scheduled

### 🧪 Testing

- [ ] All application features tested over HTTPS
- [ ] Login/logout tested
- [ ] API endpoints tested
- [ ] CORS tested from production frontend
- [ ] Form submissions tested (CSRF)
- [ ] Mobile responsiveness verified
- [ ] SSL certificate tested (SSLLabs)
- [ ] Security headers tested (securityheaders.com)
- [ ] Load testing completed
- [ ] Error pages tested (404, 500, etc.)

## Post-Deployment Verification

Run these commands after deployment:

```bash
# 1. Check all containers are running
docker-compose ps

# 2. Verify SSL certificate
docker-compose run --rm certbot certificates

# 3. Test HTTPS access
curl -I https://yourdomain.com

# 4. Verify HTTP redirects to HTTPS
curl -I http://yourdomain.com

# 5. Check security headers
curl -I https://yourdomain.com | grep -i "strict-transport-security"

# 6. View application logs
docker-compose logs -f backend

# 7. Check nginx configuration
docker-compose exec nginx nginx -t

# 8. Monitor certbot renewal
docker-compose logs certbot
```

## Online Security Tests

After deployment, run these online tests:

### SSL/TLS Configuration
- **SSL Labs**: https://www.ssllabs.com/ssltest/
  - Target: A or A+ rating
  - Checks: Protocol support, cipher strength, certificate validity

### Security Headers
- **Security Headers**: https://securityheaders.com/
  - Target: A or A+ rating
  - Checks: HSTS, CSP, X-Frame-Options, etc.

### Observatory
- **Mozilla Observatory**: https://observatory.mozilla.org/
  - Target: A or A+ grade
  - Comprehensive security scan

### Additional Checks
- **HSTS Preload**: https://hstspreload.org/
  - Optional: Submit domain for HSTS preload list
- **Certificate Transparency**: https://crt.sh/
  - Verify certificate is logged

## Common Security Issues

### ❌ Issue: Mixed Content Warnings

**Symptom**: Browser warns about insecure content on HTTPS page

**Fix**: 
- Ensure all resources (images, scripts, CSS) use HTTPS
- Check frontend API calls use HTTPS
- Update TMDB image URLs to use HTTPS

### ❌ Issue: CORS Errors

**Symptom**: API requests blocked by CORS policy

**Fix**:
- Add HTTPS frontend URL to `CORS_ALLOWED_ORIGINS`
- Ensure `CSRF_TRUSTED_ORIGINS` includes HTTPS URL
- Verify `CORS_ALLOW_CREDENTIALS=True`

### ❌ Issue: CSRF Verification Failed

**Symptom**: Form submissions fail with CSRF error

**Fix**:
- Add domain to `CSRF_TRUSTED_ORIGINS` with HTTPS
- Ensure cookies are being sent (`CORS_ALLOW_CREDENTIALS=True`)
- Clear browser cookies and try again

### ❌ Issue: SSL Certificate Not Found

**Symptom**: Nginx fails to start with certificate error

**Fix**:
- Run `./init-letsencrypt.sh` to generate certificates
- Check certificate paths in `nginx/nginx.conf`
- Verify certbot volumes are mounted

### ❌ Issue: HTTP Not Redirecting to HTTPS

**Symptom**: Can access site over HTTP

**Fix**:
- Check nginx HTTP server block has redirect
- Verify port 80 is accessible
- Restart nginx: `docker-compose restart nginx`

## Security Incident Response

If you discover a security issue:

1. **Immediate Actions**:
   - Document the issue
   - Assess the impact
   - Contain the breach if necessary

2. **Investigation**:
   - Check logs: `docker-compose logs`
   - Review recent changes
   - Identify root cause

3. **Remediation**:
   - Apply security patches
   - Update affected components
   - Change compromised credentials

4. **Prevention**:
   - Update security policies
   - Improve monitoring
   - Document lessons learned

## Regular Maintenance

### Daily
- [ ] Monitor application logs for errors
- [ ] Check certbot renewal logs

### Weekly
- [ ] Review security headers
- [ ] Check SSL certificate expiry
- [ ] Monitor server resources

### Monthly
- [ ] Update Docker images
- [ ] Review and update dependencies
- [ ] Backup database
- [ ] Review access logs

### Quarterly
- [ ] Full security audit
- [ ] Penetration testing
- [ ] Update documentation
- [ ] Review and update passwords

## Security Resources

- **Django Security**: https://docs.djangoproject.com/en/stable/topics/security/
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Let's Encrypt Docs**: https://letsencrypt.org/docs/
- **Nginx Security**: https://nginx.org/en/docs/http/configuring_https_servers.html
- **Mozilla Web Security**: https://infosec.mozilla.org/guidelines/web_security

## Need Help?

If you're unsure about any security settings:

1. Review the [SSL_SETUP.md](SSL_SETUP.md) guide
2. Check Django security documentation
3. Consult OWASP guidelines
4. Consider hiring a security professional

---

**Remember**: Security is an ongoing process, not a one-time setup. Stay vigilant and keep your system updated!
