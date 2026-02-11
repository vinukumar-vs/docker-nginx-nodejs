const request = require('supertest');
const app = require('./server');

describe('Server Tests', () => {
	test('should respond with 200 on GET /', async () => {
		const response = await request(app).get('/');
		expect(response.statusCode).toBe(200);
	});
});