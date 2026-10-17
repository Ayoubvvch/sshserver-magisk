#!/system/bin/sh
# This script starts the dropbear SSH server at boot via Magisk late_start service

LOGDIR=/data/adb/sshserver/log
mkdir -p "$LOGDIR"
SERVICE_LOG="$LOGDIR/service.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$SERVICE_LOG"
}

log "[service] Launching dropbear service..."

# Export comprehensive PATH so child processes inherit all system and Magisk tools
export PATH=/data/adb/magisk:/data/adb/sshserver/bin:$PATH:/system/bin:/system/xbin:/vendor/bin:/apex/com.android.runtime/bin
export HOME=/data/adb/sshserver

# Load configuration variables from config.env if present
CONFIG_FILE="/data/adb/sshserver/config.env"
PORT=22
ALLOW_PASSWORD=1
ALLOW_ROOT=1

if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
fi
PORT=${PORT:-22}
ALLOW_PASSWORD=${ALLOW_PASSWORD:-1}
ALLOW_ROOT=${ALLOW_ROOT:-1}

PIDFILE=/data/adb/sshserver/dropbear.pid
HOSTKEY=/data/adb/sshserver/keys/dropbear_ed25519_host_key

# Check that dropbear binaries exist
if [ ! -x /data/adb/sshserver/bin/dropbear ]; then
  log "[service] ERROR: dropbear binary is missing or not executable. Aborting startup."
  exit 1
fi
if [ ! -x /data/adb/sshserver/bin/dropbearkey ]; then
  log "[service] ERROR: dropbearkey binary is missing or not executable. Aborting startup."
  exit 1
fi

# Generate host key if it does not exist
if [ ! -f "$HOSTKEY" ]; then
  log "[service] Generating Ed25519 host key at $HOSTKEY"
  /data/adb/sshserver/bin/dropbearkey -t ed25519 -f "$HOSTKEY" >> "$SERVICE_LOG" 2>&1
fi

# Stop any existing dropbear process to avoid duplicate instances
if [ -f "$PIDFILE" ]; then
  OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    log "[service] Stopping existing dropbear process ($OLD_PID)"
    kill "$OLD_PID"
    sleep 1
  fi
  rm -f "$PIDFILE"
fi

# Compose arguments:
# -r <hostkey>: Ed25519 host key
# -p <port>: listening TCP port
# -P <pidfile>: process ID file
# -E: log to stderr (redirected to dropbear.log)
# -e: pass server process environment (PATH, etc.) to child sessions
# -K 30: keepalive ping every 30 seconds to prevent Wi-Fi sleep timeouts
ARGS="-r $HOSTKEY -p $PORT -P $PIDFILE -E -e -K 30"

# Disable password logins if configured
if [ "$ALLOW_PASSWORD" = "0" ]; then
  ARGS="$ARGS -s"
fi

# Disallow root logins if configured
if [ "$ALLOW_ROOT" = "0" ]; then
  ARGS="$ARGS -w"
fi

# Start dropbear in background
log "[service] Starting dropbear with arguments: $ARGS"
/data/adb/sshserver/bin/dropbear $ARGS >> "$LOGDIR/dropbear.log" 2>&1 &
log "[service] dropbear started with PID $!"
