const request = require('supertest');
const app = require('./server');

describe('App1 API Tests', () => {
  describe('GET /', () => {
    it('should return 200 status', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
    });

    it('should return JSON response', async () => {
      const response = await request(app).get('/');
      expect(response.type).toMatch(/json/);
    });

    it('should contain message', async () => {
      const response = await request(app).get('/');
      expect(response.body.message).toBeDefined();
    });

    it('should contain hostname', async () => {
      const response = await request(app).get('/');
      expect(response.body.hostname).toBeDefined();
    });
  });

  describe('GET /health', () => {
    it('should return 200 status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
    });

    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.body.status).toBe('healthy');
    });

    it('should contain uptime', async () => {
      const response = await request(app).get('/health');
      expect(response.body.uptime).toBeGreaterThan(0);
    });
  });

  describe('GET /api/data', () => {
    it('should return 200 status', async () => {
      const response = await request(app).get('/api/data');
      expect(response.status).toBe(200);
    });

    it('should contain system data', async () => {
      const response = await request(app).get('/api/data');
      expect(response.body.data).toBeDefined();
      expect(response.body.data.cpu_count).toBeGreaterThan(0);
    });
  });

  describe('GET /compute', () => {
    it('should return 200 status', async () => {
      const response = await request(app).get('/compute?iterations=100000');
      expect(response.status).toBe(200);
    });

    it('should return computation result', async () => {
      const response = await request(app).get('/compute?iterations=100000');
      expect(response.body.result).toBeDefined();
      expect(response.body.duration_ms).toBeGreaterThan(0);
    });
  });
});