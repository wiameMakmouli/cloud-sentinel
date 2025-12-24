
FROM python:3.9-slim


WORKDIR /app
# 1. Installation des outils système
RUN apt-get update && \
    apt-get install -y git curl unzip && \
    pip install --no-cache-dir pipx && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# 2. Installation des Scanners (Checkov & Prowler)
RUN pipx install checkov
RUN pipx install prowler

# 3. Installation des dépendances Python (boto3, fastapi...)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copie du code
COPY main.py .

# 5. Lancement
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
