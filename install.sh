#!/usr/bin/env bash
#
# Linux installer for adbqr (Supports local execution & curl | bash)
# Usage: ./install.sh [PREFIX]   (default PREFIX=/usr/local)

set -euo pipefail

PREFIX="${1:-/usr/local}"
REPO_RAW_URL="https://raw.githubusercontent.com/neflalabs/adbqr/main"

# Detect if running from local repo or via curl/stdin
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

TMP_DIR=""
cleanup() {
    [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/bin/adbqr" ]; then
    SRC_BIN="$SCRIPT_DIR/bin/adbqr"
    SRC_BASH_COMP="$SCRIPT_DIR/completions/adbqr.bash"
    SRC_ZSH_COMP="$SCRIPT_DIR/completions/_adbqr"
    SRC_FISH_COMP="$SCRIPT_DIR/completions/adbqr.fish"
else
    echo "Downloading adbqr from GitHub repository..."
    TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/adbqr-install.XXXXXX")
    SRC_BIN="$TMP_DIR/adbqr"
    SRC_BASH_COMP="$TMP_DIR/adbqr.bash"
    SRC_ZSH_COMP="$TMP_DIR/_adbqr"
    SRC_FISH_COMP="$TMP_DIR/adbqr.fish"

    curl -fsSL "$REPO_RAW_URL/bin/adbqr" -o "$SRC_BIN" || { echo "Error: Gagal mendownload adbqr." >&2; exit 1; }
    curl -fsSL "$REPO_RAW_URL/completions/adbqr.bash" -o "$SRC_BASH_COMP" 2>/dev/null || true
    curl -fsSL "$REPO_RAW_URL/completions/_adbqr" -o "$SRC_ZSH_COMP" 2>/dev/null || true
    curl -fsSL "$REPO_RAW_URL/completions/adbqr.fish" -o "$SRC_FISH_COMP" 2>/dev/null || true
fi

DEST_BIN="$PREFIX/bin/adbqr"

echo "Installing adbqr to $DEST_BIN ..."
if [ -w "$PREFIX/bin" ] 2>/dev/null; then
    mkdir -p "$PREFIX/bin"
    install -m 0755 "$SRC_BIN" "$DEST_BIN"
else
    sudo mkdir -p "$PREFIX/bin"
    sudo install -m 0755 "$SRC_BIN" "$DEST_BIN"
fi
echo " [✓] Binary terinstall: $DEST_BIN"

# Install Bash completion
if [ -f "$SRC_BASH_COMP" ]; then
    BASH_COMP_DIR="/etc/bash_completion.d"
    if [ -d "/usr/share/bash-completion/completions" ]; then
        BASH_COMP_DIR="/usr/share/bash-completion/completions"
    fi

    if [ -w "$BASH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$BASH_COMP_DIR"
        install -m 0644 "$SRC_BASH_COMP" "$BASH_COMP_DIR/adbqr" 2>/dev/null && echo " [✓] Bash completion terinstall di $BASH_COMP_DIR/adbqr" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$BASH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_BASH_COMP" "$BASH_COMP_DIR/adbqr" 2>/dev/null && echo " [✓] Bash completion terinstall di $BASH_COMP_DIR/adbqr" || true
    fi
fi

# Install Zsh completion
if [ -f "$SRC_ZSH_COMP" ]; then
    ZSH_COMP_DIR="/usr/share/zsh/site-functions"
    if [ -w "$ZSH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$ZSH_COMP_DIR"
        install -m 0644 "$SRC_ZSH_COMP" "$ZSH_COMP_DIR/_adbqr" 2>/dev/null && echo " [✓] Zsh completion terinstall di $ZSH_COMP_DIR/_adbqr" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$ZSH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_ZSH_COMP" "$ZSH_COMP_DIR/_adbqr" 2>/dev/null && echo " [✓] Zsh completion terinstall di $ZSH_COMP_DIR/_adbqr" || true
    fi
fi

# Install Fish completion
if [ -f "${SRC_FISH_COMP:-}" ]; then
    FISH_COMP_DIR="/usr/share/fish/vendor_completions.d"
    if [ -w "$FISH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$FISH_COMP_DIR"
        install -m 0644 "$SRC_FISH_COMP" "$FISH_COMP_DIR/adbqr.fish" 2>/dev/null && echo " [✓] Fish completion terinstall di $FISH_COMP_DIR/adbqr.fish" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$FISH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_FISH_COMP" "$FISH_COMP_DIR/adbqr.fish" 2>/dev/null && echo " [✓] Fish completion terinstall di $FISH_COMP_DIR/adbqr.fish" || true
    fi
fi

echo ""
echo "Selesai! Pastikan '$PREFIX/bin' ada di PATH Anda, lalu jalankan: adbqr --help"
