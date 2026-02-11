# Docker + NGINX + Node.js Load Balancing Learning Project

This project demonstrates how to use Docker, NGINX, and Node.js to create a scalable application architecture with load balancing and reverse proxy capabilities.

## Project Structure

```
docker-containers/
├── app1/
│   ├── server.js          # Express app (Port 3001)
│   ├── package.json
│   └── Dockerfile
├── app2/
│   ├── server.js          # Express app (Port 3002)
│   ├── package.json
│   └── Dockerfile
├── app3/
│   ├── server.js          # Express app (Port 3003)
│   ├── package.json
│   └── Dockerfile
├── nginx/
│   ├── nginx.conf         # NGINX reverse proxy configuration
│   └── Dockerfile
└── docker-compose.yml     # Orchestration configuration
```

## Key Concepts

### 1. **Reverse Proxy**
NGINX acts as a reverse proxy, sitting in front of multiple Node.js applications. When a client makes a request to NGINX (port 80), NGINX forwards the request to one of the backend servers.

### 2. **Load Balancing**
NGINX uses **round-robin** load balancing by default:
- Request 1 → App1
- Request 2 → App2
- Request 3 → App3
- Request 4 → App1 (cycle repeats)

### 3. **Container Networking**
All containers are connected via a Docker network (`nodejs_network`), allowing them to communicate using service names as hostnames (e.g., `http://app1:3001`).

### 4. **Health Checks**
Each service has health checks configured to ensure containers are running properly. NGINX can automatically skip unhealthy backends.

## Getting Started

### Prerequisites
- Docker Desktop installed and running
- Docker Compose (usually included with Docker Desktop)

### Step 1: Build and Start Containers

```bash
cd docker-containers
docker-compose up --build
```

This command will:
1. Build Docker images for all services
2. Create a custom bridge network
3. Start all containers (NGINX proxy + 3 Node.js apps)
4. Run health checks

### Step 2: Verify Everything is Running

```bash
docker-compose ps
```

You should see 4 containers running:
- nginx-proxy (Port 80)
- nodejs-app1 (Port 3001)
- nodejs-app2 (Port 3002)
- nodejs-app3 (Port 3003)

## Testing the Setup

### Basic Requests

**1. Test round-robin load balancing:**

```bash
# Run multiple requests and observe which app responds
curl http://localhost
curl http://localhost
curl http://localhost
```

Each response will show a different `hostname` and `app` name, proving load distribution.

**2. Check health of all backends:**

```bash
curl http://localhost/health
```

**3. Get system information:**

```bash
curl http://localhost/api/data
```

This will show CPU count, memory, and platform info for each app.

### Load Testing

**1. Single request to /compute endpoint:**

```bash
curl "http://localhost/compute?iterations=100000000"
```

**2. Load test with Apache Bench (included with most systems):**

```bash
# 100 requests with 10 concurrent connections
ab -n 100 -c 10 http://localhost/

# More intense: 1000 requests with 50 concurrent connections
ab -n 1000 -c 50 http://localhost/
```

**3. Load test with curl (alternative method):**

```bash
# Run 20 requests in parallel
for i in {1..20}; do curl http://localhost & done; wait
```

**4. Monitor load distribution in real-time:**

```bash
# In one terminal, watch NGINX status
watch curl http://localhost/nginx_status

# In another terminal, run load tests
ab -n 1000 -c 20 http://localhost/
```

## NGINX Configuration Explained

```nginx
upstream nodejs_backend {
    server app1:3001;    # Backend 1
    server app2:3002;    # Backend 2
    server app3:3003;    # Backend 3
}
```

**Key directives:**

- `upstream` - Defines a group of backend servers
- `server app1:3001` - Each backend server (uses DNS from Docker network)
- `proxy_pass` - Routes request to upstream group
- `proxy_set_header` - Preserves client information
- `proxy_read_timeout` - Timeout for responses from backend

## Advanced Configuration Options

### 1. **Weighted Load Balancing**

Modify `nginx/nginx.conf`:

```nginx
upstream nodejs_backend {
    server app1:3001 weight=3;  # Gets 3x more traffic
    server app2:3002 weight=1;
    server app3:3003 weight=1;
}
```

### 2. **Least Connections Method**

Replace the upstream block:

```nginx
upstream nodejs_backend {
    least_conn;  # Routes to server with least active connections
    server app1:3001;
    server app2:3002;
    server app3:3003;
}
```

### 3. **IP Hash (Sticky Sessions)**

```nginx
upstream nodejs_backend {
    ip_hash;  # Same client always goes to same server
    server app1:3001;
    server app2:3002;
    server app3:3003;
}
```

### 4. **Active Health Checks** (requires NGINX Plus, but can simulate with monitoring)

## Docker Compose Features

### Services Configuration

Each service in `docker-compose.yml` includes:

- **build**: Specifies Dockerfile and context
- **environment**: Sets environment variables
- **networks**: Connects to custom bridge network
- **healthcheck**: Monitors container health
- **restart**: Auto-restart policy
- **volumes**: (NGINX only) Mounts config file

### Running Commands

**Stop all containers:**
```bash
docker-compose down
```

**Stop without removing volumes:**
```bash
docker-compose down --volumes
```

**View logs:**
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs nginx
docker-compose logs app1

# Follow logs in real-time
docker-compose logs -f
```

**Restart a service:**
```bash
docker-compose restart app1
```

**Scale a service (manually):**
```bash
docker-compose up -d --no-deps --build app1 app1 app1
# This doesn't work directly - you'd need to use docker-compose multiple times
# Or modify docker-compose.yml to add more instances
```

## Scaling Beyond 3 Apps

To add more Node.js applications:

1. Create `app4/`, `app5/`, etc. directories with `server.js`, `package.json`, and `Dockerfile`
2. Update `docker-compose.yml` to include new services
3. Update `nginx/nginx.conf` to add new upstream servers:

```nginx
upstream nodejs_backend {
    server app1:3001;
    server app2:3002;
    server app3:3003;
    server app4:3004;
    server app5:3005;
}
```

## Understanding Container Communication

### Within Docker Network
Containers communicate using **service names**:
- `app1` resolves to app1's container IP
- NGINX config: `proxy_pass http://app1:3001`

### External Access
External clients access through NGINX on **localhost:80**:
- Browser: `http://localhost/`
- CURL: `curl http://localhost`

## Performance Monitoring

### Docker Stats

Monitor resource usage in real-time:

```bash
docker stats
```

This shows CPU%, memory usage, I/O, and network stats for each container.

### NGINX Status Page

View connection statistics:

```bash
curl http://localhost/nginx_status
```

Output shows:
- Active connections
- Server connections (accepts, handled, requests)
- Reading, Writing, Waiting states

## Troubleshooting

### Container Fails to Start

```bash
# Check logs
docker-compose logs app1

# Check if port is already in use
lsof -i :3001
```

### NGINX Can't Reach Backends

1. Verify containers are running: `docker-compose ps`
2. Check network: `docker network ls`
3. Test connectivity: `docker exec nginx-proxy ping app1`

### Load Balancing Not Working

1. Verify NGINX config: `docker exec nginx-proxy nginx -t`
2. Check upstream directive in config file
3. Ensure all backends are healthy: `curl http://localhost/health`

## Learning Resources

### Key Technologies:

1. **NGINX**
   - Reverse Proxy: Routes requests to backend servers
   - Load Balancing: Distributes traffic
   - Static file serving
   - SSL/TLS termination

2. **Docker**
   - Containerization: Packaging apps with dependencies
   - Docker Compose: Multi-container orchestration
   - Networks: Container communication
   - Health Checks: Automated monitoring

3. **Node.js/Express**
   - HTTP server
   - Request routing
   - Middleware pattern

### Next Steps for Learning:

1. **Experiment with different load balancing algorithms** (weighted, least connections, IP hash)
2. **Add SSL/TLS** with self-signed certificates
3. **Implement caching** in NGINX to improve performance
4. **Add logging and monitoring** (ELK stack, Prometheus)
5. **Deploy to Kubernetes** for advanced orchestration
6. **Implement session persistence** if you have stateful apps
7. **Add rate limiting** in NGINX to prevent abuse

## Common Use Cases

### API Gateway
Use NGINX as an API gateway in front of multiple microservices.

### A/B Testing
Use `split_clients` directive to route traffic to different versions.

### Cache Layer
Add caching directives to NGINX for improved performance.

### Security
- SSL/TLS encryption
- Rate limiting
- IP whitelisting
- Request validation

## Files Overview

| File | Purpose |
|------|---------|
| `app*/server.js` | Express.js application with health checks and endpoints |
| `app*/Dockerfile` | Multi-stage build for optimized Node.js images |
| `nginx/nginx.conf` | Upstream definition, load balancing, and proxy settings |
| `nginx/Dockerfile` | Builds NGINX image with custom config |
| `docker-compose.yml` | Orchestrates all services with networking and health checks |

---

**Happy Learning!** 🚀
