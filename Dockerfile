# Use Alpine as the base image
FROM alpine:3.18

# Install Python 3 and pip
RUN apk add --no-cache python3 py3-pip

# Upgrade pip
RUN pip3 install --no-cache --upgrade pip

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Create a virtual environment and install dependencies from requirements.txt
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache -r requirements.txt

# Expose the application on port 8081
EXPOSE 8081

# Set the entrypoint to use the virtual environment's Python
ENTRYPOINT ["/app/venv/bin/python"]

# Default command is to run the Flask application
CMD ["/app/app.py"]

# Set a health check to ensure the app is running
HEALTHCHECK CMD curl --fail http://localhost:8081/ || exit 1

