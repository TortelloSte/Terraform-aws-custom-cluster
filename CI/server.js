const http = require('http');
const fs = require('fs');
const path = require('path');

let notes = []; // Array per conservare note temporaneamente

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    fs.createReadStream(path.join(__dirname, 'index.html')).pipe(res);
  } else if (req.method === 'GET' && req.url === '/api/notes') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(notes));
  } else if (req.method === 'POST' && req.url === '/api/notes') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      const { text } = JSON.parse(body);
      const note = { id: notes.length + 1, text };
      notes.push(note);
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(note));
    });
  } else if (req.method === 'DELETE' && req.url.startsWith('/api/notes/')) {
    const id = parseInt(req.url.split('/').pop());
    notes = notes.filter(note => note.id !== id);
    res.writeHead(204);
    res.end();
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});