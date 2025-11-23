#!/bin/sh
set -e

. "zsh/.config/zsh/functions.sh"

# ==============================================================================
# 1. Bootstrap Gum (The Glamour)
# ==============================================================================

echo "✨ Bootstrapping Gum..."

# Get the latest version number
VERSION=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# Detect OS and Arch
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux) OS="Linux" ;;
    Darwin) OS="Darwin" ;; # macOS support just in case
    *) echo "Unsupported OS"; exit 1 ;;
esac

case "$ARCH" in
    x86_64|amd64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "Unsupported Arch"; exit 1 ;;
esac

FILENAME="gum_${VERSION}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/charmbracelet/gum/releases/download/v${VERSION}/${FILENAME}"

# Download and Extract
curl -L -s "$URL" | tar -xz --strip-components=1 --wildcards '*/gum' 2>/dev/null || \
curl -L -s "$URL" | tar -xz --strip-components=1 '*/gum'

# ==============================================================================
# 2. Welcome & Detection
# ==============================================================================

./gum style \
    --border double \
    --margin "1" \
    --padding "1" \
    --border-foreground 212 \
    "Welcome to my Dotfiles" \
    "Select your setup below"

# Detect Distribution
DISTRIBUTION=$(distro)

if [ "$DISTRIBUTION" = "unknown" ]; then
    ./gum style --foreground 196 "⚠️  Unsupported distribution detected. Proceeding with caution."
    # cleanup function
    exit 1
fi

# ==============================================================================
# 3. Selection
# ==============================================================================

# Select Tools
echo "📦 Select tools to install:"
TOOLS=$(./gum choose --no-limit --selected "zsh,stow,git,neovim,bat,fzf,eza,starship,zoxide,pnpm" "zsh" "stow" "git" "neovim" "bat" "fzf" "eza" "starship" "zoxide" "ghostty" "pnpm" "uv")

# Select Configs
echo "⚙️  Select configurations to stow:"
CONFIGS=$(./gum choose --no-limit --selected "zsh,git,ghostty,zed" "zsh" "git" "ghostty" "zed")

# Confirm
./gum confirm "Ready to install selected items?" || exit 0

# ==============================================================================
# 4. Installation
# ==============================================================================

# Helper to check if a tool was selected
has_tool() { echo "$TOOLS" | grep -q "$1"; }

install_arch() {
    PKG_LIST=""
    has_tool "zsh" && PKG_LIST="$PKG_LIST zsh"
    has_tool "stow" && PKG_LIST="$PKG_LIST stow"
    has_tool "git" && PKG_LIST="$PKG_LIST git"
    has_tool "neovim" && PKG_LIST="$PKG_LIST neovim"
    has_tool "bat" && PKG_LIST="$PKG_LIST bat"
    has_tool "fzf" && PKG_LIST="$PKG_LIST fzf"
    has_tool "eza" && PKG_LIST="$PKG_LIST eza"
    has_tool "starship" && PKG_LIST="$PKG_LIST starship"
    has_tool "zoxide" && PKG_LIST="$PKG_LIST zoxide"
    has_tool "ghostty" && PKG_LIST="$PKG_LIST ghostty"
    has_tool "pnpm" && PKG_LIST="$PKG_LIST pnpm"
    
    if [ -n "$PKG_LIST" ]; then
        ./gum spin --title "Installing Arch packages..." -- sudo pacman -S --noconfirm $PKG_LIST
    fi
}

install_debian() {
    sudo apt update
    PKG_LIST=""
    has_tool "zsh" && PKG_LIST="$PKG_LIST zsh"
    has_tool "stow" && PKG_LIST="$PKG_LIST stow"
    has_tool "git" && PKG_LIST="$PKG_LIST git"
    has_tool "neovim" && PKG_LIST="$PKG_LIST neovim"
    has_tool "bat" && PKG_LIST="$PKG_LIST bat"
    has_tool "fzf" && PKG_LIST="$PKG_LIST fzf"
    has_tool "eza" && PKG_LIST="$PKG_LIST eza"
    has_tool "pnpm" && PKG_LIST="$PKG_LIST pnpm"
    
    if [ -n "$PKG_LIST" ]; then
        ./gum spin --title "Installing Debian packages..." -- sudo apt install -y $PKG_LIST
    fi
}

# Run Package Manager
if [ "$DISTRO_FAMILY" = "arch" ]; then
    install_arch
elif [ "$DISTRO_FAMILY" = "debian" ]; then
    install_debian
fi

# Manual Installs (Cross-distro or where repos fail)
if has_tool "starship" && ! command -v starship >/dev/null; then
    ./gum spin --title "Installing Starship..." -- sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y"
fi

if has_tool "zoxide" && ! command -v zoxide >/dev/null; then
    ./gum spin --title "Installing Zoxide..." -- sh -c "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
fi

if has_tool "uv"; then
    ./gum spin --title "Installing uv..." -- sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# ==============================================================================
# 5. Configuration (Stow)
# ==============================================================================

if [ -n "$CONFIGS" ]; then
    # Ensure stow is installed if we are stowing
    if ! command -v stow >/dev/null; then
        ./gum style --foreground 196 "Stow is missing! Cannot apply configurations."
    else
        echo "🔗 Stowing configurations..."
        # Convert newlines to spaces for stow command
        CONFIG_LIST=$(echo "$CONFIGS" | tr '\n' ' ')
        ./gum spin --title "Linking dotfiles..." -- stow $CONFIG_LIST
    fi
fi

# ==============================================================================
# 6. Post-Install Fixes
# ==============================================================================

# Generate zshrc.local for distro-specific aliases
LOCAL_CONFIG="$HOME/.config/zsh/zshrc.local"
./gum spin --title "Generating local config..." -- sleep 0.5

echo "# Generated by install.sh on $(date)" > "$LOCAL_CONFIG"

if [ "$DISTRO_FAMILY" = "debian" ]; then
    echo "alias cat='batcat'" >> "$LOCAL_CONFIG"
    echo "alias fd='fdfind'" >> "$LOCAL_CONFIG"
elif [ "$DISTRO_FAMILY" = "arch" ]; then
    echo "alias cat='bat'" >> "$LOCAL_CONFIG"
fi

# Change Shell
if has_tool "zsh" && [ "$SHELL" != "$(which zsh)" ]; then
    if ./gum confirm "Change default shell to zsh?"; then
        chsh -s $(which zsh)
    fi
fi

./gum style \
    --border double \
    --margin "1" \
    --padding "1" \
    --border-foreground 212 \
    "Installation Complete!" \
    "Please restart your shell."
