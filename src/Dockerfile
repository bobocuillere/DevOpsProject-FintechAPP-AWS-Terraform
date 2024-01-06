# Use an official Python runtime as a base image
FROM python:3.10.2-slim

# Install postgres client to use the wait-for-postgres script
RUN apt-get update \
    && apt-get install -y postgresql-client \
    && rm -rf /var/lib/apt/lists/

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

# Copy the wait-for-postgres script
COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod +x /wait-for-postgres.sh

# Update the CMD to use the script and Run app.py when the container launches
CMD ["./wait-for-postgres.sh", "db", "flask", "run", "--host=0.0.0.0"]

