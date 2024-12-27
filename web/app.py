import os
import subprocess
from flask import Flask, request, send_file, render_template

app = Flask(__name__, static_url_path='/static', template_folder='templates')

UPLOAD_FOLDER = '../uploads'
RESULT_FOLDER = '../results'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file part"
    
    file = request.files['file']
    
    if file.filename == '':
        return "No selected file"
    
    # Get the file extension
    file_extension = os.path.splitext(file.filename)[1]
    
    # Rename the file to server_build and retain the extension
    renamed_file_path = os.path.join('/app', f'server_build{file_extension}')
    file.save(renamed_file_path)

    # Run the build script
    build_script = '/app/build_wl_tar.sh'  # Ensure this path is correct
    try:
        subprocess.run(['bash', build_script], check=True)
    except subprocess.CalledProcessError as e:
        return f"Error running the build script: {e}"

    # Assume your final tar file is named wl_bin.tar.gz in the results folder
    result_file = os.path.join(RESULT_FOLDER, 'wl_bin.tar.gz')
    
    return send_file(result_file, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
