import os
from flask import Flask, make_response, jsonify

app = Flask(__name__)


@app.route('/')
def index():
    return make_response(jsonify({
        "message": "Hello!"
    }))


if __name__ == '__main__':
    debug = os.environ.get('FLASK_DEBUG', False)
    app.run(host='0.0.0.0', debug=debug)
