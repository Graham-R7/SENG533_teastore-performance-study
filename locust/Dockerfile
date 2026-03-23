FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt

EXPOSE 8089

CMD ["locust", "-f", "/app/locustfile.py", "--host", "http://host.docker.internal:8080", "--web-port", "8089"]
