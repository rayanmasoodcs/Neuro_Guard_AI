const http = require('http');
const app = require('./server');

console.log('[TEST] Starting NeuroGuard AI Express Backend Standalone Test...');

const server = app.listen(0, '127.0.0.1', () => {
  const port = server.address().port;
  console.log(`[TEST] Test server listening on http://127.0.0.1:${port}`);

  // Test 1: GET /
  http.get(`http://127.0.0.1:${port}/`, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      console.log('[TEST 1 GET /] Status:', res.statusCode);
      console.log('[TEST 1 GET /] Response:', data);

      // Test 2: POST /signup with invalid payload
      const postData = JSON.stringify({ name: 'Test' });
      const req = http.request(`http://127.0.0.1:${port}/signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData)
        }
      }, (res2) => {
        let data2 = '';
        res2.on('data', chunk => data2 += chunk);
        res2.on('end', () => {
          console.log('[TEST 2 POST /signup Invalid] Status:', res2.statusCode);
          console.log('[TEST 2 POST /signup Invalid] Response:', data2);

          server.close(() => {
            console.log('[TEST] Standalone test completed successfully!');
            process.exit(0);
          });
        });
      });
      req.write(postData);
      req.end();
    });
  }).on('error', (err) => {
    console.error('[TEST ERROR]', err);
    server.close(() => process.exit(1));
  });
});
