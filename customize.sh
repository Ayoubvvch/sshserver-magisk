#!/system/bin/sh
# Dropbear SSH & SFTP Server Magisk Module Installer

LOGDIR=/data/adb/sshserver/log
mkdir -p "$LOGDIR"
INSTALL_LOG="$LOGDIR/install.log"

log() {
  local msg="$1"
  echo "$msg" >> "$INSTALL_LOG"
  ui_print "$msg"
}

log ""
log "- Installing Dropbear SSH & SFTP Server..."

MODDIR="$MODPATH"
OK=0

# Ensure directories exist with secure permissions
mkdir -p /data/adb/sshserver/bin
mkdir -p /data/adb/sshserver/keys
mkdir -p /data/adb/sshserver/.ssh
chmod 700 /data/adb/sshserver
chmod 700 /data/adb/sshserver/bin
chmod 700 /data/adb/sshserver/keys
chmod 700 /data/adb/sshserver/.ssh

# Copy binaries shipped in module
if [ -f "$MODDIR/sshserver/bin/dropbear" ] && [ -f "$MODDIR/sshserver/bin/dropbearkey" ] && [ -f "$MODDIR/sshserver/sftp" ]; then
  cp "$MODDIR/sshserver/bin/dropbear" /data/adb/sshserver/bin/dropbear && \
  cp "$MODDIR/sshserver/bin/dropbearkey" /data/adb/sshserver/bin/dropbearkey && \
  cp "$MODDIR/sshserver/sftp" /data/adb/sshserver/sftp && \
  chmod 700 /data/adb/sshserver/bin/dropbear /data/adb/sshserver/bin/dropbearkey /data/adb/sshserver/sftp

  if [ -f "$MODDIR/sshserver/bin/mkpasswd" ]; then
    cp "$MODDIR/sshserver/bin/mkpasswd" /data/adb/sshserver/bin/mkpasswd
    chmod 700 /data/adb/sshserver/bin/mkpasswd
  fi

  log "- Copied dropbear, dropbearkey & mkpasswd binaries"
else
  abort "! ERROR: Missing binaries in module package. Installation aborted."
fi

# Copy default configuration if not already present (preserves user settings on upgrade)
if [ ! -f /data/adb/sshserver/config.env ]; then
  if cp "$MODDIR/sshserver/config.env" /data/adb/sshserver/config.env && chmod 600 /data/adb/sshserver/config.env; then
    log "- Installed default configuration to /data/adb/sshserver/config.env"
  else
    abort "! ERROR: Failed to install default configuration"
  fi
else
  log "- Existing configuration detected; preserving settings"
fi

# Create default root profile if not present
if [ ! -f /data/adb/sshserver/.profile ]; then
  cat << 'EOF' > /data/adb/sshserver/.profile
# Dropbear interactive shell environment
export PATH=/data/adb/magisk:/data/adb/sshserver/bin:$PATH:/system/bin:/system/xbin:/vendor/bin:/apex/com.android.runtime/bin
export HOME=/data/adb/sshserver
export TERM=xterm-256color
alias ll='ls -la'
EOF
  chmod 600 /data/adb/sshserver/.profile
  chown 0:0 /data/adb/sshserver/.profile
  log "- Configured root shell environment"
fi

# Configure WebUI permissions
if [ -d "$MODDIR/webroot" ]; then
  log "- Configuring KsuWebUI interface..."
  set_perm_recursive "$MODDIR/webroot" 0 0 0755 0644
fi

if [ -f "$MODDIR/icon.png" ]; then
  chmod 0644 "$MODDIR/icon.png" 2>/dev/null || true
fi

# Set permissions for system binaries
chmod 0755 "$MODDIR/system/bin/sshserverctl" 2>/dev/null || true
chown 0:0 "$MODDIR/system/bin/sshserverctl" 2>/dev/null || true

# Verification
if [ -x /data/adb/sshserver/bin/dropbear ] && [ -x /data/adb/sshserver/bin/dropbearkey ] && [ -x /data/adb/sshserver/sftp ]; then
  OK=1
fi

if [ "$OK" = "1" ]; then
  log "- Installation completed successfully!"
  log "- Default password is 'crdroid' (change via WebUI or 'sshserverctl passwd')"
  log "- WebUI: Open 'KsuWebUI' app to access the SSH Server Dashboard!"
  log "- Please reboot your device to start the SSH server."
else
  abort "! Installation incomplete or verification failed."
fi
