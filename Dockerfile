# Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Copy requirements if they exist
COPY requirements.txt* ./

# Install dependencies
RUN if [ -f requirements.txt ]; then pip install --user --no-cache-dir -r requirements.txt; fi

# Runtime stage
FROM python:3.11-slim

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY . .

# Set environment variables
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000')" || exit 1

EXPOSE 5000

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
