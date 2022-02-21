var express = require('express')
var app = express()
const port = process.env.PORT || 3000;
const host = '0.0.0.0';

app.get('/', function (req, res) {
  res.send('Hello Worlddddddddddddd!')
})

app.listen(port, host, function () {
  console.log(`Listening on: ${host}:${port}`)
})
