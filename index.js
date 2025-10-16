// index.js
const express = require('express');
const app = express();

// Cloud Run automatically provides a PORT environment variable.
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('🚀 Hello from Google Cloud Run!');
});

app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
