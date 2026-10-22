from flask import Flask, request, jsonify
import py7zr
import os
from dotenv import load_dotenv
from services.email_service import send_archive

# Импорт для нейросетевого OCR
import easyocr

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

# Инициализируем EasyOCR ОДИН РАЗ при старте сервера (чтобы не грузить модель на каждый запрос)
# 'ru' - русский, 'en' - английский (для номеров и латиницы)
print("Загрузка моделей EasyOCR...")
reader = easyocr.Reader(['ru', 'en'], quantize=False)
print("EasyOCR готов к работе!")



@app.route('/upload', methods=['POST'])
def upload():
    data = request.json
    text = data.get('text', '')
    target_email = data.get('email', TARGET_EMAIL)
    password = data.get('password', ARCHIVE_PASSWORD)

    if not target_email:
        return jsonify({"status": "error", "message": "Email required"}), 400

    # 1. Сохранить текст во временный файл (обязательно указываем utf-8)
    with open('passport.txt', 'w', encoding='utf-8') as f:
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


@app.route('/ocr', methods=['POST'])
def ocr_passport():
    if 'file' not in request.files:
        return jsonify({"error": "Нет файла"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "Пустое имя файла"}), 400

    try:
        image_bytes = file.read()

        # EasyOCR сам делает всю предобработку картинки
        # detail=0 возвращает только текст, без координат
        # paragraph=True объединяет строки в логические абзацы
        result = reader.readtext(image_bytes, detail=0, paragraph=True)

        # Склеиваем распознанные строки
        text = "\n".join(result)

        return jsonify({"text": text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)