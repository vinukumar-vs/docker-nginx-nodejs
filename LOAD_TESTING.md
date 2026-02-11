# Load Testing & Performance Tuning Guide

This guide provides practical examples for load testing your Docker + NGINX + Node.js setup and optimizing performance.

## Quick Start Load Tests

### 1. Using Apache Bench (ab)

Apache Bench is lightweight and comes with most systems.

```bash
# Basic test: 100 requests
ab -n 100 http://localhost/

# With concurrency: 100 requests, 10 concurrent
ab -n 100 -c 10 http://localhost/

# More aggressive: 10,000 requests with 100 concurrent
ab -n 10000 -c 100 http://localhost/

# GET specific endpoint
ab -n 1000 -c 20 http://localhost/api/data

# POST request example
ab -n 100 -c 10 -p data.json -T application/json http://localhost/
```

### 2. Using curl with Loop (Simple Method)

```bash
# Sequential requests (easy to observe round-robin)
for i in {1..10}; do curl http://localhost/; echo ""; done

# Parallel requests (20 at once)
for i in {1..20}; do curl http://localhost/ & done; wait

# Simulate sustained load (100 requests over 10 seconds)
for i in {1..100}; do curl http://localhost/api/data > /dev/null & sleep 0.1; done
```

### 3. Using watch Command (Real-time Monitoring)

```bash
# Terminal 1: Watch NGINX status
watch -n 1 'curl -s http://localhost/nginx_status'

# Terminal 2: Run load test
ab -n 1000 -c 50 http://localhost/
```

### 4. Using xargs for Parallel Requests

```bash
# 50 parallel requests
seq 1 50 | xargs -P 50 -I {} curl http://localhost/

# 100 parallel requests to compute endpoint
seq 1 100 | xargs -P 100 -I {} curl 'http://localhost/compute?iterations=50000000'
```

## Intermediate Load Testing

### CPU-Intensive Workload

```bash
# Single heavy computation
curl 'http://localhost/compute?iterations=500000000'

# Multiple concurrent heavy computations
ab -n 50 -c 10 'http://localhost/compute?iterations=100000000'

# Watch which servers handle the load
watch -n 0.5 'curl -s http://localhost/nginx_status'
```

### Sustained Load Test

```bash
# Generate constant requests over 30 seconds
timeout 30 bash -c 'while true; do curl http://localhost > /dev/null; done'

# With multiple concurrent streams
timeout 30 bash -c 'for i in {1..10}; do (while true; do curl http://localhost > /dev/null; done) & done; wait'
```

### Request Rate Analysis

```bash
# Make requests and count responses per second
seq 1 60 | xargs -P 10 -I {} curl http://localhost/ 2>/dev/null | grep -c app

# Count which app got how many requests
seq 1 100 | xargs -P 20 -I {} curl -s http://localhost/ | jq '.app' | sort | uniq -c
```

## Advanced Tools

### Using hey (Modern alternative to ab)

Install: `go install github.com/rakyll/hey@latest`

```bash
# Basic load test
hey -n 1000 -c 50 http://localhost/

# With custom headers
hey -n 1000 -c 50 -H "X-Custom: value" http://localhost/

# Extended output
hey -n 1000 -c 50 -o results.txt http://localhost/
```

### Using wrk (High-performance HTTP benchmarking tool)

Install: `brew install wrk` (macOS) or build from source

```bash
# Basic test: 4 threads, 100 connections, 30 seconds
wrk -t4 -c100 -d30s http://localhost/

# With custom script
wrk -t4 -c100 -d30s -s script.lua http://localhost/

# View detailed stats
wrk -t4 -c100 -d10s --latency http://localhost/
```

### Using siege (Another popular tool)

Install: `brew install siege`

```bash
# Simple run
siege -c 10 -r 100 http://localhost/

# With URLs file
siege -f urls.txt -c 20 -r 50

# Extended log output
siege -c 10 -r 100 -m http://localhost/
```

## Monitoring During Load Tests

### Terminal 1: View NGINX Status

```bash
watch -n 1 'curl -s http://localhost/nginx_status'
```

### Terminal 2: Docker Stats

```bash
docker stats --no-stream

# Or continuous
docker stats
```

### Terminal 3: View Container Logs

```bash
# All containers
docker-compose logs -f

# Specific service
docker-compose logs -f app1

# Follow with filtering
docker-compose logs -f | grep app1
```

### Terminal 4: Run Load Test

```bash
ab -n 5000 -c 100 http://localhost/
```

## Sample Test Scenarios

### Scenario 1: Verify Round-Robin Load Balancing

**Goal:** Confirm each app receives roughly equal traffic

```bash
#!/bin/bash
echo "Testing round-robin load balancing..."

# Make 30 requests
for i in {1..30}; do
    curl -s http://localhost/ | jq '.app'
done | sort | uniq -c

# Expected output:
# ~10 App1
# ~10 App2
# ~10 App3
```

### Scenario 2: Capacity Testing

**Goal:** Find breaking point of the system

```bash
#!/bin/bash

# Start with light load
echo "Testing with 10 concurrent requests..."
ab -n 100 -c 10 http://localhost/

echo "Testing with 50 concurrent requests..."
ab -n 500 -c 50 http://localhost/

echo "Testing with 100 concurrent requests..."
ab -n 1000 -c 100 http://localhost/

echo "Testing with 200 concurrent requests..."
ab -n 2000 -c 200 http://localhost/
```

### Scenario 3: Response Time Analysis

```bash
#!/bin/bash

# Generate requests and measure response times
for i in {1..50}; do
    time curl http://localhost/ > /dev/null
done
```

### Scenario 4: Backend Health Under Load

```bash
#!/bin/bash

# Check health while running load test in background
ab -n 5000 -c 50 http://localhost/ &
BG_PID=$!

# Monitor backend health every second
for i in {1..10}; do
    echo "=== Check $i ==="
    curl -s http://localhost/health | jq '.'
    sleep 1
done

wait $BG_PID
```

## Expected Behavior Observations

### Normal Operation
- Each request should go to different apps (round-robin)
- Response times should be < 100ms for basic requests
- Health checks should pass
- NGINX should show steady connection counts

### Under Heavy Load
- Response times increase due to CPU utilization
- Some requests may timeout if overloaded
- NGINX buffers connections
- The compute endpoint shows varying times per server

### Bottleneck Identification

**CPU Bound:**
- Response times increase linearly with load
- CPU usage goes to 100%
- Solution: Optimize code or add more instances

**Network Bound:**
- Bandwidth limit reached
- Solution: Increase network capacity or optimize payloads

**I/O Bound:**
- Disk activity high
- Solution: Add caching, optimize queries

## Performance Tuning Tips

### NGINX Configuration

1. **Increase Worker Processes:**
```nginx
worker_processes auto;  # Uses CPU count
worker_connections 4096;  # Per worker
```

2. **Enable Compression:**
```nginx
gzip on;
gzip_types text/plain application/json;
gzip_min_length 1000;
```

3. **Caching:**
```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m;
proxy_cache my_cache;
proxy_cache_valid 200 1m;
```

### Docker Optimization

1. **Resource Limits:**
```yaml
services:
  app1:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

2. **Multi-stage Builds:** Already implemented in Dockerfile

3. **Image Size:** Use alpine images (already done)

### Node.js Optimization

1. **Use Production Mode:**
```bash
NODE_ENV=production
```

2. **Enable Clustering:** (Multi-process)
```javascript
const cluster = require('cluster');
// Fork for each CPU
```

3. **Connection Pooling:** Reuse connections

## Interpreting ab Output

```
Server Software:        nginx
Server Hostname:        localhost
Server Port:            80
Document Path:          /
Document Length:        156 bytes
Concurrency Level:      10
Time taken for tests:   2.345 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      18000 bytes
HTML transferred:       15600 bytes
Requests per second:    42.64 [#/sec] (mean)
Time per request:       234.52 [ms] (mean)
Time per request:       23.45 [ms] (mean, across all concurrent requests)
Transfer rate:          7.50 [Kbytes/sec] received

Connection Times (ms)
                min  mean[+/-sd] median   max
Connect:        10   20  15.2      15      50
Processing:     50  150  40.3     140     200
Waiting:        45  140  35.1     135     195
Total:          65  175  45.2     160     250
```

**Key Metrics:**
- **Requests per second:** Throughput
- **Time per request:** Latency (important for user experience)
- **Transfer rate:** Bandwidth
- **Connection Times:** Breakdown of latency

## Creating Realistic Load Tests

### User Session Simulation

```bash
# Simulate 10 users, each making 5 requests
for user in {1..10}; do
    for request in {1..5}; do
        curl http://localhost/ &
        sleep 0.5  # Time between requests
    done
    sleep 2  # Time between user sessions
done
wait
```

### Mixed Request Types

```bash
# 70% basic requests, 20% API data, 10% compute
for i in {1..100}; do
    rand=$((RANDOM % 100))
    if [ $rand -lt 70 ]; then
        curl http://localhost/ &
    elif [ $rand -lt 90 ]; then
        curl http://localhost/api/data &
    else
        curl 'http://localhost/compute?iterations=50000000' &
    fi
done
wait
```

## Automated Load Test Script

```bash
#!/bin/bash

# load_test.sh - Comprehensive load testing script

LOG_FILE="load_test_$(date +%Y%m%d_%H%M%S).log"

echo "=== Load Test Report ===" | tee $LOG_FILE
echo "Date: $(date)" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

# Test 1: Basic Load
echo "Test 1: Basic Load (100 req, 10 concurrent)" | tee -a $LOG_FILE
ab -n 100 -c 10 http://localhost/ 2>&1 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

# Test 2: Moderate Load
echo "Test 2: Moderate Load (500 req, 50 concurrent)" | tee -a $LOG_FILE
ab -n 500 -c 50 http://localhost/ 2>&1 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

# Test 3: Heavy Load
echo "Test 3: Heavy Load (1000 req, 100 concurrent)" | tee -a $LOG_FILE
ab -n 1000 -c 100 http://localhost/ 2>&1 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

echo "Report saved to $LOG_FILE"
```

---

**Pro Tips:**
- Always warm up servers before testing
- Test during off-peak hours
- Gradually increase load (ramp-up)
- Use realistic request distributions
- Monitor both request side and server side
