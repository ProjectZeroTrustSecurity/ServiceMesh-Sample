var express = require('express');
var bodyParser = require('body-parser');

var app = express();
var cors = require('cors');

var request = require('request');
var _ = require('underscore');

var async = require('async');
var crypto = require('crypto');

var jsep = require('jsep');
var redis = require('redis');

var Chance = require('chance');
var chance = new Chance();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json())

/*var subscriber = redis.createClient(process.env.REDISURI || 'redis://redis:6379/0');
var publisher  = redis.createClient(process.env.REDISURI || 'redis://redis:6379/0');*/

var opserviceoptions = {
  host: process.env.OPSERVICEHOST || 'http://compositeop',
  port: process.env.OPSERVICEPORT || 8080,
  path: '/compositeop/eval',
  headers: {
    'Content-Type': 'application/json'
  }
};

var getsessionid = function() {
  var sha = crypto.createHash('sha256');
  sha.update(Math.random().toString());
  
  return sha.digest('hex');
}

function isNumber(n){
  return typeof n == 'number' && !isNaN(n - n);
}

var evaluateexpression = function(input, opcallback) {
  identifier = input[0];
  expr = input[1];

  var reqoptions = {
    url: opserviceoptions.host + ':' + opserviceoptions.port + opserviceoptions.path,
    method: 'GET',
    qs: { identifier: identifier, expr: expr },
    headers: opserviceoptions.headers 
  };
  
  request(reqoptions, function (opserviceerror, opserviceresponse, opservicebody) {
    if (!opserviceerror && opserviceresponse.statusCode == 200) {
      result = JSON.parse(opservicebody);
      return opcallback(null, result);    
    }
  });
}

function traverse (parseTree, exprdeps) {
  for (var branch in parseTree) {
    var object = parseTree[branch];
    if (object !== null && typeof(object) == "object") {
      if (object.type == "Identifier") {
        exprdeps.push(object.name);
      }

      traverse(parseTree[branch], exprdeps);
    }
  }
}

var preprocessexpressions = function(expressions, preprocesscallback) {
  var input = [];
  var pairs = _.pairs(expressions);

  var finalIdentifiers = [];
  _.map(pairs, function(pair) {
    identifier = pair[0];
    if (identifier.length <= 0) {
      pair[0] = chance.string({ length: 3, pool: 'abcdefghijklmnopqrstuvwxyz' });
    }
    else if (isNumber(Number(identifier))) {
      pair[0] = chance.string({ length: 1, pool: 'abcdefghijklmnopqrstuvwxyz' }) + identifier;
    }

    finalIdentifiers.push(pair[0]);
  });

  var pe = 0;
  _.map(pairs, function(pair) {
    expression = pair[1];
    var parseTree = jsep(expression);
    
    var exprdeps = [];
    traverse(parseTree, exprdeps);

    _.map(exprdeps, function(dep) {
      if (!_.contains(finalIdentifiers, dep)) {
        exprdeps.pop(dep);
      }
    });

    pair.push(exprdeps);
    input.push(pair);

    pe = pe + 1;
    if (pe == pairs.length) return preprocesscallback(input);
  });
}

app.options('/processor/calculate', cors())
app.post('/processor/calculate', cors(), function(request, response)
{
  verbosity = request.query['verbosity'];
  if (verbosity == null || verbosity == '') verbosity = 0;

  var id = getsessionid();
  preprocessexpressions(request.body, function(input) {
    async.map(input, evaluateexpression, function(opresultserror, opresults) {
      calcresponses = [];
      _.map(opresults, function(opresult) {
        calcopresponse = {};
  
        calcopresponse.identifier = opresult.identifier;
        calcopresponse.expr = opresult.expr;
        calcopresponse.result = opresult.result;
  
        if (verbosity >= 1) {
          calcopresponse.version = opresult.version;
        }
        
        if (verbosity >= 2) {
          calcopresponse.rpnexpr = opresult.rpnexpr;
        }    
        
        if (verbosity >= 3) {
          calcopresponse.steps = opresult.steps;
        }
  
        /*publisher.rpush(id, JSON.stringify(calcopresponse), function(oppublisherror, oppublishreply) {
        });*/
  
        calcresponses.push(calcopresponse);
      });
      
      calcresponse = {};
      calcresponse.results = calcresponses;
  
      response.json(calcresponse);
    });
  });
});

// start server on the specified port and binding host
app.listen(8080, function() {
	// print a message when the server starts listening
	console.log("Server listening ...");
});
