const http = require('http');

describe('Server Tests', () => {
  test('should return 200 for the home page', done => {
    http.get('http://localhost:3000', (res) => {
      expect(res.statusCode).toBe(200);
      done();
    });
  });
});
