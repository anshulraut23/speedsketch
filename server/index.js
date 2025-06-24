// server/index.js
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

let drawer = null;

io.on('connection', (socket) => {
  console.log('✅ Connected:', socket.id);

  socket.on('register_drawer', () => {
    drawer = socket.id;
    io.to(drawer).emit('role_confirmed', 'drawer');
  });

  socket.on('register_guesser', () => {
    socket.emit('role_confirmed', 'guesser');
  });

  socket.on('draw', (data) => {
    socket.broadcast.emit('draw', data);
  });

  socket.on('guess', (guess) => {
    if (drawer) {
      io.to(drawer).emit('receive_guess', { from: socket.id, guess });
    }
  });

  socket.on('guess_response', ({ to, result }) => {
    io.to(to).emit('guess_result', result);
    if (result === 'yes') {
      io.emit('clear'); // start new round logic here if needed
    }
  });

  socket.on('disconnect', () => {
    if (socket.id === drawer) drawer = null;
    console.log('❌ Disconnected:', socket.id);
  });
});

server.listen(5000, () => {
  console.log('🚀 Server running on http://localhost:5000');
});
