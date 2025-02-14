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
chmod 400 deploy_key.pem

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
    ubuntu@${EC2_HOST} << 'EOF'
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

# Load Docker image
docker load < app.tar

# Stop and remove existing container (if any)
docker stop $APP_NAME || true
docker rm $APP_NAME || true

# Run new container
docker run -d \
    --name $APP_NAME \
    -p 80:5000 \
    --restart unless-stopped \
    $APP_NAME
EOF
# Cleanup
rm deploy_key.pem app.tar

echo "Deployment completed successfully!"