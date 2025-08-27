import subprocess
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/convert', methods=['POST'])
def convert_code():
    data = request.json
    pseudo_code = data['code']

    # Run the compiler, sending the code as stdin input
    result = subprocess.run(
        ['wsl', './pseudo_compiler'],
        input=pseudo_code,   # Send as stdin
        capture_output=True, 
        text=True,
        cwd=r'C:\Users\Sumit\Desktop\compiler\backend'
    )

    if result.returncode != 0:
        return jsonify({'error': True, 'message': result.stderr}), 400
    return jsonify({'error': False, 'cCode': result.stdout})

if __name__ == '__main__':
    app.run(debug=True)
