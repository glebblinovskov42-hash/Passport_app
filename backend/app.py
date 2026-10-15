from flask import Flask, request, jsonify
import py7zr
import os
from dotenv import load_dotenv
from services.email_service import send_archive

load_dotenv()

app = Flask(__name__)

SMTP_CONFIG = {
    'host': os.getenv('SMTP_HOST'),
    'port': int(os.getenv('SMTP_PORT', 587)),
    'from': os.getenv('SMTP_FROM'),
    'password': os.getenv('SMTP_PASSWORD')
}

TARGET_EMAIL = os.getenv('TARGET_EMAIL')
ARCHIVE_PASSWORD = os.getenv('ARCHIVE_PASSWORD', 'secret123')


@app.route('/upload', methods=['POST'])
def upload():
    data = request.json
    text = data.get('text', '')
    target_email = data.get('email', TARGET_EMAIL)
    password = data.get('password', ARCHIVE_PASSWORD)

    if not target_email:
        return jsonify({"status": "error", "message": "Email required"}), 400

    # 1. Сохранить текст во временный файл
    with open('passport.txt', 'w') as f:
        f.write(text)

    # 2. Создать 7z с паролем
    with py7zr.SevenZipFile('passport.7z', 'w', password=password) as archive:
        archive.write('passport.txt', 'passport.txt')

    # 3. Удалить временный .txt (архив остаётся)
    os.remove('passport.txt')

    # 4. Отправить архив на email
    try:
        send_archive(target_email, 'passport.7z', SMTP_CONFIG)
    except Exception as e:
        print(f"!!! ОШИБКА ОТПРАВКИ EMAIL: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

    return jsonify({"status": "ok", "message": f"Sent to {target_email}"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
