# Architecture Overview

## System Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                        EXTERNAL CLIENT                          │
│                      (Browser/curl/ab)                          │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     │ http://localhost (port 80)
                     │
┌────────────────────▼─────────────────────────────────────────────┐
│                    NGINX CONTAINER                               │
│                   (Reverse Proxy)                                │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  NGINX Reverse Proxy Configuration                      │   │
│  │  ┌─ Listens on port 80                                  │   │
│  │  ├─ Round-robin load balancing                          │   │
│  │  ├─ Upstream servers: app1:3001, app2:3002, app3:3003  │   │
│  │  ├─ Request routing to backend                          │   │
│  │  ├─ Header manipulation                                 │   │
│  │  └─ Status monitoring at /nginx_status                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  Routes:                                                          │
│  / (root)          → Upstream group (round-robin)               │
│  /health           → All backends                               │
│  /api/data         → All backends                               │
│  /compute          → All backends (extended timeout)            │
│  /nginx_status     → NGINX monitoring                           │
└────────────────────┬─────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        │ (3001)     │ (3002)     │ (3003)
        │            │            │
┌───────▼──────┐ ┌──▼─────────┐ ┌──▼──────────┐
│   APP 1      │ │   APP 2    │ │   APP 3     │
│  Node.js     │ │  Node.js   │ │  Node.js    │
│  Express     │ │  Express   │ │  Express    │
│              │ │            │ │             │
│  Endpoints:  │ │ Endpoints: │ │ Endpoints:  │
│  / → Info    │ │ / → Info   │ │ / → Info    │
│  /health     │ │ /health    │ │ /health     │
│  /api/data   │ │ /api/data  │ │ /api/data   │
│  /compute    │ │ /compute   │ │ /compute    │
│              │ │            │ │             │
│  Health: ✓   │ │ Health: ✓  │ │ Health: ✓   │
└──────────────┘ └────────────┘ └─────────────┘
```

## Data Flow

### 1. Client Makes Request
```
Browser/curl → http://localhost/
```

### 2. NGINX Receives Request
```
NGINX listens on port 80
Checks upstream configuration
Selects next server in round-robin order
```

### 3. Round-Robin Selection
```
Request 1 → app1:3001
Request 2 → app2:3002  
Request 3 → app3:3003
Request 4 → app1:3001 (cycle repeats)
```

### 4. Backend Processing
```
Node.js app receives request
Executes handler (/ → returns info)
Returns response to NGINX
```

### 5. Response to Client
```
NGINX receives response from backend
Adds/modifies headers (X-Real-IP, etc.)
Sends response to client
```

## Network Communication

```
┌────────────────────────────────────────────┐
│     Docker Network: nodejs_network         │
│     Type: Bridge Network                   │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  NGINX Container                     │ │
│  │  hostname: nginx                     │ │
│  │  IP: 172.20.0.2 (example)           │ │
│  │  Can reach: app1, app2, app3        │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  App1 Container                      │ │
│  │  hostname: app1                      │ │
│  │  IP: 172.20.0.3 (example)           │ │
│  │  Internal port: 3001                │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  App2 Container                      │ │
│  │  hostname: app2                      │ │
│  │  IP: 172.20.0.4 (example)           │ │
│  │  Internal port: 3002                │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  App3 Container                      │ │
│  │  hostname: app3                      │ │
│  │  IP: 172.20.0.5 (example)           │ │
│  │  Internal port: 3003                │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  Internal DNS Resolution:                 │
│  app1 → 172.20.0.3                       │
│  app2 → 172.20.0.4                       │
│  app3 → 172.20.0.5                       │
│  nginx → 172.20.0.2                      │
└────────────────────────────────────────────┘
```

## Port Mapping

```
┌─────────────────────────────────────────────────┐
│         Port Mapping (Host → Container)         │
├─────────────────────────────────────────────────┤
│  80:80       → NGINX (external access)          │
│  3001:3001   → App1 (direct access if needed)   │
│  3002:3002   → App2 (direct access if needed)   │
│  3003:3003   → App3 (direct access if needed)   │
└─────────────────────────────────────────────────┘

Typical Access:
  External:  curl http://localhost/       → NGINX (port 80)
  Internal:  http://app1:3001/           → App1 directly
  Internal:  http://app2:3002/           → App2 directly
```

## Container Lifecycle

```
docker-compose up
        │
        ▼
┌──────────────────────┐
│  Build Images        │
│ (if using --build)   │
└──────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│  Create Network: nodejs_network (bridge)     │
└──────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│  Start Containers (parallel):                │
│  • NGINX                                     │
│  • App1 → Health check every 30s             │
│  • App2 → Health check every 30s             │
│  • App3 → Health check every 30s             │
└──────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│  All Services Running                        │
│  Ready to accept requests                    │
│  Monitoring health checks                    │
│  Auto-restart on failure (restart policy)    │
└──────────────────────────────────────────────┘
```

## Request Flow Example

```
CLIENT REQUEST: curl http://localhost/api/data

Step 1: TCP Connection
┌─────────────┐
│   CLIENT    │ ──SYN──────────────────────> │
│             │                               │ NGINX:80
│             │ <──SYN+ACK────────────────── │
│             │ ──ACK──────────────────────> │
└─────────────┘                               │
                                              
Step 2: HTTP Request
│ GET /api/data HTTP/1.1       ──────────────>
│ Host: localhost              ──────────────>
│ User-Agent: curl/7.0         ──────────────>
                                              
Step 3: NGINX Processing
│ • Parses request
│ • Matches location block: /api/data
│ • Selects upstream: app2:3002 (round-robin)
│ • Adds headers:
│   X-Real-IP: 127.0.0.1
│   X-Forwarded-For: 127.0.0.1
│ • Forwards to app2

Step 4: App2 Processing
│                               ──────────────>
│ GET /api/data HTTP/1.1       ──────────────> │
│ (with NGINX headers)         ──────────────> │ APP2:3002
│                               ──────────────>
│                               │
│                               └─> Process request
│                                  → Return JSON
│                                  ──────────────>

Step 5: Response
│                               <──────────────
│ HTTP/1.1 200 OK              <──────────────
│ Content-Type: application/json
│ {                            <──────────────
│   "app": "App2",            <──────────────
│   "data": {...}             <──────────────
│ }                            <──────────────

Step 6: NGINX Forwards Response
│ <──────────────────────────── Receives response
│ <──────────────────────────── Adds cache headers
│ <──────────────────────────── Forwards to client

Step 7: Client Receives
│ HTTP/1.1 200 OK              <──────────────
│ Content-Type: application/json
│ {                            <──────────────
│   "app": "App2",            <──────────────
│   "data": {...}             <──────────────
│ }                            <──────────────
```

## Load Distribution Pattern

```
Timeline: Multiple Sequential Requests

Time    Client      NGINX       App1    App2    App3
────────────────────────────────────────────────────
t1      Request 1 ──────────────────> (selected)
        ✓ Response <──────────────────
                                       
t2      Request 2 ──────────────────────────> (selected)
        ✓ Response <──────────────────────────
                                       
t3      Request 3 ────────────────────────────────> (selected)
        ✓ Response <────────────────────────────────
                                       
t4      Request 4 ──────────────────> (selected - cycle restart)
        ✓ Response <──────────────────
                                       
t5      Request 5 ──────────────────────────> (selected)
        ✓ Response <──────────────────────────
                                       
t6      Request 6 ────────────────────────────────> (selected)
        ✓ Response <────────────────────────────────

Distribution:
App1: Requests 1, 4 (33%)
App2: Requests 2, 5 (33%)
App3: Requests 3, 6 (33%)
```

## Health Check Cycle

```
Every 30 seconds:

NGINX/App1         NGINX/App2         NGINX/App3
    │                  │                  │
    ├─ check ──────────────────────────────>
    │
    ├──────────────────────────────> /health
    │                                     │
    │                                     ├─> Process
    │                                     └─> 200 OK
    │
    │ <──────────────────────────── 200 OK
    │
    └─ Health: ✓   ✓   ✓ (All healthy)

If health check fails 3 times:
    └─ Container restart (restart: unless-stopped)
```

## Scaling Illustration

### Current Setup (3 apps)
```
NGINX (load factor: 1/3 per app)
  ├─ App1 (33% traffic)
  ├─ App2 (33% traffic)
  └─ App3 (33% traffic)
```

### Scaled to 5 apps
```
NGINX (load factor: 1/5 per app)
  ├─ App1 (20% traffic)
  ├─ App2 (20% traffic)
  ├─ App3 (20% traffic)
  ├─ App4 (20% traffic)
  └─ App5 (20% traffic)
```

### With Weighted Load Balancing
```
NGINX
  ├─ App1 weight=3 (43% traffic)
  ├─ App2 weight=2 (28% traffic)
  └─ App3 weight=1 (29% traffic)
```

---

This architecture provides:
- ✅ High availability (multiple backend instances)
- ✅ Load distribution (round-robin)
- ✅ Fault tolerance (health checks)
- ✅ Scalability (easily add more apps)
- ✅ Container orchestration (Docker Compose)
- ✅ Production-ready setup (best practices)
