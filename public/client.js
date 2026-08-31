const evtSource = new EventSource('/events');
let state = null;
let selected = null;

evtSource.onmessage = (e) => {
    state = JSON.parse(e.data);
    renderBoard();
};

function renderBoard() {
    const boardDiv = document.getElementById('board');
    boardDiv.innerHTML = '';
    for (let r = 0; r < 8; r++) {
        for (let c = 0; c < 8; c++) {
            const square = document.createElement('div');
            square.classList.add('square');
            const isWhite = (r + c) % 2 === 0;
            square.classList.add(isWhite ? 'white-square' : 'black-square');
            square.dataset.row = r;
            square.dataset.col = c;
            const piece = state.board[r][c];
            if (piece) {
                square.textContent = pieceToChar(piece);
            }
            if (selected && selected.row == r && selected.col == c) {
                square.classList.add('selected');
            }
            square.addEventListener('click', onSquareClick);
            boardDiv.appendChild(square);
        }
    }
}

function pieceToChar(piece) {
    const map = {
        'white-king': '♔',
        'white-queen': '♕',
        'white-rook': '♖',
        'white-bishop': '♗',
        'white-knight': '♘',
        'white-pawn': '♙',
        'black-king': '♚',
        'black-queen': '♛',
        'black-rook': '♜',
        'black-bishop': '♝',
        'black-knight': '♞',
        'black-pawn': '♟'
    };
    return map[piece] || '?';
}

function onSquareClick(e) {
    const row = parseInt(e.currentTarget.dataset.row);
    const col = parseInt(e.currentTarget.dataset.col);
    if (selected) {
        fetch('/move', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ from: selected, to: { row, col } })
        });
        selected = null;
    } else {
        selected = { row, col };
    }
    renderBoard();
}
