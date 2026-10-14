from flask import Flask, request, jsonify
import py7zr
import os

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload():
    data = request.json
    text = data.get('text', '')

    # 1. Сохранить текст в файл
    with open('passport.txt', 'w') as f:
        f.write(text)

    # 2. Создать 7z с паролем
    with py7zr.SevenZipFile('passport.7z', 'w', password='secret123') as archive:
        archive.write('passport.txt', 'passport.txt')

    # 3. Удалить временный файл
    os.remove('passport.txt')

    return jsonify({"status": "ok", "archive": "passport.7z"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
