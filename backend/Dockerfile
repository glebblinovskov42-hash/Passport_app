FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 EASYOCR_MODULE_PATH=/root/.EasyOCR

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 libglib2.0-0 libgl1 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir torch==2.14.1+cpu torchvision==0.29.1+cpu --index-url https://download.pytorch.org/whl/cpu && pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY services/ ./services/

EXPOSE 5000

CMD ["python", "app.py"]