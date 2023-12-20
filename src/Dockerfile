# Use an official Python runtime as a base image
FROM python:3.10.2-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy just the requirements.txt first to leverage Docker cache
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Then copy the rest of your application's code
COPY . /app

# Make port 5000 available outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=app.py

# Run app.py when the container launches
CMD ["flask", "run", "--host=0.0.0.0"]
