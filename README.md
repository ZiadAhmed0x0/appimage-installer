# 🐧 Universal AppImage Installer

![Bash](https://img.shields.io/badge/Script-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue)

A robust, interactive Bash script designed to streamline the installation and desktop integration of Linux AppImages. Instead of manually downloading files, setting permissions via terminal, and creating desktop shortcuts, this script automates the entire process—making "portable" Linux apps feel like native installations.

## ✨ Key Features

* **Smart Input Validation:** Uses Regular Expressions to validate URLs and automatically cleans tracking parameters (e.g., `?source=website`) to prevent broken filenames.
* **Safe & Idempotent Downloads:** Checks if the file already exists to save bandwidth. Uses `curl` with fail-safes (`-fL`) to prevent downloading HTML error pages instead of real AppImages.
* **Auto Desktop Integration:** Unpacks the AppImage temporarily to extract the `.desktop` file and application icon, installing them directly to the system's application menu.
* **Dynamic Electron Detection:** Scans the AppImage's internal files. If it detects an Electron/Chromium app (like Discord, Joplin, or Slack), it automatically injects the `--no-sandbox` flag into the shortcut to prevent crashes on strict Linux distributions.
* **Self-Cleaning:** Automatically removes temporary extraction folders after installation to save disk space.

## 🖥️ Supported Distributions

The script is designed to run on **any Linux distribution** that has Bash and FUSE installed. However, it includes **automatic dependency resolution** (`curl` installation) for the following distribution families:

* **Debian/Ubuntu Family** (Uses `apt`)
  * *Includes: Ubuntu, Linux Mint, Pop!_OS, Debian, Zorin OS, Kubuntu, etc.*
* **Fedora/RHEL Family** (Uses `dnf`)
  * *Includes: Fedora, CentOS, Rocky Linux, AlmaLinux, etc.*
* **Void Linux** (Uses `xbps`)

*Note: If you are using Arch, openSUSE, or Alpine, the script will run perfectly, but you will need to install `curl` manually if it is not already on your system.*

## 📋 Prerequisites

* A Linux distribution running Bash.
* `curl` (The script will automatically attempt to install this using your system's package manager if it is missing).
* **FUSE libraries:** AppImages require `fuse` and `libfuse2` to mount and run properly. (See installation steps below if you don't have them).

## 🚀 Usage

### Step 1: Install FUSE (If not already installed)
Most desktop Linux distributions come with FUSE pre-installed. However, if you are on a minimal install, server, or Ubuntu 22.04+, you may need to install it manually:
* **Debian/Ubuntu:** `sudo apt install fuse libfuse2`
* **Fedora/RHEL:** `sudo dnf install fuse fuse-libs`
* **Arch Linux:** `sudo pacman -S fuse2`
* **Void Linux:** `sudo xbps-install -y fuse`

### Step 2: Download and Run the Script
1. Download the script to your local machine:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. Make the script executable:
   ```bash
   chmod +x install_appimage.sh
   ```

3. Run the script:
   ```bash
   ./install_appimage.sh
   ```

4. Follow the interactive prompts in the terminal:
   ```text
   Please paste the AppImage download URL: https://github.com/.../MyApp.AppImage
   Enter save directory [Press enter for default: /home/user/Applications]: 
   You choose to save AppImage in: /home/user/Applications
   
   Download complete.
   Extracting program icon and .desktop file...
   Electron app detected! Automatically adding --no-sandbox.
   
   Success! MyApp is now in your application menu.
   ```

## 🛠️ How It Works (Under the Hood)

1. **Sanitization:** The script parses the user's URL using Bash string manipulation to strip away URL queries.
2. **Acquisition:** It uses `curl` to download the binary to `~/Applications` (or a custom user directory).
3. **Extraction:** It executes the AppImage with the `--appimage-extract` flag, temporarily unpacking its internal `squashfs-root` file system.
4. **Integration:** It uses the `find` command to locate the `.desktop` and icon files, copies them to `~/.local/share/applications` and `~/.local/share/icons`.
5. **Path Rewriting:** It utilizes `sed` to dynamically rewrite the `Exec=` and `Icon=` paths inside the `.desktop` file, pointing them to the newly downloaded AppImage and extracted icon.
6. **Cleanup:** The temporary `squashfs-root` directory is forcefully removed.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```