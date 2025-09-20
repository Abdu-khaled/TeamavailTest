const express = require('express');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const redis = require('redis'); // 🔹 Added Redis import

const app = express();
const PORT = 3000;

// Use env vars with fallbacks
const REDIS_HOST = process.env.REDIS_HOST || 'availability-redis';
const REDIS_PORT = process.env.REDIS_PORT || 6379;

const client = redis.createClient({
  url: `redis://${REDIS_HOST}:${REDIS_PORT}`
});

// Middleware
app.use(bodyParser.json());

// Serve static frontend
app.use(express.static(path.join(__dirname, 'public')));

// Serve input JSON files
app.use('/input', express.static(path.join(__dirname, 'input')));

// Serve output folder (for history.json)
app.use('/output', express.static(path.join(__dirname, 'output')));

// API to save history data
app.post('/save-history', async (req, res) => {
  const historyPath = path.join(__dirname, 'output', 'history.json');
  const json = JSON.stringify(req.body, null, 2);

  // Save to file (unchanged)
  fs.writeFile(historyPath, json, 'utf8', async (err) => {
    if (err) {
      console.error('Error saving history.json:', err);
      return res.status(500).send('Failed to save history.json');
    }

    console.log('History successfully saved to file.');

    // 🔹 Save to Redis
    try {
      await client.set('history', json); // Redis key "history"
      console.log('History successfully saved to Redis.');
      res.status(200).send('Saved to file and Redis');
    } catch (redisErr) {
      console.error('Redis error:', redisErr);
      res.status(500).send('Failed to save history in Redis');
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
