const express = require('express');
const os = require('os');
const app = express();

const PORT = process.env.PORT || 3001;
const APP_NAME = process.env.APP_NAME || 'App1';

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: `Hello from ${APP_NAME}`,
    hostname: os.hostname(),
    uptime: process.uptime(),
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    app: APP_NAME,
    uptime: process.uptime()
  });
});

app.get('/api/data', (req, res) => {
  res.json({
    app: APP_NAME,
    server: os.hostname(),
    data: {
      cpu_count: os.cpus().length,
      platform: os.platform(),
      memory_total: os.totalmem(),
      memory_free: os.freemem()
    }
  });
});

// Heavy computation endpoint for load testing
app.get('/compute', (req, res) => {
  const iterations = parseInt(req.query.iterations) || 100000000;
  let sum = 0;
  
  const start = Date.now();
  for (let i = 0; i < iterations; i++) {
    sum += Math.sqrt(i);
  }
  const duration = Date.now() - start;
  
  res.json({
    app: APP_NAME,
    server: os.hostname(),
    computation: 'sum of square roots',
    iterations,
    result: sum,
    duration_ms: duration
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`${APP_NAME} running on port ${PORT}`);
  console.log(`Hostname: ${os.hostname()}`);
  console.log(`Process ID: ${process.pid}`);
});

// Export app for testing
module.exports = app;
