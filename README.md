# Dropbear SSH & SFTP Server for Android (Magisk / KernelSU / APatch)

[![Release](https://img.shields.io/github/v/release/Ayoubvvch/sshserver-magisk?style=flat-square&color=blue)](https://github.com/Ayoubvvch/sshserver-magisk/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%2010--15%2B-green.svg?style=flat-square)](https://github.com/Ayoubvvch/sshserver-magisk)
[![Architecture](https://img.shields.io/badge/Architecture-arm64-red.svg?style=flat-square)](https://github.com/Ayoubvvch/sshserver-magisk)

A lightweight, standalone, statically-compiled **Dropbear SSH and SFTP server** module for Android. Provides persistent, headless root access over SSH (port 22) and SFTP file management from boot without requiring Termux, userland apps, or interactive terminal setups.

---

## ✨ Features

- **🚀 100% Headless & Background**: Starts automatically at boot via Magisk `late_start` service. Runs silently without battery-draining UI wrappers.
- **⚡ Static Musl Compilation (arm64)**: Dropbear v2025.88 and SFTP are statically linked against musl libc. Completely bypasses Android Bionic linker namespace restrictions, ensuring flawless compatibility on Android 10, 11, 12, 13, 14, and Android 15+.
- **📁 Native SFTP Server**: Includes statically built `sftp` hardcoded to `/data/adb/sshserver/sftp`. Compatible out-of-the-box with **WinSCP**, **FileZilla**, **Cyberduck**, and **VS Code Remote - SSH**.
- **🔑 Dual Authentication**:
  - **Public Key Authentication**: High-security Ed25519 and RSA keys via standard `authorized_keys`.
  - **Password Authentication**: Crypt SHA-512 hashed passwords.
- **🪄 Dynamic Systemless `/system/etc/passwd`**: Android does not ship with standard `/etc/passwd`. This module dynamically generates a systemless passwd file during `post-fs-data` boot stage, allowing standard Unix authentication routines to work seamlessly.
- **⏱️ Sleep & Doze Proof**: Configured with a 30-second TCP keepalive (`-K 30`) to keep SSH sessions stable even when Android enters deep sleep (Doze mode).
- **🛠️ Management CLI (`sshserverctl`)**: Global command mounted to `/system/bin/sshserverctl` for starting, stopping, restarting, inspecting status, or changing root password interactively.
- **🌐 Full Environment Export**: Sessions automatically inherit Magisk binaries (`/data/adb/magisk`), Android utilities (`/system/bin`, `/vendor/bin`, `/apex`), and user environment.

---

## 📦 Installation

1. Download the latest **`sshserver-magisk.zip`** from [GitHub Releases](https://github.com/Ayoubvvch/sshserver-magisk/releases).
2. Open **Magisk**, **KernelSU**, or **APatch** app on your phone.
3. Go to **Modules** ➔ **Install from storage** ➔ Select `sshserver-magisk.zip`.
4. Once installation completes, **reboot your device**.

---

## 🚀 Quick Start & Connecting

### 1. Default Password Login
By default, the server listens on **port 22** with password authentication enabled:
- **Username**: `root`
- **Default Password**: `crdroid`
- **Port**: `22`

From your computer terminal (PowerShell, Command Prompt, or Linux/macOS shell):
```bash
ssh root@<PHONE_IP_ADDRESS>
```
*(Replace `<PHONE_IP_ADDRESS>` with your phone's Wi-Fi IP address, visible in Android Settings ➔ Wi-Fi).*

### 2. Passwordless Public Key Login (Recommended)
For the best security and convenience, use SSH keys:

1. Copy your PC's public key (e.g. `~/.ssh/id_ed25519.pub`) into `/data/adb/sshserver/.ssh/authorized_keys` on your phone:
   ```bash
   # From your PC (if ssh-copy-id is available):
   ssh-copy-id -i ~/.ssh/id_ed25519.pub root@<PHONE_IP_ADDRESS>
   ```
   Or manually append your public key directly to `/data/adb/sshserver/.ssh/authorized_keys`.

2. Add a convenient alias in your PC's `~/.ssh/config`:
   ```ssh-config
   Host phone
       HostName 192.168.1.50
       User root
       Port 22
       IdentityFile ~/.ssh/id_ed25519
   ```
   Now you can simply connect by typing:
   ```bash
   ssh phone
   ```

---

## 🛠️ CLI Management (`sshserverctl`)

Run `sshserverctl` in any root shell or terminal on your phone:

| Command | Action |
| :--- | :--- |
| `sshserverctl start` | Starts the SSH daemon if stopped. |
| `sshserverctl stop` | Stops the running SSH daemon. |
| `sshserverctl restart` | Restarts the SSH daemon. |
| `sshserverctl status` | Checks PID and running status. |
| `sshserverctl passwd` | Interactively prompts for and updates the root password instantly. |

---

## ⚙️ Configuration (`config.env`)

Configuration is stored in `/data/adb/sshserver/config.env` and preserved across module updates:

```sh
# Listening port (default: 22)
PORT=22

# Password authentication (1 = enabled, 0 = disabled / key-only)
ALLOW_PASSWORD=1

# Root logins (1 = allowed, 0 = disallowed)
ALLOW_ROOT=1

# Plaintext password (auto-hashed on boot, then cleared)
PASSWORD=""

# Pre-computed SHA-512 crypt hash (always use single quotes)
PASSWORD_HASH='$6$saltsalt$hashedpassword...'
```

> [!TIP]
> To disable password logins completely and enforce public key authentication only, set `ALLOW_PASSWORD=0` in `config.env` and restart the service (`sshserverctl restart`).

---

## 📁 File Structure

```text
/data/adb/sshserver/
├── bin/
│   ├── dropbear           # Dropbear server binary (static musl arm64)
│   └── dropbearkey        # Dropbear key generator
├── keys/
│   └── dropbear_ed25519_host_key  # Host key
├── .ssh/
│   └── authorized_keys    # Your authorized public keys
├── log/
│   ├── service.log        # Boot launch logs
│   └── dropbear.log       # Dropbear daemon runtime output
├── sftp                   # SFTP subsystem binary
├── config.env             # User configuration file
└── dropbear.pid           # Running daemon PID file
```

---

## 🔨 Building the Flashable ZIP

To build the flashable zip package from source:

```bash
# Clone the repository
git clone https://github.com/Ayoubvvch/sshserver-magisk.git
cd sshserver-magisk

# Create flashable zip (excluding git files)
zip -r9 sshserver-magisk.zip . -x ".git*" ".github*" "*.zip" "README.md" "LICENSE"
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
Dropbear SSH is created by Matt Johnston and licensed under a BSD-style license.
