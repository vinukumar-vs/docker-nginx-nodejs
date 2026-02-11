# Troubleshooting & Common Issues

## Container Issues

### Containers Won't Start

**Problem:** `docker-compose up` fails or containers exit immediately

**Solutions:**

1. Check logs:
```bash
docker-compose logs
docker-compose logs app1
```

2. Rebuild containers (remove cached layers):
```bash
docker-compose down
docker-compose up --build
```

3. Check port conflicts:
```bash
lsof -i :80    # Check NGINX port
lsof -i :3001  # Check app ports
```

4. Insufficient resources (Docker Desktop memory):
   - Docker Desktop Preferences → Resources
   - Increase available memory/CPU

### Port Already in Use

```bash
# Find process using the port
lsof -i :80

# Kill process (macOS)
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8080:80"  # Changed from 80:80
```

## Network Issues

### NGINX Can't Reach Backend Apps

**Problem:** 502 Bad Gateway or connection refused

```bash
# 1. Verify all containers are running
docker-compose ps

# 2. Test connectivity from NGINX to app
docker exec nginx-proxy ping app1
docker exec nginx-proxy curl http://app1:3001/

# 3. Check NGINX config syntax
docker exec nginx-proxy nginx -t
```

**Solution:**

```bash
# Ensure all apps are in same network
docker network ls
docker network inspect docker-containers_nodejs_network

# If network issue, recreate it
docker-compose down --volumes
docker-compose up --build
```

### DNS Resolution Issues

```bash
# Test DNS from NGINX container
docker exec nginx-proxy nslookup app1

# Alternative test
docker exec nginx-proxy getent hosts app1

# If fails, ensure containers on same network:
docker-compose ps --services | xargs -I {} docker inspect {} | grep -A 5 "Networks"
```

## NGINX Issues

### NGINX Won't Start with Custom Config

```bash
# Check config syntax
docker exec nginx-proxy nginx -t

# View config
docker exec nginx-proxy cat /etc/nginx/conf.d/default.conf

# Common errors in nginx.conf:
# - Missing semicolons
# - Wrong server names
# - Invalid directives
```

### 502 Bad Gateway Errors

**Causes:**

1. Backend servers down:
```bash
docker-compose ps  # Check status
curl http://localhost:3001  # Direct test
```

2. NGINX config pointing to wrong host:
```bash
# Check nginx.conf
# Should be: server app1:3001;
# NOT: server localhost:3001;
```

3. Upstream server not responding:
```bash
# Increase timeouts in nginx.conf
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
```

4. Health check failing:
```bash
# Check Dockerfile HEALTHCHECK
# Test health endpoint manually
curl http://localhost:3001/health
```

### NGINX Returning 502 for Some Requests

```bash
# Check buffer settings
proxy_buffering off;
proxy_request_buffering off;

# Or increase buffer size
proxy_buffer_size 128k;
proxy_buffers 4 256k;
```

## Application Issues

### Node.js App Crashing

```bash
# Check logs
docker-compose logs app1

# Common issues:
# - PORT environment variable not set
# - Port already in use
# - Memory issues
```

### Health Check Failing

```bash
# Check if health endpoint works
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health

# Check Docker health status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

**Health check in Dockerfile:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"
```

## Load Balancing Issues

### All Traffic Going to One Server

**Problem:** Round-robin not working

```bash
# Verify upstream configuration
docker exec nginx-proxy cat /etc/nginx/conf.d/default.conf | grep -A 5 upstream

# Should show:
upstream nodejs_backend {
    server app1:3001;
    server app2:3002;
    server app3:3003;
}
```

**Troubleshooting:**

1. If using `ip_hash`:
```nginx
# This causes sticky sessions (same client → same server)
upstream nodejs_backend {
    ip_hash;
    server app1:3001;
    server app2:3002;
    server app3:3003;
}
```

2. If weighted, verify weights:
```bash
# Weights should sum for distribution
curl http://localhost/ | jq '.app'  # Run many times to check
```

### Unequal Request Distribution

**Causes:**

1. Persistent connections:
   - Solution: `proxy_set_header Connection "";`

2. Keep-alive disabled:
   - Solution: Add `keepalive 32;` in upstream

3. Some backends slower:
   - Solution: Use `least_conn;` instead of round-robin

## Performance Issues

### Slow Response Times

**Diagnosis:**

```bash
# Test direct vs through proxy
time curl http://localhost:3001/     # Direct
time curl http://localhost/          # Through NGINX

# Check where latency is
ab -n 10 http://localhost/ | grep "Time per request"
```

**Solutions:**

1. Enable compression:
```nginx
gzip on;
gzip_types text/plain application/json;
```

2. Enable caching:
```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=cache:10m;
location / {
    proxy_cache cache;
}
```

3. Connection reuse:
```nginx
upstream nodejs_backend {
    keepalive 32;
    server app1:3001;
    server app2:3002;
}
```

### High CPU Usage

**Check usage:**

```bash
docker stats
docker stats app1
```

**Solutions:**

1. Add more instances (scale up)
2. Optimize Node.js code
3. Reduce computation intensity
4. Enable load balancing if not already

### High Memory Usage

```bash
# Check memory per container
docker stats --no-stream

# Set memory limits
docker-compose.yml:
services:
  app1:
    deploy:
      resources:
        limits:
          memory: 512M
```

## Logging and Debugging

### View Container Logs

```bash
# Follow all logs
docker-compose logs -f

# Follow specific service
docker-compose logs -f app1

# Last N lines
docker-compose logs --tail=100

# Filter by pattern
docker-compose logs | grep ERROR
docker-compose logs | grep app1
```

### Enable NGINX Debug Logging

Modify `nginx/nginx.conf`:

```nginx
error_log /var/log/nginx/error.log debug;

server {
    access_log /var/log/nginx/access.log;
}
```

Then:

```bash
# View logs
docker exec nginx-proxy tail -f /var/log/nginx/access.log
docker exec nginx-proxy tail -f /var/log/nginx/error.log
```

### Test Individual Services

```bash
# Test app1 directly
curl http://localhost:3001/

# Test app2 directly  
curl http://localhost:3002/

# Test through NGINX (should round-robin)
curl http://localhost/
curl http://localhost/
curl http://localhost/

# Test specific endpoint
curl http://localhost/api/data
curl http://localhost/health
```

## Resource Cleanup

### Remove Everything

```bash
# Stop and remove containers, networks, volumes
docker-compose down -v

# Prune unused Docker resources
docker system prune -a

# Remove specific image
docker rmi <image_name>

# Remove unused networks
docker network prune
```

### Reset Configuration

```bash
# Clear containers but keep images
docker-compose down

# Reset with clean build
docker-compose up --build --force-recreate
```

## Performance Debugging

### Identify Slow Endpoint

```bash
# Compare endpoint response times
time curl http://localhost/
time curl http://localhost/api/data
time curl http://localhost/compute?iterations=50000000
```

### Check Load Distribution

```bash
# Make requests and analyze distribution
for i in {1..30}; do
    curl -s http://localhost/ | jq '.app'
done | sort | uniq -c
```

### Monitor Real-time

```bash
# Terminal 1: Docker stats
docker stats

# Terminal 2: NGINX status
watch curl http://localhost/nginx_status

# Terminal 3: Application logs
docker-compose logs -f

# Terminal 4: Load test
ab -n 1000 -c 100 http://localhost/
```

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | App not running | `docker-compose up` |
| `502 Bad Gateway` | Backend unreachable | Check NGINX config & backend status |
| `Cannot assign requested address` | Port in use | Change port or kill process |
| `Error building image` | Dockerfile issue | Check syntax, verify files exist |
| `Service not found` | DNS resolution failed | Ensure same network, restart container |
| `Read timed out` | Response too slow | Increase `proxy_read_timeout` |
| `Client request body too large` | Payload exceeds limit | Increase `client_max_body_size` |

## When All Else Fails

**Full Reset:**

```bash
# 1. Stop everything
docker-compose down -v

# 2. Clean images
docker image prune -a

# 3. Clean networks
docker network prune

# 4. Start fresh
docker-compose up --build
```

**Manual Testing:**

```bash
# 1. Test NGINX alone
docker run -p 80:80 nginx:alpine

# 2. Test Node.js alone
docker run -p 3001:3001 node:18-alpine npm start

# 3. Test containers can communicate
docker network create test
docker run --network test --name app node:18-alpine node server.js
docker exec app curl http://app:3001/
```

---

**Still stuck?** Check:
1. Docker Desktop is running
2. All required ports are available
3. Network connectivity with `docker network inspect`
4. Logs with `docker-compose logs`
5. Config syntax with `nginx -t`
