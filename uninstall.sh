#!/usr/bin/env bash
#
# Linux uninstaller for adbqr
# Usage: ./uninstall.sh [PREFIX] [--purge] (default PREFIX=/usr/local)

set -euo pipefail

PREFIX="/usr/local"
PURGE=false

for arg in "$@"; do
    case "$arg" in
        --purge|-p)
            PURGE=true
            ;;
        -h|--help)
            echo "Usage: $0 [PREFIX] [--purge]"
            echo "  PREFIX   Installation directory prefix (default: /usr/local)"
            echo "  --purge  Also delete configuration & device history (~/.config/adbqr)"
            exit 0
            ;;
        *)
            if [[ "$arg" != -* ]]; then
                PREFIX="$arg"
            fi
            ;;
    esac
done

DEST="$PREFIX/bin/adbqr"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/adbqr"

echo "Uninstalling adbqr..."

# Remove binary
if [ -f "$DEST" ]; then
    if [ -w "$PREFIX/bin" ] && [ -w "$DEST" ]; then
        rm -f "$DEST"
    else
        sudo rm -f "$DEST"
    fi
    echo "[✓] Berhasil menghapus binary: $DEST"
else
    echo "[i] Binary $DEST tidak ditemukan."
fi

# Remove completions
for comp in /etc/bash_completion.d/adbqr /usr/share/bash-completion/completions/adbqr /usr/share/zsh/site-functions/_adbqr /usr/share/fish/vendor_completions.d/adbqr.fish; do
    if [ -f "$comp" ]; then
        if [ -w "$comp" ]; then
            rm -f "$comp" 2>/dev/null || true
        else
            sudo rm -f "$comp" 2>/dev/null || true
        fi
        echo "[✓] Berhasil menghapus completion: $comp"
    fi
done

# Purge config if requested
if [ "$PURGE" = true ]; then
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        echo "[✓] Berhasil menghapus konfigurasi & history: $CONFIG_DIR"
    fi
else
    if [ -d "$CONFIG_DIR" ]; then
        echo "[i] Konfigurasi riwayat perangkat di $CONFIG_DIR tetap dipertahankan."
        echo "    (Gunakan './uninstall.sh --purge' jika ingin menghapus seluruh riwayat perangkat)."
    fi
fi

echo "Selesai! adbqr telah di-uninstall."
