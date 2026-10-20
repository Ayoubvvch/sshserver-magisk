# Dropbear SSH & SFTP Server for Android (Magisk / KernelSU / APatch)

[![Release](https://img.shields.io/github/v/release/Ayoubvvch/sshserver-magisk?style=flat-square&color=blue)](https://github.com/Ayoubvvch/sshserver-magisk/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%2010--15%2B-green.svg?style=flat-square)](https://github.com/Ayoubvvch/sshserver-magisk)
[![Architecture](https://img.shields.io/badge/Architecture-arm64-red.svg?style=flat-square)](https://github.com/Ayoubvvch/sshserver-magisk)

A lightweight, standalone, statically-compiled **Dropbear SSH and SFTP server** module for Android. Features an interactive **KsuWebUI graphical management dashboard** as well as a complete CLI control utility. Provides persistent, headless root access over SSH (port 22) and SFTP file management from boot without requiring Termux, userland apps, or interactive terminal setups.

---

## ✨ Features

- **🎨 Modern WebUI (KsuWebUI / KernelSU / APatch)**: Comprehensive graphical dashboard with one-click connect command, server power toggle, live session monitoring, and real-time logs.
- **🚀 100% Headless & Background**: Starts automatically at boot via Magisk `late_start` service. Runs silently without battery-draining UI wrappers.
- **⚡ Static Musl Compilation (arm64)**: Dropbear v2025.88 and SFTP are statically linked against musl libc. Completely bypasses Android Bionic linker namespace restrictions, ensuring flawless compatibility on Android 10, 11, 12, 13, 14, and Android 15+.
- **📁 Native SFTP Server**: Includes statically built `sftp` hardcoded to `/data/adb/sshserver/sftp`. Compatible out-of-the-box with **WinSCP**, **FileZilla**, **Cyberduck**, and **VS Code Remote - SSH**.
- **🔑 Dual Authentication & Keys Manager**:
  - **Public Key Authentication**: High-security Ed25519 and RSA keys via standard `authorized_keys`, easily managed directly via WebUI.
  - **Password Authentication**: Crypt SHA-512 hashed passwords, customizable through GUI or CLI.
- **🪄 Dynamic Systemless `/system/etc/passwd`**: Generates a systemless passwd file dynamically during `post-fs-data` boot stage, allowing standard Unix authentication routines to work seamlessly.
- **⏱️ Sleep & Doze Proof**: Configured with a 30-second TCP keepalive (`-K 30`) to keep SSH sessions stable even when Android enters deep sleep (Doze mode).
- **🛠️ Management CLI (`sshserverctl`)**: Global command mounted to `/system/bin/sshserverctl` for starting, stopping, restarting, inspecting status, or changing root password interactively.
- **⚡ In-App Updates**: Built-in `updateJson` manifest support for one-click updates directly inside the Magisk / KernelSU app.

---

## 📦 Installation

1. Download the latest **`sshserver-magisk.zip`** from [GitHub Releases](https://github.com/Ayoubvvch/sshserver-magisk/releases).
2. Open **Magisk**, **KernelSU**, or **APatch** app on your phone.
3. Go to **Modules** ➔ **Install from storage** ➔ Select `sshserver-magisk.zip`.
4. Once installation completes, **reboot your device**.

---

## 🚀 How to Use

### 1. Interactive WebUI (Recommended)
If you have **KsuWebUI** (or KernelSU / APatch) installed:
1. Open the **KsuWebUI** app on your phone.
2. Select **Dropbear SSH Server**.
3. View your Wi-Fi IP and copy the SSH command with one tap!
4. Start, stop, or restart the server, edit root password, manage public keys, and inspect runtime logs.

### 2. Command-Line Remote Login
From your computer terminal (PowerShell, Command Prompt, or Linux/macOS shell):
```bash
ssh root@<PHONE_IP_ADDRESS>
```
- **Default Username**: `root`
- **Default Password**: `crdroid`
- **Default Port**: `22`

*(Replace `<PHONE_IP_ADDRESS>` with your phone's Wi-Fi IP address shown in the WebUI or Android Wi-Fi settings).*

---

## 🛠️ CLI Management (`sshserverctl`)

Run `sshserverctl` in any root terminal on your phone:

| Command | Action |
| :--- | :--- |
| `sshserverctl start` | Starts the SSH daemon if stopped. |
| `sshserverctl stop` | Stops the running SSH daemon. |
| `sshserverctl restart` | Restarts the SSH daemon. |
| `sshserverctl status` | Checks running status, IP, and active sessions. |
| `sshserverctl status-json` | Returns status in JSON format (for WebUI). |
| `sshserverctl passwd` | Interactively prompts for and updates the root password instantly. |
| `sshserverctl set-password <pass>` | Updates root password directly with SHA-512 hashing. |
| `sshserverctl get-keys` | Lists installed authorized keys. |
| `sshserverctl add-key "<key>"` | Adds a public key to `authorized_keys`. |
| `sshserverctl remove-key <index>` | Deletes key by index. |
| `sshserverctl get-logs` | Prints the latest runtime daemon logs. |

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
Dropbear SSH is created by Matt Johnston and licensed under a BSD-style license.
Developed by [Ayoubvvch](https://github.com/Ayoubvvch).
