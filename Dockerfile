# Use an official nginx runtime as a parent image
FROM nginx:latest

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY ./public /app/public

# Copy your default nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 to the world
EXPOSE 5000

# Run nginx
CMD ["nginx", "-g", "daemon off;"]