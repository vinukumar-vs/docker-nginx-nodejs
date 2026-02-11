#!/bin/bash

# Quick Command Reference for Docker + NGINX + Node.js Setup
# Save as: quick-commands.sh or just use as reference

# ============================================================
# DOCKER COMPOSE COMMANDS
# ============================================================

# Start all containers
docker-compose up

# Start in background
docker-compose up -d

# Build and start
docker-compose up --build

# Force recreate (useful if config changed)
docker-compose up --force-recreate

# Stop all containers
docker-compose stop

# Stop and remove everything
docker-compose down

# Stop and remove with volumes
docker-compose down -v

# View running containers
docker-compose ps

# View logs of all services
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# Logs of specific service
docker-compose logs -f app1
docker-compose logs -f nginx

# View last N lines
docker-compose logs --tail=50

# ============================================================
# TESTING ENDPOINTS
# ============================================================

# Basic health check - routes to any backend
curl http://localhost/

# Check app health
curl http://localhost/health

# Get system information
curl http://localhost/api/data

# Direct backend test (if running locally)
curl http://localhost:3001/
curl http://localhost:3002/
curl http://localhost:3003/

# ============================================================
# LOAD BALANCING VERIFICATION
# ============================================================

# Make 10 requests and show which app responds
for i in {1..10}; do curl -s http://localhost/ | jq '.app'; done

# Show count of responses per app (verify round-robin)
for i in {1..30}; do curl -s http://localhost/ | jq '.app'; done | sort | uniq -c

# Pretty print response
curl -s http://localhost/ | jq '.'

# ============================================================
# LOAD TESTING WITH APACHE BENCH (ab)
# ============================================================

# Light test: 100 requests, 10 concurrent
ab -n 100 -c 10 http://localhost/

# Moderate test: 500 requests, 50 concurrent
ab -n 500 -c 50 http://localhost/

# Heavy test: 1000 requests, 100 concurrent
ab -n 1000 -c 100 http://localhost/

# Test with more detailed stats
ab -n 1000 -c 100 -r -g results.tsv http://localhost/

# Test specific endpoint
ab -n 100 -c 10 http://localhost/api/data

# Compute endpoint (heavy workload)
ab -n 50 -c 5 'http://localhost/compute?iterations=100000000'

# ============================================================
# MONITORING
# ============================================================

# Real-time container stats
docker stats

# Watch NGINX status (server connections, waiting, etc)
watch 'curl -s http://localhost/nginx_status'

# Monitor specific container
docker stats app1

# View container details
docker inspect nginx
docker inspect app1

# ============================================================
# CONTAINER INTERACTION
# ============================================================

# Execute command in container
docker exec app1 node --version

# Get shell in container
docker exec -it app1 sh

# View container logs
docker logs app1
docker logs -f app1  # Follow
docker logs --tail=50 app1  # Last 50 lines

# Check container health
docker inspect --format='{{.State.Health.Status}}' app1

# ============================================================
# NETWORK DIAGNOSTICS
# ============================================================

# Test DNS from NGINX container
docker exec nginx-proxy nslookup app1
docker exec nginx-proxy ping app1

# Test backend connectivity
docker exec nginx-proxy curl http://app1:3001/health

# Check networks
docker network ls
docker network inspect docker-containers_nodejs_network

# ============================================================
# NGINX OPERATIONS
# ============================================================

# Check NGINX config syntax
docker exec nginx-proxy nginx -t

# View NGINX config
docker exec nginx-proxy cat /etc/nginx/conf.d/default.conf

# Reload NGINX config (no downtime)
docker exec nginx-proxy nginx -s reload

# Test through NGINX with verbose output
curl -v http://localhost/

# Check response headers
curl -i http://localhost/

# ============================================================
# LOAD WITH MULTIPLE CONCURRENT REQUESTS
# ============================================================

# 20 concurrent requests using background jobs
for i in {1..20}; do curl http://localhost/ > /dev/null & done; wait

# 100 requests using xargs
seq 1 100 | xargs -P 50 -I {} curl http://localhost/ > /dev/null

# Generate requests for 30 seconds
timeout 30 bash -c 'while true; do curl http://localhost/ > /dev/null; done'

# ============================================================
# VOLUME & RESOURCE MANAGEMENT
# ============================================================

# List volumes
docker volume ls

# Remove unused volumes
docker volume prune

# Check container resource usage
docker stats --no-stream

# Prune all unused Docker resources
docker system prune -a

# Check disk usage
docker system df

# ============================================================
# SCALING & MULTIPLE INSTANCES (Manual)
# ============================================================

# Build images without starting
docker-compose build

# Build specific service
docker-compose build app1

# Restart service
docker-compose restart app1

# Stop specific service
docker-compose stop app1

# Start specific service
docker-compose start app1

# Remove stopped containers
docker-compose rm

# ============================================================
# DEBUGGING
# ============================================================

# Check for errors
docker-compose logs | grep -i error

# Trace requests (verbose curl)
curl -v http://localhost/

# Check response timing
curl -w "Total: %{time_total}s\nConnect: %{time_connect}s\nTransfer: %{time_starttransfer}s\n" http://localhost/

# Monitor container events
docker events --filter 'container=nginx-proxy'

# View container process list
docker top app1

# ============================================================
# USEFUL COMBINATIONS
# ============================================================

# Full setup test sequence
echo "1. Checking containers..."
docker-compose ps

echo -e "\n2. Testing basic endpoint..."
curl http://localhost/

echo -e "\n3. Load balancing verification..."
for i in {1..6}; do curl -s http://localhost/ | jq '.app'; done

echo -e "\n4. Container stats..."
docker stats --no-stream

echo -e "\n5. NGINX status..."
curl http://localhost/nginx_status

# Monitor test (run load test + monitor)
echo "Starting monitoring..." &
watch docker stats &
echo "Running load test..."
ab -n 1000 -c 50 http://localhost/

# ============================================================
# TROUBLESHOOTING COMMANDS
# ============================================================

# Full diagnostic check
echo "=== Containers ==="
docker-compose ps

echo -e "\n=== Network ==="
docker network inspect docker-containers_nodejs_network

echo -e "\n=== Logs (last 20 lines) ==="
docker-compose logs --tail=20

echo -e "\n=== Test Connectivity ==="
docker exec nginx-proxy curl http://app1:3001/health

echo -e "\n=== Test Endpoint ==="
curl http://localhost/

# Reset everything (clean slate)
docker-compose down -v
docker image prune -a
docker network prune
docker-compose up --build

# ============================================================
# ONE-LINER TESTS
# ============================================================

# Is everything up and working?
curl -s http://localhost/ && echo "✓ System OK" || echo "✗ System DOWN"

# Count requests per app
seq 1 30 | xargs -P 30 -I {} curl -s http://localhost/ | jq '.app' | sort | uniq -c

# Simple load test and monitor
docker stats app1 & ab -n 500 -c 50 http://localhost/ && kill %1

# Health check all backends
for app in app1 app2 app3; do echo -n "$app: "; docker exec $app curl -s http://localhost:$(docker port $app 2>/dev/null | cut -d: -f2)/health | jq '.status'; done

# ============================================================
