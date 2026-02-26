#!/bin/bash
set -e

# Usage: ./setup_dirs.sh [TARGET_DIR]
TARGET_DIR="${1:-.}"
TARGET_DIR=$(realpath "$TARGET_DIR")

echo "--- 📂 DockerApps Directory Setup (v3) ---"
echo "Target Base Directory: $TARGET_DIR"
echo ""

# --- DEFINING THE STACKS ---
GATEWAY_DIR="$TARGET_DIR/gateway-stack"
MEDIA_DIR="$TARGET_DIR/media-stack"
OPS_DIR="$TARGET_DIR/ops-stack"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "⚠️  WARNING: You are running this script as root!"
  echo "    Files/Dirs will be owned by root. You may need to chown them later."
fi

# Confirmation
read -r -p "Proceed with creating directories in $TARGET_DIR? [y/N] " response
case "$response" in
    [yY]*) true ;;
    *) echo "Aborted."; exit 1 ;;
esac

# Helpers
create_dir() {
    if [ ! -d "$1" ]; then mkdir -p "$1"; echo "✅ Created Dir: $1"; else echo "👌 Exists: $1"; fi
}

create_file() {
    if [ ! -f "$1" ]; then 
        mkdir -p "$(dirname "$1")"
        touch "$1"
        echo "✅ Created File: $1"
    else 
        echo "👌 File exists: $1"
    fi
}

# 🔄 LINKER: Automatically Symlink to Master .env
link_env() {
    local target_dir="$1"
    local link_path="$target_dir/.env"
    
    # Ensure directory exists
    mkdir -p "$target_dir"
    
    # Create the symlink (forces overwrite if exists)
    # logic: ../../.env assumes depth of 2 (e.g. gateway-stack/caddy)
    ln -sf ../../.env "$link_path"
    echo "🔗 Linked .env in: $target_dir"
}

# --- PRE-FLIGHT CHECK ---
# Create Master .env if missing (to prevent broken symlinks)
MASTER_ENV="$TARGET_DIR/.env"
if [ ! -f "$MASTER_ENV" ]; then
    touch "$MASTER_ENV"
    echo "✉️  Created empty MASTER .env at root (Populate this!)"
else
    echo "👌 MASTER .env exists."
fi

echo ""
echo "--- 1. 🌐 GATEWAY STACK ---"
create_dir "$GATEWAY_DIR/caddy/data"
create_dir "$GATEWAY_DIR/caddy/config"
create_dir "$GATEWAY_DIR/caddy/logs"
create_dir "$GATEWAY_DIR/caddy/maxmind"
create_dir "$GATEWAY_DIR/caddy/voidauth/config"
create_dir "$GATEWAY_DIR/caddy/voidauth/db"
link_env "$GATEWAY_DIR/caddy"

create_dir "$GATEWAY_DIR/crowdsec/config"
create_dir "$GATEWAY_DIR/crowdsec/data"
create_file "$GATEWAY_DIR/crowdsec/acquis.yaml"
link_env "$GATEWAY_DIR/crowdsec"

create_dir "$GATEWAY_DIR/tailscale/state"
link_env "$GATEWAY_DIR/tailscale"

create_dir "$GATEWAY_DIR/voidauth/config"
create_dir "$GATEWAY_DIR/voidauth/db"
link_env "$GATEWAY_DIR/voidauth"

echo ""
echo "--- 2. 🎬 MEDIA STACK ---"
create_dir "$MEDIA_DIR/jellyfin/jellyfin-config"
create_dir "$MEDIA_DIR/jellyfin/jellyfin-cache"
create_dir "$MEDIA_DIR/jellyfin/jellyseerr-config"
link_env "$MEDIA_DIR/jellyfin"

ARR_BASE="$MEDIA_DIR/vpn-arr-stack"
create_dir "$ARR_BASE/gluetun/config"
create_dir "$ARR_BASE/gluetun/auth"
create_dir "$ARR_BASE/qbittorrent/config"
create_dir "$ARR_BASE/transmission/config"
create_dir "$ARR_BASE/prowlarr/config"
create_dir "$ARR_BASE/jackett/config"
create_dir "$ARR_BASE/radarr/config"
create_dir "$ARR_BASE/sonarr/config"
create_dir "$ARR_BASE/bazarr/config"
create_dir "$ARR_BASE/flaresolverr/config"
create_dir "$ARR_BASE/profilarr/config"
create_dir "$ARR_BASE/speedtest-tracker"  
link_env "$ARR_BASE"

echo ""
echo "--- 3. 🛠️ OPS STACK ---"
create_dir "$OPS_DIR/kopia/config"
create_dir "$OPS_DIR/kopia/cache"
create_dir "$OPS_DIR/kopia/logs"
link_env "$OPS_DIR/kopia"

create_dir "$OPS_DIR/goaccess/data"
create_dir "$OPS_DIR/goaccess/html"
link_env "$OPS_DIR/goaccess"

create_dir "$GATEWAY_DIR/gotify/data"
link_env "$GATEWAY_DIR/gotify"

UTILS_BASE="$OPS_DIR/monitoring-stack"
create_dir "$UTILS_BASE/homepage/config"
create_dir "$UTILS_BASE/homepage/config/icons"
create_dir "$UTILS_BASE/wud/store"
create_dir "$UTILS_BASE/beszel/data"
create_dir "$UTILS_BASE/beszel/beszel_agent_data"
create_dir "$UTILS_BASE/dozzle"
create_dir "$UTILS_BASE/arcane/arcane-data"
link_env "$UTILS_BASE"

echo ""
echo "--- 4. 📄 ROOT FILES ---"
create_dir "$TARGET_DIR/.beszel"

echo ""
echo "✨ Setup Complete! Directories structure and symlinks are ready."