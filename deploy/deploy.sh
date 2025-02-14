#!/bin/bash
# deploy/deploy.sh

# Exit on error
set -e

echo "Starting deployment..."

# Variables
EC2_HOST="${EC2_HOST}"
SSH_KEY="${SSH_PRIVATE_KEY}"
APP_NAME="vulnerable-bank"

# Save SSH key
echo "$SSH_KEY" > deploy_key.pem
chmod 600 deploy_key.pem

# Build Docker image
echo "Building Docker image..."
docker build -t $APP_NAME .

# Save image to tar
echo "Saving Docker image..."
docker save $APP_NAME > app.tar

# Copy files to EC2
echo "Copying files to EC2..."
scp -i deploy_key.pem \
    -o StrictHostKeyChecking=no \
    app.tar \
    ubuntu@${EC2_HOST}:~/

# Deploy on EC2
echo "Deploying on EC2..."
ssh -i deploy_key.pem \
    -o StrictHostKeyChecking=no \
    ubuntu@${EC2_HOST} \
    "docker load < app.tar && \
     docker stop $APP_NAME || true && \
     docker rm $APP_NAME || true && \
     docker run -d \
       --name $APP_NAME \
       -p 80:5000 \
       --restart unless-stopped \
       $APP_NAME"

# Cleanup
rm deploy_key.pem app.tar

echo "Deployment completed successfully!"