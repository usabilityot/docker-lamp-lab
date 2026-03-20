#!/bin/bash
#
# docker-restart-containers.sh - Lab Environment Recovery
#
# DESCRIPTION:
#   Wipes any stale container instances and re-launches the 
#   MariaDB and Webserver containers on the lab-network.
#
# ----------------------------------------------------------------------

# 1. Define variables for easy updates
NETWORK_NAME="app-network"
DB_NAME="db-container"
WEB_NAME="webserver"

echo "--- 🛠️  Resetting Docker Lab Environment ---"

# 2. Ensure the network exists
if ! docker network ls | grep -q "$NETWORK_NAME"; then
    echo "🌐 Creating network: $NETWORK_NAME"
    docker network create "$NETWORK_NAME"
fi

# 3. Force remove existing containers (ignores errors if they don't exist)
echo "🧹 Cleaning up old containers..."
docker rm -f "$DB_NAME" "$WEB_NAME" 2>/dev/null

# 4. Launch MariaDB
# We add -d for detached and --network to fix DNS issues
echo "🗄️  Launching Database..."
docker run -d \
    --name "$DB_NAME" \
    --network "$NETWORK_NAME" \
    -e MYSQL_ROOT_PASSWORD=rootpassword \
    -e MYSQL_DATABASE=testdb \
    -e MYSQL_USER=labuser \
    -e MYSQL_PASSWORD=labpass \
    it135-mariadb:1.0


# 5. Launch Webserver
echo "🌐 Launching Webserver..."
docker run -d \
    --name "$WEB_NAME" \
    --network "$NETWORK_NAME" \
    -p 8080:80 \
    -v $PWD:/var/www/html \
    webserver-base:1.0

# Add this pause to give MariaDB time to breathe
echo "⏳ Waiting 20 seconds for database initialization..."
sleep 20


echo "--- ✅ Lab Environment is LIVE ---"
docker ps
