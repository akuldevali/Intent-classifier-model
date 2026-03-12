# Intent Classifier Model

This project is a lightweight MLOps-style workflow for intent classification.
It shows the complete path from training a simple scikit-learn model to serving
predictions locally with Flask and deploying the model on Kubernetes using
KServe.

## What I Built

- A small training pipeline using `CountVectorizer`, `MultinomialNB`, and scikit-learn `Pipeline`
- A saved model artifact at `model/artifacts/intent_model.pkl`
- A Flask API with `GET /health` and `POST /predict`
- A WSGI entrypoint (`wsgi.py`) for production-style serving with Gunicorn
- A KServe deployment guide in `KServe-implementation.md`

## Project Structure

```text
app.py
wsgi.py
requirements.txt
KServe-implementation.md
model/train.py
model/intent_model.py
model/artifacts/intent_model.pkl  (generated after training)
```

## How It Works

1. `model/train.py` trains on a tiny sample dataset of intent phrases.
2. The trained pipeline is serialized with Joblib.
3. `app.py` loads the artifact using `IntentModel` from `model/intent_model.py`.
4. `/predict` accepts JSON input and returns the predicted intent.

## Requirements

- Python 3.9+
- `pip`

Install dependencies from:

```txt
requirements.txt
```

## Run Locally

### 1. Create and activate a virtual environment

Windows (PowerShell):

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

Linux/macOS:

```bash
python3 -m venv venv
source venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Train the model

```bash
python model/train.py
```

Expected output:

```text
trained
```

This creates:

```text
model/artifacts/intent_model.pkl
```

### 4. Start the API server

```bash
python app.py
```

Server starts on:

```text
http://127.0.0.1:8080
```

## API Usage

### Health Check

```bash
curl http://127.0.0.1:8080/health
```

Response:

```json
{"status":"ok"}
```

### Predict Intent

```bash
curl -X POST http://127.0.0.1:8080/predict \
    -H "Content-Type: application/json" \
    -d '{"text":"I want to cancel my subscription"}'
```

Example response:

```json
{"intent":"complaint"}
```

## Production-Style Serving (Optional)

You can run the app behind Gunicorn using `wsgi.py`:

```bash
gunicorn -w 2 -b 0.0.0.0:8080 wsgi:application
```

## KServe Deployment

KServe deployment steps are documented in:

```text
KServe-implementation.md
```

That file includes:

- cert-manager installation
- KServe CRD + controller installation (Helm)
- `InferenceService` deployment for `intent-classifier`
- port-forward and test inference command

## Notes and Current Limitations

- The training dataset is intentionally tiny and for demonstration only.
- The current `/predict` response returns only the top intent.
- `predict_proba` is computed in `model/intent_model.py` but not currently returned by the API.

## Next Improvements

- Expand and version the training dataset.
- Add model metrics (accuracy, precision, recall, confusion matrix).
- Add unit tests for data loading, model training, and API endpoints.
- Return confidence scores in `/predict` response.
- Add Dockerfile and CI workflow for automated builds/tests.
