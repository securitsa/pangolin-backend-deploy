FROM python:3.13.3-slim

WORKDIR /src

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/src

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gcc \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src .

EXPOSE 8000

CMD ["bash", "-c", "alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2"]
