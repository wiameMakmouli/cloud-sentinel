FROM python:3.9

WORKDIR /app

# Mise à jour de pip
RUN pip install --upgrade pip

# Installation de Checkov et Prowler (Prendre un café, ça peut être long)
RUN pip install --no-cache-dir checkov prowler

# Installation des dépendances App
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code
COPY main.py .

# Lancement
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
