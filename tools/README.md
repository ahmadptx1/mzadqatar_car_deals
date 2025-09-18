Upload server
==============

This small Flask server exposes an HTML upload form on port 8080 and saves uploaded files into the repository's `android/` directory.

Quick start
-----------

1. Create a virtual environment and install dependencies:

   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r tools/requirements.txt

2. Run the server:

   python3 tools/upload_server.py

3. Open http://localhost:8080 in your browser and upload files. Uploaded files are saved to the `android/` folder at the repository root.

Security notes
--------------

- This server is intentionally minimal and has no authentication. Only run it in a trusted network or for local development.
- Filenames are sanitized to their basename; path traversal is prevented. Existing files receive a numeric suffix to avoid accidental overwrites.

Try it (copy/paste)
------------------

```
# from the repository root
python3 -m venv .venv
source .venv/bin/activate
pip install -r tools/requirements.txt
python3 tools/upload_server.py
```

