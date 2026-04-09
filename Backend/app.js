const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const dbconnect = require('./db');
const userRoutes = require('./Routes/Routes'); 
const pickListRoutes = require("./Routes/pickListRoutes");

const port = process.env.PORT || 3000;

const app = express();
// Wrap Express in an HTTP server for WebSocket compatibility
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST", "PATCH", "DELETE"]
  }
});

app.use(cors());
app.use(express.json());

// Attach socket.io to the request object so controllers can use it
app.use((req, res, next) => {
  req.io = io;
  next();
});

dbconnect();

// Use routes
app.use('/api', userRoutes);
app.use("/api/picklist", pickListRoutes);

// WebSocket connection for Admin/Manager
io.on("connection", (socket) => {
  console.log("Client connected for live notifications: ", socket.id);
  socket.on("disconnect", () => {
    console.log("Client disconnected: ", socket.id);
  });
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});