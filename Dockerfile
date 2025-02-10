FROM python:3.9-slim

WORKDIR /app

# Crea un usuario no root "app" con UID 10001
RUN groupadd -g 3000 app && useradd -m -u 10001 -g 3000 app

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY ./app ./app

RUN chown -R app:app /app

USER app

EXPOSE 8080

CMD ["python", "app/main.py"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; exit(0) if urllib.request.urlopen('http://localhost:8080/ping').getcode() == 200 else exit(1)"

