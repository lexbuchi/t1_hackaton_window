# Dockerfile

# Use Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Set environment variables (can be overridden)
ENV NEO4J_URI="bolt://0.0.0.0:7687" \
    NEO4J_USERNAME="<neo4j_user>" \
    NEO4J_PASSWORD="<password>" \
    NEO4J_DATABASE="<neo4j_database>" \
    OPENAI_API_KEY="EMPTY" \
    OPENAI_API_BASE="http://0.0.0.0:8004/v1"

# Set the entrypoint to the main.py script
ENTRYPOINT ["python", "main.py"]