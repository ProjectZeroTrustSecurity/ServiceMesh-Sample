import os
from flask import Flask

from flask import request
from flask import Response

app = Flask(__name__)

from flask_cors import CORS
from flask_cors import cross_origin

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route('/basicop/subtract', methods=['GET'])
@cross_origin()
def subtract():
  n1 = int(request.args.get('n1'))
  if (n1 is None): n1 = 0

  n2 = int(request.args['n2'])
  if (n2 is None): n2 = 0
  
  result = n1 - n2
  return Response(str(result), mimetype="text/plain")

port = os.getenv('PORT', '8080')
if __name__ == "__main__":
  app.run(host='0.0.0.0', port=int(port))
