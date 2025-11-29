import os
from flask import Flask, jsonify

app = Flask(__name__)
@app.route('/health', methods=['GET'])
def health_check():
    return jsonify(status='OK'), 200

@app.route('/info', methods=['GET'])
def info():
    env_value = os.getenv("APP_ENV", "unknown")
    return jsonify({
        "service": "Hello Service",
        "environment": env_value
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)