# 🛠️ Etapa 1: Construcción (evita instalar paquetes innecesarios en la imagen final)
FROM python:3.9-slim AS builder

WORKDIR /app

# Crea un usuario no root "app" con UID 10001
RUN groupadd -g 3000 app && useradd -m -u 10001 -g 3000 app

# Copia solo los archivos necesarios para instalar dependencias
COPY requirements.txt .

# Instala dependencias en una carpeta separada para que no se copien archivos innecesarios
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 🏗️ Etapa 2: Imagen final
FROM python:3.9-slim

WORKDIR /app

# Copia las dependencias instaladas en la etapa anterior
COPY --from=builder /install /usr/local

# Copia la aplicación
COPY ./app ./app

# Cambia los permisos al usuario no root
RUN chown -R app:app /app

# Cambia al usuario seguro
USER app

EXPOSE 8080

# Usa Gunicorn para producción
CMD ["gunicorn", "--workers=2", "--bind=0.0.0.0:8080", "app.main:app"]

# 🔥 Configuración de Healthcheck para Kubernetes
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; exit(0) if urllib.request.urlopen('http://localhost:8080/ping').getcode() == 200 else exit(1)"

