# Changelog

## v1.4.0
- **KsuWebUI & KernelSU Interactive Dashboard**: Added a comprehensive WebUI (`webroot/index.html`) providing mobile graphical control over the SSH and SFTP server.
- **One-Tap Quick Connect**: Automatically displays local Wi-Fi / network IP address with a one-click copyable SSH connection command.
- **Server Power & Session Management**: Start, stop, or restart Dropbear daemon directly from the UI with real-time active session monitoring.
- **In-App Password & Configuration Editor**: Change root password (with SHA-512 crypt hashing) and update listening port or authentication modes without touching terminal files.
- **SSH Authorized Keys Manager**: View, add from clipboard, and remove authorized public keys (`id_ed25519.pub`, `id_rsa.pub`) visually.
- **Live Runtime Log Viewer**: Inspect Dropbear daemon logs directly inside the app for immediate connection troubleshooting.
- **CLI Backend Enhancements**: Expanded `sshserverctl` with `status-json`, `set-config`, `set-password`, `get-keys`, `add-key`, `remove-key`, and `get-logs`.

## v1.3.0
- **Native Magisk Update Channel**: Added native `updateJson` support so updates can be discovered and installed directly inside Magisk App, KernelSU, and APatch.
- **Automated CI/CD Release Pipeline**: Added and improved GitHub Actions workflow to automatically package and release flashable module assets.
- **Changelog & Documentation**: Added structured changelog and updated documentation.

## v1.2.0
- **Robust Password Hashing**: Fixed shell variable expansion where SHA-512 crypt prefixes (`$6$`) could be stripped by `sh`. Added safe regex parsing and single-quote preservation in `config.env`, `post-fs-data.sh`, and `sshserverctl passwd`.
- **Comprehensive PATH & Root Environment**: Sessions automatically inherit Magisk binaries (`/data/adb/magisk`), system utilities (`/system/bin`, `/vendor/bin`, `/apex`), and Termux paths.
- **Sleep & Doze Proof Keepalive**: Added `-K 30` (30s TCP keepalive) to Dropbear daemon startup to keep SSH connections alive even when Android enters deep sleep.
- **Clean Dropbear Flags**: Enabled `-e` to pass server environment to client sessions, correctly mapped root login restrictions (`-w`), and cleaned gateway forwarding options.
- **Root Profile**: Automatically configures `/data/adb/sshserver/.profile` for interactive root terminal sessions.
- **Android 10 - 15+ Compatibility**: Tested and fully functional on modern Android architectures (arm64).

## v1.1.0
- Initial stable release with Dropbear static binaries and dynamic password generation.
