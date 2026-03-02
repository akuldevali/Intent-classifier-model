# Use a slim official Python image
FROM python:3.10-slim

# Prevent Python from writing .pyc files and enable stdout/stderr flushing
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system deps (if needed) and Python deps and later remove build tools to keep image small
COPY requirements.txt .
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libc-dev \
 && pip install --no-cache-dir -r requirements.txt \
 && apt-get remove -y gcc libc-dev \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

# Copy app code and model file(s)
COPY . .

# Train the Model and save the trained model to the artifacts directory
RUN python3 model/train.py

# Expose the port your app runs on 
EXPOSE 8080

# Start the app with gunicorn (4 workers, bind to 0.0.0.0:6000) and specify the app module and variable (app:app)
CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:8080", "app:app"]
