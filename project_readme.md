# Containerized Chat Server Project

## Overview
This project deploys Rocket.Chat using Docker and secures it with UFW and SSH.

## Setup Instructions

1. Run `scripts/setup_chat.sh` to install Docker and start Rocket.Chat.
2. Visit `http://localhost:3000` or `http://www.blascyzkowski.com:3000` to access the chat.
3. UFW allows only necessary ports (3000, SSH).
4. Docker Compose manages MongoDB and Rocket.Chat containers.

## Screenshots

- `docker ps`
- Chat interface
- `ufw status`

## Security Measures

- UFW configured
- SSH port changed and root login disabled
