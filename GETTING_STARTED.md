# Getting Started - Quick Reference

## 🚀 Start Learning in 3 Steps

### Step 1: Start the Docker Environment

```bash
cd /Users/vinukumar/Documents/projects/experiments/Docker/docker-containers

docker-compose up --build
```

Wait until you see:
```
nginx-proxy    | ... listening on port 80
nodejs-app1    | App1 running on port 3001
nodejs-app2    | App2 running on port 3002
nodejs-app3    | App3 running on port 3003
```

### Step 2: Verify Everything Works

Open a new terminal:

```bash
# Test basic endpoint
curl http://localhost/

# Check health
curl http://localhost/health

# View system info
curl http://localhost/api/data | jq '.'
```

### Step 3: Test Load Balancing

```bash
# Make 10 requests and see which apps respond
for i in {1..10}; do echo "Request $i:"; curl -s http://localhost/ | jq '.app'; done
```

Each app should get roughly equal traffic (round-robin).

## 📚 Learning Path

### Beginner Level
1. **Understand Basics** → Read [README.md](README.md)
2. **Run Simple Tests** → Use commands in [QUICK_COMMANDS.sh](QUICK_COMMANDS.sh)
3. **Verify Round-Robin** → Make requests and observe load distribution

### Intermediate Level
4. **Explore NGINX Config** → Check `nginx/nginx.conf`
5. **Run Basic Load Tests** → Use `ab` (Apache Bench) command
6. **Monitor Performance** → Use `docker stats` while running tests

### Advanced Level
7. **Study Dockerfiles** → Multi-stage builds in `app*/Dockerfile`
8. **Run Complex Load Tests** → See [LOAD_TESTING.md](LOAD_TESTING.md)
9. **Modify Configuration** → Try weighted load balancing, different algorithms
10. **Add More Services** → Scale to 4+ Node.js apps

## 🎯 What You'll Learn

### Docker Concepts
- ✅ Container images and Dockerfiles
- ✅ Multi-container orchestration with Docker Compose
- ✅ Container networking and communication
- ✅ Health checks and auto-restart policies
- ✅ Multi-stage builds for optimization

### NGINX Concepts
- ✅ Reverse proxy functionality
- ✅ Load balancing algorithms (round-robin, weighted, etc.)
- ✅ Upstream server management
- ✅ Request routing and rewriting
- ✅ Performance optimization (caching, compression)

### Node.js Concepts
- ✅ Express.js application structure
- ✅ HTTP server creation
- ✅ Middleware and routing
- ✅ Environment variables
- ✅ Docker best practices for Node.js

### DevOps Concepts
- ✅ Infrastructure as Code (Docker Compose)
- ✅ Monitoring and health checks
- ✅ Load testing and performance analysis
- ✅ Container scaling strategies
- ✅ Production-ready configurations

## 📖 Documentation Files

| File | Purpose |
|------|---------|
| [README.md](README.md) | Complete overview and concepts |
| [QUICK_COMMANDS.sh](QUICK_COMMANDS.sh) | Copy-paste ready commands |
| [LOAD_TESTING.md](LOAD_TESTING.md) | Load testing guide and examples |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Problem solving guide |
| [GETTING_STARTED.md](GETTING_STARTED.md) | This file |

## 🔧 Project Structure

```
docker-containers/
├── app1/                      # Node.js App 1 (Port 3001)
│   ├── server.js              # Express application
│   ├── package.json           # Dependencies
│   └── Dockerfile             # Multi-stage build
├── app2/                      # Node.js App 2 (Port 3002)
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── app3/                      # Node.js App 3 (Port 3003)
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── nginx/                     # NGINX Reverse Proxy
│   ├── nginx.conf             # Load balancing config
│   └── Dockerfile
├── docker-compose.yml         # Orchestration config
└── Documentation files        # Guides and references
```

## 💡 Key Concepts Explained

### Round-Robin Load Balancing
```
Request 1 → App1
Request 2 → App2
Request 3 → App3
Request 4 → App1 (cycle repeats)
```

### Docker Network
All containers talk through a **bridge network**:
```
NGINX (port 80) → Internal network → App1, App2, App3
```

### Container Health Checks
```
Every 30 seconds → Check /health endpoint
If fails 3 times → Mark unhealthy, restart
```

## 🎮 Interactive Exercises

### Exercise 1: Observe Round-Robin
```bash
for i in {1..9}; do curl -s http://localhost/ | jq '.app'; done
```
**Expected:** App1, App2, App3, App1, App2, App3, App1, App2, App3

### Exercise 2: Compare Response Times
```bash
time curl http://localhost:3001/          # Direct
time curl http://localhost/               # Through NGINX
```
**Expected:** Slightly higher latency through proxy

### Exercise 3: Basic Load Test
```bash
ab -n 100 -c 10 http://localhost/
```
**Expected:** ~33 requests per app, <100ms per request

### Exercise 4: Check Container Info
```bash
docker-compose ps
docker stats
curl http://localhost/api/data | jq '.'
```
**Expected:** 4 containers running, system info visible

### Exercise 5: Modify and Test
1. Edit `nginx/nginx.conf`
2. Change to weighted load balancing
3. Rebuild: `docker-compose up --build`
4. Test distribution

## 🔍 How to Debug

### Problem: Containers won't start
```bash
docker-compose logs
docker-compose logs app1
```

### Problem: Can't access localhost
```bash
docker-compose ps              # Check if running
curl http://localhost/health   # Test endpoint
docker logs nginx-proxy        # Check NGINX logs
```

### Problem: Unequal load distribution
```bash
# Check NGINX config
docker exec nginx-proxy cat /etc/nginx/conf.d/default.conf

# Test load distribution
for i in {1..30}; do curl -s http://localhost/ | jq '.app'; done | sort | uniq -c
```

## 🚀 Next Steps for Learning

1. **Week 1:** Basic setup and round-robin testing
2. **Week 2:** Load testing with Apache Bench and wrk
3. **Week 3:** Modify NGINX configuration (weights, algorithms)
4. **Week 4:** Add 4th and 5th Node.js apps, experiment with scaling
5. **Week 5:** Add SSL/TLS with self-signed certificates
6. **Week 6:** Implement caching in NGINX
7. **Week 7:** Add monitoring (metrics, logs)
8. **Week 8:** Deploy to Kubernetes (advanced)

## 📊 Common Load Test Results

### Light Load (ab -n 100 -c 10)
```
Requests per second: 40-50
Time per request: 20-30ms
Requests distributed: ~33-34 per server
```

### Moderate Load (ab -n 1000 -c 50)
```
Requests per second: 30-45
Time per request: 50-100ms
Requests distributed: ~333 per server
```

### Heavy Load (ab -n 5000 -c 100)
```
Requests per second: 20-40
Time per request: 100-300ms
May see some queue buildup
```

## 🎓 Learning Resources Referenced

- NGINX Documentation: https://nginx.org/en/docs/
- Docker Documentation: https://docs.docker.com/
- Node.js & Express: https://expressjs.com/
- Apache Bench: https://httpd.apache.org/docs/2.4/programs/ab.html

## 💬 Common Questions

**Q: Why 3 apps instead of 1?**  
A: To demonstrate load balancing. One app wouldn't show distribution.

**Q: Can I add more apps?**  
A: Yes! Add app4, app5 directories and update docker-compose.yml and nginx.conf

**Q: What's the difference between ports?**  
A: Internal (3001-3003) are for container communication. External (80) is for client access.

**Q: Why NGINX instead of Docker load balancer?**  
A: NGINX is industry-standard, feature-rich, and useful to learn.

**Q: How do I scale to production?**  
A: Use Kubernetes orchestration or cloud-native services (Elastic Container Service, etc.)

## ✅ Checklist for First Run

- [ ] Docker Desktop installed and running
- [ ] Navigated to project directory
- [ ] Run `docker-compose up --build`
- [ ] Wait for all containers to start
- [ ] `curl http://localhost/` returns JSON
- [ ] Make 10 requests, each shows different app
- [ ] Run `ab -n 100 -c 10 http://localhost/`
- [ ] Review NGINX config
- [ ] Explore application code
- [ ] Read through documentation

---

**Ready to start?** Run:
```bash
cd /Users/vinukumar/Documents/projects/experiments/Docker/docker-containers
docker-compose up --build
```

Then open another terminal and:
```bash
curl http://localhost/
```

**Happy learning! 🎉**
