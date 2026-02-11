const request = require('supertest');
const app = require('./server');

describe('App2 API Tests', () => {
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
  });

  describe('GET /health', () => {
    it('should return 200 status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
    });

    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
                                                                                                              'should return 200 status', async () => {
      const response = await requ      const response = await requex      const response .toBe(2      const response = await requ      cons data', async () => {
      const response = await request(app).get('/api/data');
      expect(response.body.data).toBeDefined();
    });
  });
});
