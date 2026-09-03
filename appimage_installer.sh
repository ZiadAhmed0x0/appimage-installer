#!/bin/bash


# ============================================================================
# PRINT BANNER & SYSTEM INFO
# ============================================================================
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Extract system information
OS_NAME=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
if [ -z "$OS_NAME" ]; then
    OS_NAME="Unknown Linux"
fi
KERNEL=$(uname -r)
ARCH=$(uname -m)

echo -e "${RED}"
cat <<'EOF'
 ███████ ██      ███████ ████████  ██████  ███    ██  ██████  
 ██      ██      ██         ██    ██    ██ ████   ██ ██       
 █████   ██      █████      ██    ██    ██ ██ ██  ██ ██   ███ 
 ██      ██      ██         ██    ██    ██ ██  ██ ██ ██    ██ 
 ███████ ███████ ███████    ██     ██████  ██   ████  ██████  
EOF
echo -e "${NC}"
echo -e "${YELLOW}                 [ B r e a k i n g   C h a i n s ]${NC}"
echo ""
echo -e "${CYAN}       .--.       ${NC}Version 1.1.0 | Universal AppImage Installer"
echo -e "${CYAN}      |o_o |      ${NC}\"Software is free. Run it anywhere.\""
echo -e "${CYAN}      |:_/ |      ${NC}No root, no repos, no restrictions."
echo -e "${CYAN}     //   \ \     ${NC}"
echo -e "${CYAN}    (|     | )    ${NC}${CYAN}OS:      ${NC}${WHITE}${OS_NAME}"
echo -e "${CYAN}   /'\_   _/`\    ${NC}${CYAN}Kernel:  ${NC}${WHITE}${KERNEL}"
echo -e "${CYAN}   \___)=(___/    ${NC}${CYAN}Arch:    ${NC}${WHITE}${ARCH}"
echo -e "${WHITE}------------------------------------------------------${NC}"
echo ""




# ============================================================================
# UNIVERSAL APPIMAGE INSTALLER
# ----------------------------------------------------------------------------
# Description: Downloads, installs, and integrates AppImages into the
#              Linux application menu automatically.
# ============================================================================
# ============================================================================
# 1. VALIDATE USER INPUT
#    - Check if URL is empty
#    - Check if URL matches a valid HTTP/HTTPS format
#    - Clean the URL (removes tracking parameters like ?source=...)
# ============================================================================
VALID_URL="^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]+)?(/.*)?$"

until [[ "$APP_URL" =~ $VALID_URL ]]; do
  read -p "Please paste the AppImage download URL: " APP_URL

  if [ -z "$APP_URL" ]; then
    echo "Error: No URL provided. Please try again."

  elif ! [[ "$APP_URL" =~ $VALID_URL ]]; then
    echo "Error: Invalid URL Format. Please try again."
  fi
done

echo "cleaning the URL"
CLEAN_URL="${APP_URL%%\?*}"

# ============================================================================
# 2. EXTRACT FILE NAME
# ============================================================================
echo ""
APP_NAME=$(basename "$CLEAN_URL")

# ============================================================================
# 3. SET SAVE DIRECTORY
#    - Prompt user for directory (default: ~/Applications)
#    - Create directory if it doesn't exist
# ============================================================================
DEFAULT_SAVE_DIR="$HOME/Applications"

until [ -d "$SAVE_DIR" ]; do
read -e -p "Enter save directory [Press enter for default: $DEFAULT_SAVE_DIR]: " USER_DIR
SAVE_DIR="${USER_DIR:-$DEFAULT_SAVE_DIR}"
echo "You choose to save AppImage in: $SAVE_DIR"

if ! [[ -d "$SAVE_DIR" ]]; then
    read -p "Directory does not exist, Create it now? (y|n): " create_answer
    if [[ "$create_answer" == "y" || "$create_answer" == "Y" ]]; then
        mkdir -p "$SAVE_DIR"
        echo "Directory Created"
    else
        echo "Please choose a valid directory."
    fi
fi
done

# ============================================================================
# 4. DOWNLOAD THE APPIMAGE
#    - Check if curl is installed; install if missing
#    - Check if the AppImage has already been downloaded
#    - Download using curl (fail safely on server errors)
# ============================================================================
if ! command -v curl &> /dev/null ; then
  echo "curl not found. Installing..."

# Check whats the distribution used
  # Load OS information
  if [[ -f /etc/os-release ]]; then
	. /etc/os-release
  else
	echo "Error: Cannot detect linux distribution. Please install 'curl' manually"
	exit 1
  fi


  # Check the distro ID and use the correct package manager
  if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
	sudo apt update && sudo apt install curl -y
  elif [[ "$ID" == "fedora" || "$ID_LIKE" == *"fedora"* ]]; then
	sudo dnf install curl -y
  elif [[ "$ID" == "void" ]]; then
	sudo xbps-install -y curl
  else
	echo "Unsupported distribution ($ID). Please install 'curl' manually"
    exit 1
  fi
fi

if ! [[ -f "$SAVE_DIR/$APP_NAME" ]]; then

  echo ""
  echo "Installing..."
  if curl -fL "$CLEAN_URL" -o "$SAVE_DIR"/"$APP_NAME"; then
    echo "Download complete."
  else
    echo "Error: Download failed! Please check the URL and try again."
    rm -rf "$SAVE_DIR/$APP_NAME"
   exit 1
  fi
else
  echo "AppImage already downloaded."
fi

# ============================================================================
# 5. MAKE EXECUTABLE
# ============================================================================
chmod +x "$SAVE_DIR/$APP_NAME"

# ============================================================================
# 6. EXTRACT INTERNAL CONTENTS
# ============================================================================
echo "Extracting program icon and .desktop file..."
cd "$SAVE_DIR"
./"$APP_NAME" --appimage-extract > /dev/null 2>&1


# ============================================================================
# 7. FIND AND MOVE ASSETS
#    - Search for .png/.svg icon and .desktop shortcut
#    - Remove ".AppImage" extension for a clean application title
#    - Copy icon to the system icons directory
# ============================================================================
ICON_FILE=$(find squashfs-root -maxdepth 1 \( -name "*.png" -o -name "*.svg" \) | head -n 1)
DESKTOP_FILE=$(find squashfs-root -maxdepth 1 -name "*.desktop" | head -n 1)

APP_TITLE="${APP_NAME%.AppImage}"

ICON_DIR="$HOME/.local/share/icons"
mkdir -p "$ICON_DIR"

FINAL_ICON="$ICON_DIR/$APP_TITLE"

if ! [[ -f "$FINAL_ICON" ]]; then
  cp "$ICON_FILE" "$FINAL_ICON"
else
  echo "Icon already exist"
fi

# ============================================================================
# 8. AUTO-DETECT ELECTRON APPS
#    - Check for 'chrome-sandbox' or 'resources/app.asar' files
#    - Add --no-sandbox flag if it is an Electron app
# ============================================================================
RUN_ARGS=""

if [[ -f "squashfs-root/chrome-sandbox" ]] || [[ -f "squashfs-root/resources/app.asar" ]]; then
  echo "Electron app detected! Automatically adding --no-sandbox."
  RUN_ARGS="--no-sandbox"
else
  echo "Standard AppImage detected. No special arguments needed."
fi

# ============================================================================
# 9. CREATE SHORTCUT (.DESKTOP FILE)
#     - Copy .desktop file to the applications menu directory
#     - Modify Exec path to point to the actual AppImage (with args)
#     - Modify Icon path to point to the newly extracted icon
# ============================================================================
echo "Adding the application menu..."
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

if ! [[ -e "$DESKTOP_DIR/$(basename "$DESKTOP_FILE")" ]]; then
  cp "$DESKTOP_FILE" "$DESKTOP_DIR/"

FINAL_DESKTOP="$DESKTOP_DIR/$(basename "$DESKTOP_FILE")"

sed -i "s|^Exec=.*|Exec=$SAVE_DIR/$APP_NAME $RUN_ARGS|" "$FINAL_DESKTOP"

sed -i "s|^Icon=.*|Icon=$FINAL_ICON|" "$FINAL_DESKTOP"

else
  echo ".Desktop file already exist"
fi
# ============================================================================
# 10. CLEAN UP AND FINISH
#     - Remove temporary squashfs-root folder
# ============================================================================
rm -rf "$SAVE_DIR/squashfs-root"

echo ""
echo "Success! $APP_TITLE is now in your application menu."

