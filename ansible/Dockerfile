
FROM python:3.9-slim


WORKDIR /app


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


COPY app/app.py .
COPY app/templates/ /app/templates/


EXPOSE 5000


CMD ["python", "app.py"]


