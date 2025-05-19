from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import os
import tempfile

app = Flask(__name__)
CORS(app)

@app.route('/compile', methods=['POST'])
def compile_code():
    try:
        code = request.json.get('code', '')
        input_data = request.json.get('input', '')  # Get input data from request
        
        # Create a temporary file for the input code
        with tempfile.NamedTemporaryFile(mode='w', suffix='.c', delete=False) as temp_file:
            temp_file.write(code)
            temp_file.flush()
            
            # Compile the code using gcc
            compile_result = subprocess.run(['gcc', temp_file.name, '-o', temp_file.name + '.out'],
                                         capture_output=True,
                                         text=True)
            
            if compile_result.returncode != 0:
                return jsonify({
                    'success': False,
                    'output': '',
                    'errors': [compile_result.stderr]
                })
            
            # Run the compiled program with input
            run_result = subprocess.run([temp_file.name + '.out'],
                                     input=input_data,  # Provide input to the program
                                     capture_output=True,
                                     text=True)
            
            # Clean up the temporary files
            os.unlink(temp_file.name)
            os.unlink(temp_file.name + '.out')
            
            return jsonify({
                'success': True,
                'output': run_result.stdout,
                'errors': []
            })
                
    except Exception as e:
        return jsonify({
            'success': False,
            'output': '',
            'errors': [str(e)]
        })

if __name__ == '__main__':
    app.run(debug=True, port=5000) 