# 1. Immagine di base
FROM python:3.9-slim

# 2. Directory di lavoro dentro il container
WORKDIR /app

# 3. Copia i file necessari nel container
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copia dei file dell'applicazione
COPY app/app.py .
COPY app/templates/ /app/templates/

# 5. Esponi la porta su cui Flask gira (default: 5000)
EXPOSE 5000

# 6. Comando di avvio
CMD ["python", "app.py"]


