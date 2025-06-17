# Online Chess Game

This is a simple example of an online chess game implemented with plain Node.js. It uses Server-Sent Events to synchronise moves between browsers and does not enforce chess rules.

## Setup

1. Start the server:
   ```bash
   npm start
   ```
2. Open `http://localhost:3000` in two different browser windows to play.

## Features

- Basic chess board rendered in the browser.
- Real-time move synchronization across clients.
- No full move validation; pieces can be moved anywhere.

This project is meant as a lightweight starting point for building a more complete chess game.
