FROM python:3.9-slim

# Define el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos necesarios
COPY requirements.txt requirements.txt

# Instala las dependencias
RUN pip install -r requirements.txt

# Copia el código fuente a /app
COPY ./app ./app

EXPOSE 8080
CMD ["python", "app/main.py"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; exit(0) if urllib.request.urlopen('http://localhost:8080/ping').getcode() == 200 else exit(1)"
