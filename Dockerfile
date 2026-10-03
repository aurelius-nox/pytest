FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
COPY add.py .
COPY tests/test_app.py .
RUN pip install -r requirements.txt
CMD ["python", "-m", "pytest"]