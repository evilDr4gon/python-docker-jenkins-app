FROM python:3.9-slim

# Define el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos necesarios
COPY requirements.txt requirements.txt

# Instala las dependencias
RUN pip install -r requirements.txt

# Copia el código fuente a /app
COPY ./app ./app

# Cambia el comando de inicio para ejecutar desde el nuevo directorio
CMD ["python", "app/main.py"]

