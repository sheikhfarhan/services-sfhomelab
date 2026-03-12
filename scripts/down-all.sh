#!/bin/bash
set -e # Exit immediately if any command fails

echo "--- 🛑 Gracefully Stopping All Docker Stacks ---"
echo "This will take a moment as all containers are spun down..."
echo ""

# Define the absolute path to our stacks
BASE_DIR="/home/sfarhan/homelab/services"

# Define Sub-Stack Paths for cleaner code
GATEWAY="$BASE_DIR/gateway-stack"
OPS="$BASE_DIR/ops-stack"
MEDIA="$BASE_DIR/media-stack"
MON="$BASE_DIR/mon-stack"

# --- Step 1: Analytics & Backups ---
echo "[1/9] Stopping Kopia (Backups)..."
cd "$OPS/kopia" && docker compose down

echo "[2/9] Stopping GoAccess (Logs Analytics)..."
cd "$OPS/goaccess" && docker compose down

# --- Step 2: Automation Engine ---
echo "[3/9] Stopping VPN-ARR-Stack (Downloads & Managers)..."
cd "$MEDIA/vpn-arr-stack" && docker compose down

# --- Step 3: Media Core ---
echo "[4/9] Stopping Jellyfin Stack (Media & Requests)..."
cd "$MEDIA/jellyfin" && docker compose down

# --- Step 4: Monitoring & Management ---
echo "[5/9] Stopping Monitoring Stack (Homepage, Socket Proxy, Beszel)..."
cd "$MON" && docker compose down

# --- Step 5: Core & Security Infrastructure ---
echo "[6/9] Stopping Caddy (Reverse Proxy)..."
cd "$GATEWAY/caddy" && docker compose down

echo "[7/9] Stopping CrowdSec (Security Brain)..."
cd "$GATEWAY/crowdsec" && docker compose down

echo "[8/9] Stopping Gotify (Notifications)..."
cd "$OPS/gotify" && docker compose down

echo "[9/9] Stopping VoidAuth (SSO Identity)..."
cd "$GATEWAY/voidauth" && docker compose down

echo ""
echo "🛑 All stacks have been successfully shut down! Safe to perform maintenance."