🐧 Universal AppImage Installer
A robust, interactive Bash script designed to streamline the installation and desktop 
integration of Linux AppImages. Instead of manually downloading files, 
setting permissions via terminal, and creating desktop shortcuts, this script automates the 
entire process—making "portable" Linux apps feel like native installations.

✨ Key Features
Smart Input Validation: Uses Regular Expressions to validate URLs and automatically cleans tracking parameters (e.g., ?source=website) to prevent broken filenames.
Safe & Idempotent Downloads: Checks if the file already exists to save bandwidth. Uses curl with fail-safes (-fL) to prevent downloading HTML error pages instead of real AppImages.
Auto Desktop Integration: Unpacks the AppImage temporarily to extract the .desktop file and application icon, installing them directly to the system's application menu.
Dynamic Electron Detection: Scans the AppImage's internal files. If it detects an Electron/Chromium app (like Discord, Joplin, or Slack), it automatically injects the --no-sandbox flag into the shortcut to prevent crashes on strict Linux distributions.
Self-Cleaning: Automatically removes temporary extraction folders after installation to save disk space.

📋 Prerequisites
A Linux distribution running Bash.
curl (The script will automatically attempt to install this using apt if it is missing, requiring sudo privileges).

🚀 Usage
Download the script to your local machine:
git clone https://github.com/your-username/your-repo-name.gitcd your-repo-name
Make the script executable:
bash

chmod +x install_appimage.sh
Run the script:
bash

./install_appimage.sh
Follow the interactive prompts in the terminal:
text

Please paste the AppImage download URL: https://github.com/.../MyApp.AppImage
Enter save directory [Press enter for default: /home/user/Applications]: 
You choose to save AppImage in: /home/user/Applications

Download complete.
Extracting program icon and .desktop file...
Electron app detected! Automatically adding --no-sandbox.

Success! MyApp is now in your application menu

🛠️ How It Works (Under the Hood)
Sanitization: The script parses the user's URL using Bash string manipulation to strip away URL queries.
Acquisition: It uses curl to download the binary to ~/Applications (or a custom user directory).
Extraction: It executes the AppImage with the --appimage-extract flag, temporarily unpacking its internal squashfs-root file system.
Integration: It uses the find command to locate the .desktop and icon files, copies them to ~/.local/share/applications and ~/.local/share/icons.
Path Rewriting: It utilizes sed to dynamically rewrite the Exec= and Icon= paths inside the .desktop file, pointing them to the newly downloaded AppImage and extracted icon.
Cleanup: The temporary squashfs-root directory is forcefully removed.

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
