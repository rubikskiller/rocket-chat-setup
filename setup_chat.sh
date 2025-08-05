#!/bin/bash

set -e

echo "🚀 Starting Rocket.Chat setup..."

# 1. Install Docker prerequisites
echo "🔧 Installing Docker dependencies..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# 2. Add Docker’s official GPG key
echo "🔐 Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Add Docker’s official repository
echo "📦 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Install Docker Engine + Compose plugin
echo "📥 Installing Docker and Docker Compose..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Enable and start Docker
echo "✅ Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# 6. Create docker-compose.yml
echo "📝 Creating docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: "3.9"

services:
  mongo:
    image: mongo:5.0
    restart: always
    volumes:
      - ./data/db:/data/db

  rocketchat:
    image: rocketchat/rocket.chat:latest
    restart: always
    ports:
      - "3000:3000"
    environment:
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - ROOT_URL=http://localhost:3000
      - PORT=3000
    depends_on:
      - mongo
EOF

# 7. Start Rocket.Chat
echo "🚀 Starting Rocket.Chat and MongoDB containers..."
docker compose down -v
docker compose pull
docker compose up -d

# 8. Allow port 3000 through UFW if enabled
if sudo ufw status | grep -q "Status: active"; then
  echo "🔓 Allowing port 3000 through UFW firewall..."
  sudo ufw allow 3000
fi

echo "🎉 Rocket.Chat setup complete!"
echo "👉 Visit: http://localhost:3000"
