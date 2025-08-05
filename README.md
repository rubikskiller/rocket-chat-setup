Rocket.Chat Setup with Docker and Docker Compose
==================================================

This guide will walk you through installing Docker, the Docker Compose V2 plugin, and setting up Rocket.Chat along with MongoDB (version 5.0) using Docker Compose. Follow these steps to get your Rocket.Chat environment running.

Prerequisites:
--------------
• Ubuntu 24.04.1 (or similar)
• A user account with sudo privileges and Internet access

Step 1: Download the Setup Script
----------------------------------
1. Open a terminal.
2. Create a new file called “setup_chat.sh”:

   nano setup_chat.sh

3. Copy and paste the following script into the file:

-----------------------------------------------------------
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
-----------------------------------------------------------

4. Save the file by pressing Ctrl + O, then hit Enter. Exit Nano by pressing Ctrl + X.

Step 2: Make the Script Executable
------------------------------------
In the terminal, run:

   chmod +x setup_chat.sh

Step 3: Run the Setup Script
----------------------------
Execute the script by running:

   ./setup_chat.sh

The script will do the following automatically:
  • Install Docker and required dependencies.
  • Add Docker’s official repository and install the Docker Compose plugin.
  • Create a docker-compose.yml file for Rocket.Chat and MongoDB (v5.0).
  • Pull the necessary Docker images.
  • Start the containers in detached mode.
  • Open port 3000 through the firewall if UFW is active.

Step 4: Verify the Installation
-------------------------------
After the script completes, check that Rocket.Chat is running:
  1. Open a browser on the machine or access via your server’s IP.
  2. Go to: http://localhost:3000 (or http://your-server-ip:3000)
  3. You should see the Rocket.Chat setup screen.

Optional: Troubleshooting
-------------------------
• If you need to check the status of your containers, run:

     docker compose ps

• To view logs for Rocket.Chat, run:

     docker compose logs -f rocketchat

• To stop and remove the containers and volumes, run:

     docker compose down -v

Congratulations! Your Rocket.Chat environment is now up and running.
--------------------------------------------------
