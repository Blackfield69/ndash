# NDash Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Install Dependencies
```bash
cd /opt/ndash
npm install
```

### Step 2: Configure Environment
Edit the `.env` file:
```bash
nano .env
```

Set these values:
```env
PORT=3000
PDNS_API_URL=http://localhost:8081
PDNS_API_KEY=your-api-key-here
SESSION_SECRET=your-random-secret
```

### Step 3: Start the Application
```bash
# Development mode (auto-reload)
npm run dev

# Or production mode
npm start
```

### Step 4: Access Dashboard
Open your browser: http://localhost:3000

---

## 🔧 PowerDNS Configuration

### Enable API in PowerDNS
Edit `/etc/powerdns/pdns.conf`:
```conf
api=yes
api-key=your-secure-api-key
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=127.0.0.1,::1
```

Restart PowerDNS:
```bash
systemctl restart pdns
```

### Test API Connection
```bash
curl -H "X-API-Key: your-api-key" http://localhost:8081/api/v1/servers
```

---

## 📋 Common Tasks

### Create a New Zone
1. Click "Add Zone" button on dashboard
2. Enter zone name (e.g., example.com)
3. Select zone type (Native/Master/Slave)
4. Add nameservers
5. Click "Create Zone"

### Add DNS Records
1. Click on a zone name
2. Click "Add Record"
3. Select record type (A, AAAA, CNAME, etc.)
4. Enter record data
5. Save

### Delete a Zone
1. Find the zone in the list
2. Click the trash icon
3. Confirm deletion

---

## 🐳 Docker Deployment (Optional)

Create `Dockerfile`:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  ndash:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PDNS_API_URL=http://pdns:8081
      - PDNS_API_KEY=${PDNS_API_KEY}
    restart: unless-stopped
```

Run:
```bash
docker-compose up -d
```

---

## 🔒 Production Deployment

### 1. Install as Systemd Service
```bash
# Copy service file
sudo cp ndash.service /etc/systemd/system/

# Edit service file if needed
sudo nano /etc/systemd/system/ndash.service

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable ndash
sudo systemctl start ndash

# Check status
sudo systemctl status ndash
```

### 2. Configure Nginx Reverse Proxy
```bash
# Copy nginx config
sudo cp nginx.conf.example /etc/nginx/sites-available/ndash

# Edit configuration
sudo nano /etc/nginx/sites-available/ndash

# Enable site
sudo ln -s /etc/nginx/sites-available/ndash /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Setup SSL with Let's Encrypt
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d ndash.example.com

# Auto-renewal is configured automatically
```

---

## 🔍 Troubleshooting

### Application won't start
```bash
# Check logs
npm run dev

# Or for systemd service
sudo journalctl -u ndash -f
```

### Can't connect to PowerDNS API
```bash
# Test API directly
curl -v -H "X-API-Key: your-key" http://localhost:8081/api/v1/servers

# Check PowerDNS is running
sudo systemctl status pdns

# Check PowerDNS logs
sudo journalctl -u pdns -f
```

### Port already in use
```bash
# Check what's using port 3000
sudo lsof -i :3000

# Change port in .env file
nano .env
# Set PORT=3001 (or any other free port)
```

---

## 📊 Features Overview

### Dashboard
- Total zones count
- Total records count
- Query statistics
- Server status
- Recent zones list

### Zone Management
- Create new zones
- Delete zones
- View zone details
- Search zones

### Record Management
- Add/Edit/Delete records
- Support for all record types
- Bulk operations
- Record validation

---

## 🛠️ Development

### Project Structure
```
ndash/
├── server.js           # Main Express application
├── lib/
│   └── pdns-client.js  # PowerDNS API client
├── views/              # EJS templates
├── public/             # Static assets
│   ├── css/           # Stylesheets
│   └── js/            # Client-side JavaScript
└── .env               # Configuration
```

### Adding New Features
1. Add API routes in `server.js`
2. Update `lib/pdns-client.js` if needed
3. Create/update views in `views/`
4. Add client-side logic in `public/js/app.js`

### Running Tests
```bash
npm test
```

---

## 📚 API Reference

All API endpoints are available at `/api/*`:

- `GET /api/servers` - List servers
- `GET /api/servers/:id/zones` - List zones
- `POST /api/servers/:id/zones` - Create zone
- `DELETE /api/servers/:id/zones/:zoneId` - Delete zone
- `PATCH /api/servers/:id/zones/:zoneId` - Update records

---

## 💡 Tips & Best Practices

1. **Backup Regularly**: Always backup your PowerDNS database
2. **Use HTTPS**: Never expose the dashboard over plain HTTP in production
3. **Restrict Access**: Use firewall rules to limit access
4. **Monitor Logs**: Keep an eye on application and PowerDNS logs
5. **Update Dependencies**: Regularly update npm packages

---

## 🆘 Getting Help

- Check the full README.md
- Review PowerDNS documentation
- Check application logs
- Open an issue on GitHub

---

**Happy DNS Management! 🎉**
