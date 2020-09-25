'use strict';

const express = require('express');
const path = __dirname + '/pages/';

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.sendFile(path + 'index.html');
});

app.use(express.static(path));

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

