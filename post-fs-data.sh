#!/system/bin/sh
# This script runs in post-fs-data mode (early boot stage)

MODDIR=${0%/*}
CONFIG_FILE="/data/adb/sshserver/config.env"

# Create directories and ensure secure permissions
mkdir -p /data/adb/sshserver/bin
mkdir -p /data/adb/sshserver/keys
mkdir -p /data/adb/sshserver/log
mkdir -p /data/adb/sshserver/.ssh

chmod 700 /data/adb/sshserver
chmod 700 /data/adb/sshserver/bin
chmod 700 /data/adb/sshserver/keys
chmod 700 /data/adb/sshserver/.ssh

# If authorized_keys exists, ensure secure permissions
if [ -f /data/adb/sshserver/.ssh/authorized_keys ]; then
  chmod 600 /data/adb/sshserver/.ssh/authorized_keys
  chown -R 0:0 /data/adb/sshserver/.ssh
fi

# Ensure default profile for interactive root sessions exists
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
fi

# Default configurations
PORT=22
ALLOW_PASSWORD=1
ALLOW_ROOT=1
PASSWORD=""
PASSWORD_HASH=""

# Safely extract raw PASSWORD_HASH without shell variable expansion
if [ -f "$CONFIG_FILE" ]; then
  RAW_HASH=$(grep -E '^[[:space:]]*PASSWORD_HASH=' "$CONFIG_FILE" 2>/dev/null | head -n1 | sed -e 's/^[[:space:]]*PASSWORD_HASH=//' -e 's/^["']//' -e 's/["']$//')
  if [ -n "$RAW_HASH" ]; then
    PASSWORD_HASH="$RAW_HASH"
  fi
  . "$CONFIG_FILE"
  # Re-apply extracted hash if it was mangled by shell sourcing
  if [ -n "$RAW_HASH" ]; then
    PASSWORD_HASH="$RAW_HASH"
  fi
fi

# If password authentication is allowed and plaintext password is provided, generate hash
if [ "$ALLOW_PASSWORD" = "1" ]; then
  if [ -z "$PASSWORD_HASH" ] && [ -n "$PASSWORD" ]; then
    if [ -x /data/adb/magisk/busybox ]; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | /data/adb/magisk/busybox cryptpw -m sha512 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ] && which busybox >/dev/null 2>&1; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | busybox cryptpw -m sha512 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ] && which cryptpw >/dev/null 2>&1; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | cryptpw -m sha512 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ] && [ -x /data/adb/magisk/busybox ]; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | /data/adb/magisk/busybox cryptpw 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ] && which busybox >/dev/null 2>&1; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | busybox cryptpw 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ] && which openssl >/dev/null 2>&1; then
      PASSWORD_HASH=$(echo -n "$PASSWORD" | openssl passwd -1 -stdin 2>/dev/null)
    fi
    if [ -z "$PASSWORD_HASH" ]; then
      # Fallback SHA-512 hash for 'crdroid'
      PASSWORD_HASH='$6$xR50rJ0RcmaVH0X9$WQQHov4xxfBKvfhssC2exMoDD8ZUoWc5ne2QsOwBtXBxiBQR7IOOEZhUzGLk1seTvQG2bxbCM392ehPyVqWF5.'
    fi

    # Update config.env to save hash with single quotes and clear plaintext password
    if [ -f "$CONFIG_FILE" ] && [ -n "$PASSWORD_HASH" ]; then
      TEMP_CONF=$(grep -v "^PASSWORD=" "$CONFIG_FILE" | grep -v "^PASSWORD_HASH=")
      echo "$TEMP_CONF" > "$CONFIG_FILE"
      echo "PASSWORD_HASH='$PASSWORD_HASH'" >> "$CONFIG_FILE"
      echo "PASSWORD=''" >> "$CONFIG_FILE"
    fi
  fi
fi

# If password login is disabled or no hash exists, set to *
if [ "$ALLOW_PASSWORD" = "0" ] || [ -z "$PASSWORD_HASH" ]; then
  PASSWORD_HASH="*"
fi

# Dynamically generate systemless /system/etc/passwd file
mkdir -p "$MODDIR/system/etc"
echo "root:$PASSWORD_HASH:0:0:root:/data/adb/sshserver:/system/bin/sh" > "$MODDIR/system/etc/passwd"
chmod 644 "$MODDIR/system/etc/passwd"
chown 0:0 "$MODDIR/system/etc/passwd"
