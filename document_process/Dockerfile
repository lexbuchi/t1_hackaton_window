# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python script into the container
COPY pdf_to_markdown.py .

# Create directories for PDFs and Markdown files
RUN mkdir -p /app/pdfs /app/markdowns

# Set environment variables (can be overridden at runtime)
ENV PDF_FOLDER=/app/pdfs \
    MARKDOWN_FOLDER=/app/markdowns

# Set the entrypoint to run the script
ENTRYPOINT ["python", "pdf_to_markdown.py"]