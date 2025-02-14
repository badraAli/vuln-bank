#!/bin/bash
# deploy/deploy.sh

# Exit on error
set -e

echo "Starting deployment..."

# Variables
EC2_HOST="${EC2_HOST}"
SSH_KEY="${SSH_PRIVATE_KEY}"
APP_NAME="vulnerable-bank"
PROJECT_DIR="/home/ubuntu/$APP_NAME"  # Directory on the EC2 instance to store the project

# Save SSH key
echo "$SSH_KEY" > deploy_key.pem
chmod 400 deploy_key.pem

# Copy project files to EC2
echo "Copying project files to EC2..."
scp -i deploy_key.pem \
    -o StrictHostKeyChecking=no \
    -r ./* ubuntu@${EC2_HOST}:${PROJECT_DIR}/

# Deploy on EC2
echo "Deploying on EC2..."
ssh -i deploy_key.pem \
    -o StrictHostKeyChecking=no \
    ubuntu@${EC2_HOST} << 'EOF'
# Navigate to the project directory
cd /home/ubuntu/vulnerable-bank

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    echo "Docker installed successfully."
fi

# Build Docker image
echo "Building Docker image..."
docker build -t $APP_NAME .

# Stop and remove existing container (if any)
echo "Stopping and removing existing container..."
docker stop $APP_NAME || true
docker rm $APP_NAME || true

# Run new container
echo "Starting new container..."
docker run -d \
    --name $APP_NAME \
    -p 5000:5000 \
    --restart unless-stopped \
    $APP_NAME
EOF

# Cleanup
rm deploy_key.pem

echo "Deployment completed successfully!"