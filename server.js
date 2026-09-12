const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const port = Number(process.env.AXIOM_PORT || 8080);
const host = '0.0.0.0';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'axes2026';
const LEADS_FILE = path.join(__dirname, 'leads.json');

function getLeads() {
    try {
          if (fs.existsSync(LEADS_FILE)) return JSON.parse(fs.readFileSync(LEADS_FILE, 'utf8'));
    } catch(e) {}
    return [];
}

function saveLead(lead) {
    const leads = getLeads();
    lead.id = Date.now();
    lead.timestamp = new Date().toISOString();
    leads.unshift(lead);
    try { fs.writeFileSync(LEADS_FILE, JSON.stringify(leads, null, 2)); } catch(e) {}
    console.log('NEW LEAD [' + lead.damageType + '] ' + lead.name + ' | ' + lead.phone);
    return lead;
}

function serveFile(res, filePath, contentType) {
    fs.readFile(filePath, (err, data) => {
          if (err) { res.writeHead(404); res.end('Not Found'); return; }
          res.writeHead(200, { 'Content-Type': contentType });
          res.end(data);
    });
}

function parseBody(req) {
    return new Promise((resolve) => {
          let body = '';
          req.on('data', chunk => body += chunk);
          req.on('end', () => { try { resolve(JSON.parse(body)); } catch(e) { resolve({}); } });
    });
}

function checkAdmin(req) {
    const b64 = ((req.headers['authorization'] || '').split(' ')[1] || '');
    const parts = Buffer.from(b64, 'base64').toString().split(':');
    return parts[1] === ADMIN_PASSWORD;
}

const server = http.createServer(async (req, res) => {
    const parsed = url.parse(req.url, true);
    const pathname = parsed.pathname;

                                   res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

                                   if (pathname === '/health') {
                                         res.writeHead(200, { 'Content-Type': 'application/json' });
                                         res.end(JSON.stringify({ status: 'ok', service: 'AXIOM', version: '2.0.0' }));
                                         return;
                                   }
    if (pathname === '/' || pathname === '/index.html') {
          serveFile(res, path.join(__dirname, 'axiom_web_interface.html'), 'text/html; charset=utf-8');
          return;
    }
    if (pathname === '/embed' || pathname === '/axes') {
          serveFile(res, path.join(__dirname, 'axes_embed.html'), 'text/html; charset=utf-8');
          return;
    }
    if (pathname === '/widget.js') {
          serveFile(res, path.join(__dirname, 'widget.js'), 'application/javascript; charset=utf-8');
          return;
    }
    if (pathname === '/api/intake' && req.method === 'POST') {
          const body = await parseBody(req);
          const lead = saveLead(body);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: true, id: lead.id, message: 'Team alerted. We respond within 60 minutes.' }));
          return;
    }
    if (pathname === '/admin') {
          if (!checkAdmin(req)) {
                  res.writeHead(401, { 'WWW-Authenticate': 'Basic realm="AXIOM Admin"' });
                  res.end('Unauthorized');
                  return;
          }
          serveFile(res, path.join(__dirname, 'admin.html'), 'text/html; charset=utf-8');
          return;
    }
    if (pathname === '/api/leads' && req.method === 'GET') {
          if (!checkAdmin(req)) { res.writeHead(401); res.end('Unauthorized'); return; }
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(getLeads()));
          return;
    }
    res.writeHead(404); res.end('Not Found');
});

server.listen(port, host, () => {
    console.log('AXIOM v2.0 listening on ' + host + ':' + port);
    console.log('  Embed:  https://xiiom.com/embed');
    console.log('  Widget: https://xiiom.com/widget.js');
    console.log('  Admin:  https://xiiom.com/admin');
});
