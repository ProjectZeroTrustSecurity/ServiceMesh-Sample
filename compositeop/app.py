import os
import requests

import json

from flask import Flask
from flask import request

from flask import Response
from flask import jsonify

app = Flask(__name__)

from flask_cors import CORS
from flask_cors import cross_origin

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

basicopserviceoptions = { 
  '+': os.getenv('ADDURI', 'http://add:8080/basicop/add'),
  '-': os.getenv('SUBURI', 'http://subtract:8080/basicop/subtract'),
  '*': os.getenv('MULURI', 'http://multiply:8080/basicop/multiply'),
  '/': os.getenv('DIVURI', 'http://divide:8080/basicop/divide')  
}

def forwardTraceHeaders(request):
  headers = {}
  incomingheaders = [
    'x-request-id',
    'x-b3-traceid',
    'x-b3-spanid',
    'x-b3-parentspanid',
    'x-b3-sampled',
    'x-b3-flags',
    'x-ot-span-context',
    'x-dev-user'
  ]
 
  for h in incomingheaders:
    val = request.headers.get(h)

    if val is not None:
      headers[h] = val
  
  return headers

def executeop(op, params, headers, timeout):
  try:
    url = basicopserviceoptions[op]
    response = requests.get(url, headers = headers, params = params, timeout = timeout)
  except:
    response = None
  
  status = response.status_code
  if response and status == 200:
    return status, response.text
  else:
    return status, 'NA'

@app.route('/compositeop/square', methods=['GET'])
@cross_origin()
def square():
  n1 = request.args.get('n1')

  headers = forwardTraceHeaders(request)
  params = { 'n1': n1, 'n2': n1 }
  
  status, result = executeop('*', params, headers, 20.0)
  return Response(str(result), mimetype="text/plain")

@app.route('/compositeop/cube', methods=['GET'])
@cross_origin()
def cube():
  n1 = request.args.get('n1')

  headers = forwardTraceHeaders(request)
  params = { 'n1': n1, 'n2': n1 }
  status, result = executeop('*', params, headers, 20.0)

  params = { 'n1': result, 'n2': n1 }
  status, result = executeop('*', params, headers, 20.0)

  return Response(str(result), mimetype="text/plain")

@app.route('/compositeop/mean', methods=['GET'])
@cross_origin()
def mean():
  headers = forwardTraceHeaders(request)
  count = len(request.args)

  result = 0
  for arg in request.args:
    param = request.args.get(arg)

    params = { 'n1': result, 'n2': param }
    status, result = executeop('+', params, headers, 20.0)
  
  params = { 'n1': result, 'n2': count }
  status, result = executeop('/', params, headers, 20.0)

  return Response(str(result), mimetype="text/plain")  

def expr2rpn(expr, delimiter):
  OPERATORS = set(['+', '-', '*', '/', '(', ')'])
  PRIORITY = {'+':1, '-':1, '*':2, '/':2}
  
  stack = [] # only pop when the coming op has priority 
  output = ''

  pos = 0
  for ch in expr:
    if ch not in OPERATORS:
      output += ch
      if pos < len(expr) - 1 and expr[pos + 1] in OPERATORS: output += delimiter
    elif ch == '(':
      stack.append('(')
      output += delimiter
    elif ch == ')':
      while stack and stack[-1] != '(':
        output += stack.pop()
        output += delimiter

      stack.pop() # pop '('
    else:
      while stack and stack[-1] != '(' and PRIORITY[ch] <= PRIORITY[stack[-1]]:
        output += stack.pop()
        output += delimiter
      
      stack.append(ch)

    pos += 1
  
  # leftover
  while stack: 
    output += delimiter
    output += stack.pop()

  return " ".join(output.split()).strip()

def processrpnexpr(rpnexpr, headers):
  stack = []
  steps = []

  if rpnexpr:
    for val in rpnexpr.split(' '):
      if val in ['+', '-', '*', '/']:
        op1 = stack.pop()
        op2 = stack.pop()
        
        op = val
        params = { 'n1': op2, 'n2': op1 }

        if op == '/' and int(op1) == 0: return [ "NaN", steps ]
        
        istatus, iresult = executeop(op, params, headers, 20.0)
        stack.append(iresult)

        stepn = {}
        stepn['stepop'] = op
        stepn['stepop1'] = op1
        stepn['stepop2'] = op2
        stepn['stepresult'] = iresult
        stepn['stepstatus'] = istatus
        steps.append(stepn)
        
        if (istatus != 200): break
      else:
        stack.append(val)

    result = stack.pop()
    return [ result, steps ]
  else:
    return [ None, None ]

def formatresult(identifier, expr, rpnexpr, steps, result):
  jsonresult = {}

  jsonresult['version'] = os.getenv('VERSION')
  jsonresult['identifier'] = identifier

  jsonresult['expr'] = expr
  jsonresult['rpnexpr'] = rpnexpr

  jsonresult['result'] = result
  jsonresult['steps'] = steps

  return jsonresult

@app.route('/compositeop/eval', methods=['GET'])
@cross_origin()
def eval():
  headers = forwardTraceHeaders(request)

  identifier = request.args.get('identifier')
  expr = request.args.get('expr')
  
  rpnexpr = expr2rpn(expr, ' ') 
  
  result, steps = processrpnexpr(rpnexpr, headers)
  jsonresult = formatresult(identifier, expr, rpnexpr, steps, result)

  return jsonify(jsonresult)

@app.route('/compositeop/evalrpnexpr', methods=['GET'])
@cross_origin()
def evalrpnexpr():
  headers = forwardTraceHeaders(request)

  identifier = request.args.get('identifier')
  rpnexpr = request.args.get('expr')
  
  result, steps = processrpnexpr(rpnexpr, headers)   
  jsonresult = formatresult(identifier, rpnexpr, rpnexpr, steps, result)
  
  return jsonify(jsonresult)

port = os.getenv('PORT', '8080')
if __name__ == "__main__":
  app.run(host='0.0.0.0', port=int(port))
