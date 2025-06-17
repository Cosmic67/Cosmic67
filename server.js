const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(path.join(__dirname, 'public')));

let gameState = {
  board: Array(8).fill(null).map(() => Array(8).fill(null)),
  turn: 'white'
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

io.on('connection', (socket) => {
  socket.emit('state', gameState);

  socket.on('move', (data) => {
    // simple move handling without validation
    const { from, to } = data;
    const piece = gameState.board[from.row][from.col];
    gameState.board[from.row][from.col] = null;
    gameState.board[to.row][to.col] = piece;
    gameState.turn = gameState.turn === 'white' ? 'black' : 'white';
    io.emit('state', gameState);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Listening on http://localhost:${PORT}`);
});
