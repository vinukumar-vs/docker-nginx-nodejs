# Docker + NGINX + Node.js Learning Project - Complete Index

## 📋 Project Overview

A comprehensive learning environment demonstrating **Docker containerization**, **NGINX reverse proxy**, and **Node.js application scaling** with load balancing.

**Location:** `/Users/vinukumar/Documents/projects/experiments/Docker/docker-containers/`

---

## 🚀 Quick Start (2 minutes)

```bash
cd /Users/vinukumar/Documents/projects/experiments/Docker/docker-containers

# Start all services
docker-compose up --build

# In another terminal, test it
curl http://localhost/
```

**Expected output:** JSON response showing which app handled the request

---

## 📂 Project Structure

```
docker-containers/
│
├── 📄 Documentation Files (700+ lines)
│   ├── README.md                 ← Main documentation (START HERE)
│   ├── GETTING_STARTED.md        ← 3-step quick start guide
│   ├── ARCHITECTURE.md           ← System diagrams & data flow
│   ├── LOAD_TESTING.md           ← Testing techniques & tools
│   ├── TROUBLESHOOTING.md        ← Problem solving guide
│   ├── QUICK_COMMANDS.sh         ← Copy-paste commands
│   └── PROJECT_SUMMARY.md        ← Overview & progression
│
├── 🐳 Application Containers (3x Node.js)
│   ├── app1/
│   │   ├── server.js             ← Express.js application
│   │   ├── package.json          ← Dependencies
│   │   └── Dockerfile            ← Multi-stage build
│   ├── app2/
│   │   ├── server.js
│   │   ├── package.json
│   │   └── Dockerfile
│   └── app3/
│       ├── server.js
│       ├── package.json
│       └── Dockerfile
│
├── 🔧 Infrastructure
│   ├── nginx/
│   │   ├── nginx.conf            ← Load balancing config
│   │   └── Dockerfile            ← NGINX container image
│   └── docker-compose.yml        ← Container orchestration
│
└── ⚙️ Configuration
    └── .gitignore                ← Git ignore patterns
```

---

## 📖 Documentation Guide

### For Different Learning Levels

**🟢 Beginner (Just Starting)**
1. Start: [GETTING_STARTED.md](GETTING_STARTED.md)
2. Then: [README.md](README.md) - Concepts section
3. Run: Basic commands from [QUICK_COMMANDS.sh](QUICK_COMMANDS.sh)

**🟡 Intermediate (Learning the Details)**
1. Study: [ARCHITECTURE.md](ARCHITECTURE.md) - System diagrams
2. Read: [README.md](README.md) - Full document
3. Experiment: Modify `nginx/nginx.conf`
4. Practice: Commands from [LOAD_TESTING.md](LOAD_TESTING.md)

**🔴 Advanced (Production Ready)**
1. Review: [ARCHITECTURE.md](ARCHITECTURE.md) - Data flow
2. Study: Dockerfiles for multi-stage builds
3. Practice: All commands in [LOAD_TESTING.md](LOAD_TESTING.md)
4. Troubleshoot: Issues in [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📚 Documentation Files Explained

| File | Size | Purpose | Read When |
|------|------|---------|-----------|
| [README.md](README.md) | 400+ lines | Complete overview, all concepts | First, for comprehensive understanding |
| [GETTING_STARTED.md](GETTING_STARTED.md) | 300+ lines | Quick start, exercises, checklist | Before first `docker-compose up` |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 350+ lines | System diagrams, data flow, networking | Want to understand how it works |
| [LOAD_TESTING.md](LOAD_TESTING.md) | 400+ lines | Testing techniques, tools, scenarios | Ready to test and benchmark |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 300+ lines | Problem solving, error messages | Something doesn't work |
| [QUICK_COMMANDS.sh](QUICK_COMMANDS.sh) | 200+ lines | Copy-paste ready commands | Need a command quickly |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | 250+ lines | Overview, learning path, stats | Want big picture summary |

---

## 🎯 Learning Paths

### Path 1: Understanding the Architecture (2-3 hours)
```
1. GETTING_STARTED.md (read + run exercises)
2. ARCHITECTURE.md (study diagrams)
3. README.md → Concepts section
4. docker-compose.yml (read and understand)
5. nginx/nginx.conf (understand each directive)
```

### Path 2: Practical Testing (4-5 hours)
```
1. GETTING_STARTED.md (setup)
2. QUICK_COMMANDS.sh (run basic tests)
3. LOAD_TESTING.md (progressively more intense tests)
4. docker stats (monitor during tests)
5. Analyze results and learn patterns
```

### Path 3: Production Readiness (6-8 hours)
```
1. All previous paths
2. TROUBLESHOOTING.md (understand issues)
3. Modify nginx.conf (try different algorithms)
4. Add 4th app (test scaling)
5. Run comprehensive load tests
6. Analyze bottlenecks and optimize
```

---

## 🏃 Typical Workflow

### Day 1: Setup & First Run
```bash
# 1. Navigate to project
cd /Users/vinukumar/Documents/projects/experiments/Docker/docker-containers

# 2. Read quick start
cat GETTING_STARTED.md

# 3. Start everything
docker-compose up --build

# 4. In another terminal, test
curl http://localhost/

# 5. Verify round-robin
for i in {1..9}; do curl -s http://localhost/ | jq '.app'; done

# 6. Stop with Ctrl+C
```

### Day 2: Understand the System
```bash
# 1. Study architecture
cat ARCHITECTURE.md

# 2. Check container status
docker-compose ps
docker stats

# 3. Review configurations
cat nginx/nginx.conf
cat docker-compose.yml

# 4. Test various endpoints
curl http://localhost/
curl http://localhost/health
curl http://localhost/api/data | jq '.'
curl http://localhost/nginx_status
```

### Day 3: Load Testing
```bash
# 1. Read load testing guide
cat LOAD_TESTING.md

# 2. Run basic test
ab -n 100 -c 10 http://localhost/

# 3. Monitor during test
docker stats  # in one terminal
ab -n 1000 -c 50 http://localhost/  # in another

# 4. Check request distribution
for i in {1..30}; do curl -s http://localhost/ | jq '.app'; done | sort | uniq -c

# 5. Analyze NGINX status
curl http://localhost/nginx_status
```

### Day 4: Experimentation
```bash
# 1. Modify nginx.conf
# Edit nginx/nginx.conf (try weighted balancing)

# 2. Rebuild and restart
docker-compose up --build

# 3. Test new configuration
ab -n 500 -c 20 http://localhost/

# 4. Add 4th app instance
# Create app4/ directory with copy of app1

# 5. Update docker-compose.yml
# Update nginx.conf upstream
```

---

## 💡 Key Concepts Quick Reference

### Docker
- **Container**: Isolated application environment
- **Image**: Blueprint for creating containers
- **Dockerfile**: Instructions to build an image
- **Docker Compose**: Multi-container orchestration
- **Network**: Communication between containers
- **Health Check**: Automated monitoring

### NGINX
- **Reverse Proxy**: Routes client requests to backend servers
- **Load Balancing**: Distributes traffic across backends
- **Upstream**: Group of backend servers
- **Round-robin**: Default distribution (sequential)
- **Keep-alive**: Reuse connections for efficiency

### Node.js/Express
- **Express**: Web framework for building HTTP servers
- **Routes**: URL endpoints that handle requests
- **Middleware**: Functions that process requests
- **Port**: Network interface for communication
- **Environment Variables**: Configuration values

---

## ✅ Verification Checklist

### Prerequisites
- [ ] Docker Desktop installed
- [ ] Docker running (check system tray)
- [ ] Terminal/command line access
- [ ] 1-2 GB free disk space
- [ ] Port 80 available (check: `lsof -i :80`)

### After Setup
- [ ] Project directory exists with all files
- [ ] `docker-compose.yml` present
- [ ] 3 app folders (app1, app2, app3)
- [ ] nginx folder with config and Dockerfile
- [ ] All documentation files present

### After `docker-compose up --build`
- [ ] All 4 containers started successfully
- [ ] NGINX listening on port 80
- [ ] Apps running on ports 3001-3003
- [ ] Health checks passing
- [ ] `curl http://localhost/` returns JSON

---

## 🔧 Common Commands

### Start & Stop
```bash
docker-compose up --build              # Start all (rebuild)
docker-compose up                      # Start (use existing images)
docker-compose down                    # Stop all
docker-compose logs -f                 # Follow all logs
```

### Testing
```bash
curl http://localhost/                 # Basic test
ab -n 100 -c 10 http://localhost/     # Load test
docker stats                           # Monitor resources
```

### Debugging
```bash
docker-compose ps                      # Check status
docker-compose logs app1               # View logs
docker exec nginx-proxy nginx -t       # Check NGINX syntax
docker exec app1 curl http://app1:3001/health  # Test backend
```

---

## 📊 What You're Learning

### Technologies
✅ Docker (containerization)  
✅ Docker Compose (orchestration)  
✅ NGINX (reverse proxy)  
✅ Node.js / Express.js  
✅ Linux / Bash  

### Concepts
✅ Load balancing algorithms  
✅ Reverse proxy architecture  
✅ Container networking  
✅ Health monitoring  
✅ Performance testing  
✅ Scaling strategies  

### Skills
✅ Reading and writing Dockerfiles  
✅ Composing multi-container apps  
✅ Configuring NGINX  
✅ Load testing  
✅ Monitoring systems  
✅ Troubleshooting containers  

---

## 🎓 Next Learning Milestones

### After Basic Understanding (Week 1)
- [ ] Can start/stop system
- [ ] Understand round-robin distribution
- [ ] Know what each file does
- [ ] Can run basic load test

### After Intermediate Practice (Week 2-3)
- [ ] Can modify NGINX config
- [ ] Can add new app instances
- [ ] Can interpret load test results
- [ ] Can identify bottlenecks

### After Advanced Study (Week 4+)
- [ ] Can implement weighted load balancing
- [ ] Can optimize configuration
- [ ] Can scale to 10+ instances
- [ ] Can deploy to cloud
- [ ] Can explain every line of code

---

## 🐛 When Something Goes Wrong

1. **Check Status:** `docker-compose ps`
2. **Review Logs:** `docker-compose logs`
3. **Test Connectivity:** `curl http://localhost/`
4. **Read Guide:** Open [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
5. **Search for Issue:** Find your error message in guide
6. **Follow Solution:** Execute suggested commands

---

## 📞 Quick Help

**Containers won't start?**
```bash
docker-compose logs
docker-compose down -v
docker-compose up --build
```

**Can't access localhost:80?**
```bash
lsof -i :80                    # Check what's using port
curl http://localhost/         # Verify it works
```

**Load balancing not working?**
```bash
for i in {1..30}; do curl -s http://localhost/ | jq '.app'; done | sort | uniq -c
```

**Want to see detailed request flow?**
```bash
curl -v http://localhost/
```

---

## 📈 Performance Expectations

### Without Load
```
Response time: 5-10ms
Requests per second: 100+
CPU usage: <5%
Memory usage: ~100MB
```

### With Moderate Load (ab -n 1000 -c 50)
```
Response time: 50-100ms
Requests per second: 50-100
CPU usage: 20-40%
Memory usage: ~150MB
```

### With Heavy Load (ab -n 5000 -c 100)
```
Response time: 100-500ms
Requests per second: 50-80
CPU usage: 60-80%
Memory usage: ~200MB
```

---

## 🎯 Learning Objectives

After completing this project, you should be able to:

### Understand
- [ ] How Docker containerization works
- [ ] How NGINX load balancing distributes traffic
- [ ] How containers communicate in a Docker network
- [ ] How health checks enable self-healing
- [ ] How to measure performance with load tests

### Do
- [ ] Build Docker images from Dockerfiles
- [ ] Orchestrate multiple containers with Docker Compose
- [ ] Configure NGINX for different load balancing strategies
- [ ] Run load tests and analyze results
- [ ] Troubleshoot common container issues

### Explain
- [ ] Why we need a reverse proxy
- [ ] How round-robin load balancing works
- [ ] What happens when a backend fails
- [ ] Why Docker makes deployment easier
- [ ] How to scale applications horizontally

---

## 📝 Files at a Glance

### Application Files (Node.js)
```
app1/server.js          Express.js app, 70 lines
app1/package.json       Dependencies, 15 lines
app1/Dockerfile         Multi-stage build, 25 lines
```

### Configuration Files
```
docker-compose.yml      Full orchestration, 75 lines
nginx/nginx.conf        Load balancing, 65 lines
nginx/Dockerfile        NGINX image, 10 lines
```

### Documentation
```
README.md               Comprehensive guide, 400+ lines
GETTING_STARTED.md      Quick start, 300+ lines
ARCHITECTURE.md         Diagrams & flow, 350+ lines
LOAD_TESTING.md         Testing guide, 400+ lines
TROUBLESHOOTING.md      Problem solving, 300+ lines
```

---

## 🚀 Your Learning Journey

```
Start Here
    ↓
GETTING_STARTED.md (read + run)
    ↓
docker-compose up --build
    ↓
Verify load balancing works
    ↓
Study ARCHITECTURE.md
    ↓
Read full README.md
    ↓
Run basic load tests (LOAD_TESTING.md)
    ↓
Modify configurations
    ↓
Add more app instances
    ↓
Run advanced load tests
    ↓
Troubleshoot issues (TROUBLESHOOTING.md)
    ↓
Deploy to cloud / Add monitoring
    ↓
Expert Status! 🎉
```

---

## 🎉 You Now Have

- ✅ Complete Docker learning environment
- ✅ Production-grade configuration
- ✅ 700+ lines of documentation
- ✅ 200+ copy-paste commands
- ✅ Real-world architecture patterns
- ✅ Multiple learning resources
- ✅ Professional setup to reference

**Everything you need to master Docker, NGINX, and scalable Node.js applications!**

---

## 🔗 Quick Navigation

| What I Want To... | Go To |
|-------------------|-------|
| Get started now | [GETTING_STARTED.md](GETTING_STARTED.md) |
| Understand the system | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Learn all details | [README.md](README.md) |
| Run load tests | [LOAD_TESTING.md](LOAD_TESTING.md) |
| Fix a problem | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| Find a command | [QUICK_COMMANDS.sh](QUICK_COMMANDS.sh) |
| See big picture | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |

---

**Ready to start? Run this command:**

```bash
cd /Users/vinukumar/Documents/projects/experiments/Docker/docker-containers && docker-compose up --build
```

**Then read:** `GETTING_STARTED.md`

**Happy Learning! 🚀**
