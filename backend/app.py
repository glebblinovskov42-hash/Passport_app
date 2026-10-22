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

# Инициализируем EasyOCR ОДИН РАЗ при старте сервера (чтобы не грузить модель на каждый запрос)
# 'ru' - русский, 'en' - английский (для номеров и латиницы)
print("Загрузка моделей EasyOCR...")
reader = easyocr.Reader(['ru', 'en'], quantize=False)
print("EasyOCR готов к работе!")



@app.route('/upload', methods=['POST'])
def upload():
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({
            "status": "error",
            "message": "Invalid JSON request"
        }), 400

    text = data.get('text', '')
    target_email = data.get('email', '')
    password = data.get('password', '')

    if not isinstance(target_email, str) or not target_email.strip():
        return jsonify({
            "status": "error",
            "message": "Email required"
        }), 400

    if not isinstance(password, str) or not password.strip():
        return jsonify({
            "status": "error",
            "message": "Archive password required"
        }), 400

    if not isinstance(text, str) or not text.strip():
        return jsonify({
            "status": "error",
            "message": "Passport text required"
        }), 400

    target_email = target_email.strip()

    try:
        # 1. Сохраняем распознанный текст во временный файл
        with open('passport.txt', 'w', encoding='utf-8') as f:
            f.write(text)

        # 2. Создаём архив с паролем, введённым в приложении
        with py7zr.SevenZipFile(
            'passport.7z',
            'w',
            password=password
        ) as archive:
            archive.write('passport.txt', 'passport.txt')

        # 3. Отправляем архив на указанный email
        send_archive(target_email, 'passport.7z', SMTP_CONFIG)

        return jsonify({
            "status": "ok",
            "message": f"Sent to {target_email}"
        })

    except Exception:
        app.logger.exception("Ошибка создания или отправки архива")
        return jsonify({
            "status": "error",
            "message": "Не удалось создать или отправить архив"
        }), 500

    finally:
        # Удаляем временные файлы и при успехе, и при ошибке
        for filename in ('passport.txt', 'passport.7z'):
            if os.path.exists(filename):
                try:
                    os.remove(filename)
                except OSError:
                    app.logger.exception(
                        "Не удалось удалить временный файл: %s",
                        filename
                    )

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