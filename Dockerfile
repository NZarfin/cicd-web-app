# Use a Python image
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Add the current directory to the container as /app
COPY . /app

# Install Python dependencies from requirements.txt
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Expose the application on port 8081
EXPOSE 8081

# Set up the health check on port 8081
HEALTHCHECK CMD curl --fail http://localhost:8081/ || exit 1

# Execute the Flask app
ENTRYPOINT ["python"]
CMD ["/app/app.py"]

