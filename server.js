const http = require('http');
const fs = require('fs');
const path = require('path');

const clients = [];

function sendState(res) {
  res.write(`data: ${JSON.stringify(gameState)}\n\n`);
}

function broadcastState() {
  clients.forEach((res) => sendState(res));
}

function serveFile(res, filePath, contentType) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
}

let gameState = {
  board: Array(8)
    .fill(null)
    .map(() => Array(8).fill(null)),
  turn: 'white',
};

function initializeBoard() {
  const pieces = ['rook', 'knight', 'bishop', 'queen', 'king', 'bishop', 'knight', 'rook'];
  for (let i = 0; i < 8; i++) {
    gameState.board[0][i] = 'black-' + pieces[i];
    gameState.board[1][i] = 'black-pawn';
    gameState.board[6][i] = 'white-pawn';
    gameState.board[7][i] = 'white-' + pieces[i];
  }
}

initializeBoard();

const server = http.createServer((req, res) => {
  const parsed = new URL(req.url, `http://${req.headers.host}`);
  if (req.method === 'GET' && parsed.pathname === '/') {
    serveFile(res, path.join(__dirname, 'public', 'index.html'), 'text/html');
  } else if (req.method === 'GET' && parsed.pathname === '/client.js') {
    serveFile(res, path.join(__dirname, 'public', 'client.js'), 'text/javascript');
  } else if (req.method === 'GET' && parsed.pathname === '/style.css') {
    serveFile(res, path.join(__dirname, 'public', 'style.css'), 'text/css');
  } else if (req.method === 'GET' && parsed.pathname === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
    });
    clients.push(res);
    sendState(res);
    req.on('close', () => {
      const index = clients.indexOf(res);
      if (index !== -1) clients.splice(index, 1);
    });
  } else if (req.method === 'POST' && parsed.pathname === '/move') {
    let body = '';
    req.on('data', (chunk) => (body += chunk));
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const { from, to } = data;
        const piece = gameState.board[from.row][from.col];
        gameState.board[from.row][from.col] = null;
        gameState.board[to.row][to.col] = piece;
        gameState.turn = gameState.turn === 'white' ? 'black' : 'white';
        broadcastState();
      } catch (_) {
        // ignore parse errors
      }
      res.writeHead(204);
      res.end();
    });
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Listening on http://localhost:${PORT}`);
});
