const http = require('http');
const fs = require('fs');
const path = require('path');

const port = Number(process.env.AXIOM_PORT || 8080);
const host = '0.0.0.0';
const indexPath = path.join(__dirname, 'axiom_web_interface.html');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  if (req.url === '/' || req.url === '/index.html') {
    fs.readFile(indexPath, (err, data) => {
      if (err) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Unable to load AXIOM interface');
        return;
      }
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(data);
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not Found');
});

server.listen(port, host, () => {
  console.log(`AXIOM web service listening on ${host}:${port}`);
});
