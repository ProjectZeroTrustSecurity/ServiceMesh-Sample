var express = require('express');

var app = express();
var cors = require('cors');

function isNumber(n){
  return typeof n == 'number' && !isNaN(n - n);
}

app.options('/basicop/add', cors())
app.get('/basicop/add', cors(), function(request, response)
{
  n1 = Number(request.query['n1']);
  if (!isNumber(n1)) n1 = 0;

  n2 = Number(request.query['n2']);
  if (!isNumber(n2)) n2 = 0;

  result = n1 + n2;

  response.write(result.toString());
  response.end();
});

// start server on the specified port and binding host
app.listen(8080, function() {
	// print a message when the server starts listening
	console.log("Server listening ...");
});
