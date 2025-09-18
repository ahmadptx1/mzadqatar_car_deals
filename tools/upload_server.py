#!/usr/bin/env python3
"""Simple file upload server for the repo.

Serves an HTML form at / to upload files and lists files in android/.
Saves uploads to the repository's android/ directory.
"""
from pathlib import Path
from flask import Flask, request, redirect, url_for, send_from_directory, render_template_string, abort
import os

APP = Flask(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]
ANDROID_DIR = REPO_ROOT / "android"
ANDROID_DIR.mkdir(parents=True, exist_ok=True)

UPLOAD_FORM = """
<!doctype html>
<title>Upload File to android/</title>
<h1>Upload File to android/</h1>
<form method=post enctype=multipart/form-data>
  <input type=file name=file>
  <input type=submit value=Upload>
</form>
<h2>Existing files in android/</h2>
<ul>
{% for f in files %}
  <li><a href="/files/{{ f }}">{{ f }}</a></li>
{% else %}
  <li>(no files)</li>
{% endfor %}
</ul>
"""


@APP.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        if 'file' not in request.files:
            return 'No file part', 400
        file = request.files['file']
        if file.filename == '':
            return 'No selected file', 400
        # Basic sanitization: keep basename only
        filename = os.path.basename(file.filename)
        target = ANDROID_DIR / filename
        # Prevent overwriting by adding numeric suffix if exists
        if target.exists():
            stem = target.stem
            suffix = target.suffix
            i = 1
            while True:
                candidate = ANDROID_DIR / f"{stem}_{i}{suffix}"
                if not candidate.exists():
                    target = candidate
                    break
                i += 1
        file.save(str(target))
        return redirect(url_for('upload_file'))

    # GET: list files
    files = [p.name for p in sorted(ANDROID_DIR.iterdir()) if p.is_file()]
    return render_template_string(UPLOAD_FORM, files=files)


@APP.route('/files/<path:filename>')
def uploaded_file(filename):
    # prevent path traversal
    safe_name = os.path.basename(filename)
    path = ANDROID_DIR / safe_name
    if not path.exists() or not path.is_file():
        abort(404)
    return send_from_directory(str(ANDROID_DIR), safe_name, as_attachment=True)


def main():
    # Bind to 0.0.0.0 so it's reachable from host; port 8080 as requested
    APP.run(host='0.0.0.0', port=8080, debug=False)


if __name__ == '__main__':
    main()
