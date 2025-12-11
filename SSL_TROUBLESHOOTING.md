# 🔧 SSL Certificate Setup Troubleshooting

## Your Error: "Connection Refused"

The error you're seeing means Let's Encrypt cannot reach your server on port 80.

### Error Details:
```
Domain: moviediary.live
Type: connection
Detail: 167.172.111.20: Fetching http://moviediary.live/.well-known/acme-challenge/... Connection refused
```

## ✅ Quick Fix Steps

### Step 1: Check Current Setup

```bash
# Check if containers are running
docker-compose ps

# Check nginx logs
docker-compose logs nginx

# Check if port 80 is accessible
curl -I http://moviediary.live
```

### Step 2: Verify Firewall Settings

```bash
# Check if port 80 and 443 are open
sudo ufw status

# If firewall is blocking, allow ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### Step 3: Check DNS Configuration

```bash
# Verify DNS points to your server
nslookup moviediary.live
dig moviediary.live

# Should show IP: 167.172.111.20
```

### Step 4: Use the Fixed Setup Script

```bash
# Make the fixed script executable
chmod +x init-letsencrypt-fixed.sh

# Update your email
nano init-letsencrypt-fixed.sh  # Change EMAIL variable

# Run the fixed script
./init-letsencrypt-fixed.sh
```

## 🔍 Common Causes & Solutions

### 1. ❌ Nginx Not Running on Port 80

**Check:**
```bash
docker-compose ps nginx
docker-compose logs nginx
```

**Fix:**
```bash
# Restart nginx
docker-compose restart nginx

# Or rebuild
docker-compose up -d --build nginx
```

### 2. ❌ Port 80 Blocked by Firewall

**Check:**
```bash
sudo ufw status
sudo iptables -L -n | grep 80
```

**Fix:**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### 3. ❌ Nginx SSL Config Before Certificate Exists

**Problem:** Nginx tries to load SSL certificate that doesn't exist yet

**Fix:** Use the new `init-letsencrypt-fixed.sh` script which:
- Starts with HTTP-only config
- Gets certificate
- Then switches to SSL config

### 4. ❌ DNS Not Configured

**Check:**
```bash
nslookup moviediary.live
# Should return: 167.172.111.20
```

**Fix:**
- Add A record in your domain registrar
- Point to: 167.172.111.20
- Wait for DNS propagation (5-30 minutes)

### 5. ❌ Wrong Server IP

**Check:**
```bash
# Get your server's public IP
curl ifconfig.me
```

**Fix:**
- Update DNS A record with correct IP

### 6. ❌ Certbot Directory Not Mounted

**Check:**
```bash
ls -la certbot/www/
docker-compose exec nginx ls -la /var/www/certbot/
```

**Fix:**
```bash
mkdir -p certbot/www
docker-compose restart nginx
```

## 🚀 Step-by-Step Fix Process

### Method 1: Use Fixed Script (Recommended)

```bash
# 1. Stop current containers
docker-compose down

# 2. Update email in fixed script
nano init-letsencrypt-fixed.sh
# Change: EMAIL="your-email@example.com"
# To: EMAIL="youremail@gmail.com"

# 3. Make executable
chmod +x init-letsencrypt-fixed.sh

# 4. Run it
./init-letsencrypt-fixed.sh
```

### Method 2: Manual Step-by-Step

```bash
# 1. Stop everything
docker-compose down

# 2. Backup current nginx config
cp nginx/nginx.conf nginx/nginx.conf.backup

# 3. Use HTTP-only config
cp nginx/nginx.conf.http-only nginx/nginx.conf

# 4. Start services
docker-compose up -d

# 5. Wait for services to be ready
sleep 10

# 6. Test if port 80 works
curl -I http://moviediary.live

# 7. Request certificate
docker-compose run --rm certbot certonly --webroot \
  -w /var/www/certbot \
  --email your-email@example.com \
  -d moviediary.live \
  -d www.moviediary.live \
  --rsa-key-size 4096 \
  --agree-tos \
  --non-interactive

# 8. If successful, restore SSL config
cp nginx/nginx.conf.backup nginx/nginx.conf

# 9. Restart nginx
docker-compose restart nginx
```

### Method 3: Use Staging Mode First

```bash
# Test with Let's Encrypt staging (no rate limits)
nano init-letsencrypt-fixed.sh
# Set: STAGING=1

./init-letsencrypt-fixed.sh

# If successful, get real certificate
# Set: STAGING=0
./init-letsencrypt-fixed.sh
```

## 🔍 Debugging Commands

```bash
# Check if nginx is listening on port 80
docker-compose exec nginx netstat -tuln | grep :80

# Check nginx configuration
docker-compose exec nginx nginx -t

# View real-time nginx logs
docker-compose logs -f nginx

# Check certbot directory
docker-compose exec nginx ls -la /var/www/certbot/

# Test ACME challenge path
docker-compose exec nginx curl http://localhost/.well-known/acme-challenge/test

# Check if domain resolves correctly
dig +short moviediary.live

# Test connection from outside
curl -v http://moviediary.live/.well-known/acme-challenge/test
```

## ⚠️ Pre-Flight Checklist

Before running SSL setup:

- [ ] DNS A record points to 167.172.111.20
- [ ] DNS propagated (check with: `nslookup moviediary.live`)
- [ ] Port 80 open in firewall
- [ ] Port 443 open in firewall
- [ ] Docker and docker-compose installed
- [ ] No other service using port 80 or 443
- [ ] Email configured in script
- [ ] Domain configured in script

## 🎯 Verify Each Requirement

### 1. Check DNS
```bash
nslookup moviediary.live
# Expected: Address: 167.172.111.20
```

### 2. Check Firewall
```bash
sudo ufw status
# Expected: 80/tcp ALLOW, 443/tcp ALLOW
```

### 3. Check Port Availability
```bash
sudo netstat -tuln | grep -E ':80|:443'
# Should show docker-proxy or nginx
```

### 4. Check from External Server
```bash
# From another machine or online tool
curl -I http://moviediary.live
# Should get response, not "Connection refused"
```

## 🆘 Still Not Working?

### Option 1: Use Staging Mode
```bash
# In init-letsencrypt-fixed.sh
STAGING=1  # Change this line

# Run script
./init-letsencrypt-fixed.sh

# Check for different errors
```

### Option 2: Check Cloud Provider Settings

**DigitalOcean:**
- Check firewall rules in dashboard
- Ensure droplet has public IP
- Check networking tab

**AWS:**
- Check Security Groups
- Ensure inbound rules allow port 80, 443
- Check if Elastic IP is attached

**Other Providers:**
- Verify firewall settings
- Check network configuration

### Option 3: Test Without Docker

```bash
# Stop docker
docker-compose down

# Install nginx directly
sudo apt install nginx

# Test if it works
sudo systemctl start nginx
curl -I http://localhost

# If this works, issue is with Docker networking
```

## 📊 Success Indicators

You'll know it's working when:

```bash
# This returns 200 or 301
curl -I http://moviediary.live

# This shows certificate info
docker-compose run --rm certbot certificates

# Nginx logs show no errors
docker-compose logs nginx | grep -i error
```

## 📞 Get More Help

If still stuck:

1. **Share these outputs:**
   ```bash
   docker-compose ps
   docker-compose logs nginx | tail -50
   nslookup moviediary.live
   curl -I http://moviediary.live
   sudo ufw status
   ```

2. **Check Let's Encrypt Community:**
   - https://community.letsencrypt.org

3. **Common Issues Database:**
   - Search for "certbot connection refused"

## 💡 Pro Tips

1. **Always test with staging first** (STAGING=1) to avoid rate limits
2. **Wait for DNS propagation** before requesting certificates
3. **Check logs frequently** during setup
4. **Keep certbot/www directory** writable
5. **Ensure nginx config is valid** before restarting

---

**Run the fixed script and you should be good to go! 🚀**
