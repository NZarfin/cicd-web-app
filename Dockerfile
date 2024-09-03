# Use a slim Python image as the base
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Python dependencies from requirements.txt
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Expose the application on port 8081
EXPOSE 8081

# Set the entrypoint to Python, so you can run Python commands directly
ENTRYPOINT ["python"]

# Default command is to run the Flask application
CMD ["/app/app.py"]

# Set a health check to ensure the app is running
HEALTHCHECK CMD curl --fail http://localhost:8081/ || exit 1

