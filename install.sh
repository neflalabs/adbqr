#!/usr/bin/env bash
#
# Linux installer & dependency helper for adbqr
# Supports local execution & one-line install (curl -fsSL ... | bash)
# Usage: ./install.sh [PREFIX]   (default PREFIX=/usr/local)

set -euo pipefail

PREFIX="${1:-/usr/local}"
REPO_RAW_URL="https://raw.githubusercontent.com/neflalabs/adbqr/main"

# Colors and styling
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
RESET='\033[0m'

# Detect if running from local repo or via curl/stdin
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

TMP_DIR=""
cleanup() {
    [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# 1. Distro & Package Manager Detection
detect_distro() {
    local distro_name="Linux"
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        distro_name=$(. /etc/os-release && echo "${PRETTY_NAME:-$NAME}")
    fi
    echo "$distro_name"
}

detect_pkg_manager() {
    local m
    for m in dnf apt pacman zypper apk; do
        if command -v "$m" >/dev/null 2>&1; then
            echo "$m"
            return 0
        fi
    done
    echo ""
}

# 2. Dependency Package Names
get_pkg_name() {
    local tool="$1"
    local mgr="$2"
    case "$tool:$mgr" in
        adb:apt)                                   echo "adb" ;;
        adb:dnf|adb:zypper|adb:pacman|adb:apk)     echo "android-tools" ;;
        qrencode:apk)                              echo "libqrencode-tools" ;;
        qrencode:*)                                echo "qrencode" ;;
        avahi-browse:dnf|avahi-browse:zypper)      echo "avahi-tools" ;;
        avahi-browse:apt)                          echo "avahi-utils" ;;
        avahi-browse:pacman|avahi-browse:apk)      echo "avahi" ;;
        scrcpy:*)                                  echo "scrcpy" ;;
        *)                                         echo "$tool" ;;
    esac
}

# Interactive Dependency Helper
check_and_install_dependencies() {
    local distro
    distro=$(detect_distro)
    local mgr
    mgr=$(detect_pkg_manager)

    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}${BOLD}                    ADBQR INSTALLER & SETUP                       ${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  Distro          : ${BOLD}$distro${RESET} ($(uname -m))"
    [ -n "$mgr" ] && echo -e "  Package Manager : ${BOLD}$mgr${RESET}"
    echo ""

    echo -e "${BOLD}Pemeriksaan Dependensi Sistem:${RESET}"

    local missing_pkgs=()

    # adb
    if command -v adb >/dev/null 2>&1; then
        echo -e "  [✓] adb          : ${GREEN}Terpasang${RESET} ($(command -v adb))"
    else
        local p
        p=$(get_pkg_name "adb" "$mgr")
        echo -e "  [✗] adb          : ${RED}Belum terpasang${RESET} (${YELLOW}paket: $p${RESET})"
        [ -n "$p" ] && missing_pkgs+=("$p")
    fi

    # qrencode
    if command -v qrencode >/dev/null 2>&1; then
        echo -e "  [✓] qrencode     : ${GREEN}Terpasang${RESET} ($(command -v qrencode))"
    else
        local p
        p=$(get_pkg_name "qrencode" "$mgr")
        echo -e "  [✗] qrencode     : ${RED}Belum terpasang${RESET} (${YELLOW}paket: $p${RESET})"
        [ -n "$p" ] && missing_pkgs+=("$p")
    fi

    # avahi-browse
    if command -v avahi-browse >/dev/null 2>&1; then
        echo -e "  [✓] avahi-browse : ${GREEN}Terpasang${RESET} ($(command -v avahi-browse))"
    else
        local p
        p=$(get_pkg_name "avahi-browse" "$mgr")
        echo -e "  [✗] avahi-browse : ${YELLOW}Belum terpasang${RESET} (disarankan untuk mDNS, ${YELLOW}paket: $p${RESET})"
        [ -n "$p" ] && missing_pkgs+=("$p")
    fi

    # scrcpy (optional)
    local missing_scrcpy=false
    if command -v scrcpy >/dev/null 2>&1; then
        echo -e "  [✓] scrcpy       : ${GREEN}Terpasang${RESET} (opsional - screen mirroring)"
    else
        echo -e "  [-] scrcpy       : ${DIM}Tidak terpasang${RESET} (opsional - untuk fitur 'adbqr -s' mirror screen)"
        missing_scrcpy=true
    fi
    echo ""

    # Check if interactive terminal input is available
    if [ -t 0 ] || [ -e /dev/tty ]; then
        if [ ${#missing_pkgs[@]} -gt 0 ] && [ -n "$mgr" ]; then
            local cmd=""
            case "$mgr" in
                dnf)    cmd="sudo dnf install -y ${missing_pkgs[*]}" ;;
                apt)    cmd="sudo apt update && sudo apt install -y ${missing_pkgs[*]}" ;;
                pacman) cmd="sudo pacman -S --noconfirm ${missing_pkgs[*]}" ;;
                zypper) cmd="sudo zypper install -y ${missing_pkgs[*]}" ;;
                apk)    cmd="sudo apk add ${missing_pkgs[*]}" ;;
            esac

            echo -e "${YELLOW}Dependensi yang belum lengkap:${RESET} ${BOLD}${missing_pkgs[*]}${RESET}"
            echo -ne "${BOLD}Ingin menginstall paket di atas sekarang? [Y/n]: ${RESET}"
            local ans=""
            if [ -e /dev/tty ]; then
                read -r ans </dev/tty || true
            else
                read -r ans || true
            fi
            ans="${ans:-y}"

            if [[ "$ans" =~ ^[Yy]$ ]]; then
                echo -e "Menjalankan: ${CYAN}$cmd${RESET}"
                eval "$cmd" || echo -e "${YELLOW}[!] Gagal otomatis menginstall. Anda dapat menginstall manual nanti.${RESET}"
                echo ""
            fi
        fi

        if [ "$missing_scrcpy" = true ] && [ -n "$mgr" ]; then
            echo -ne "${BOLD}Ingin menginstall scrcpy (mirror layar HP) sekarang? [y/N]: ${RESET}"
            local ans_scrcpy=""
            if [ -e /dev/tty ]; then
                read -r ans_scrcpy </dev/tty || true
            else
                read -r ans_scrcpy || true
            fi
            if [[ "$ans_scrcpy" =~ ^[Yy]$ ]]; then
                local scrcpy_cmd="sudo $mgr install -y scrcpy"
                [ "$mgr" = "pacman" ] && scrcpy_cmd="sudo pacman -S --noconfirm scrcpy"
                [ "$mgr" = "apt" ] && scrcpy_cmd="sudo apt install -y scrcpy"
                echo -e "Menjalankan: ${CYAN}$scrcpy_cmd${RESET}"
                eval "$scrcpy_cmd" || true
                echo ""
            fi
        fi
    fi
}

check_and_install_dependencies

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/bin/adbqr" ]; then
    SRC_BIN="$SCRIPT_DIR/bin/adbqr"
    SRC_BASH_COMP="$SCRIPT_DIR/completions/adbqr.bash"
    SRC_ZSH_COMP="$SCRIPT_DIR/completions/_adbqr"
    SRC_FISH_COMP="$SCRIPT_DIR/completions/adbqr.fish"
else
    echo "Mengunduh adbqr dari GitHub repository..."
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

echo "Memasang adbqr ke $DEST_BIN ..."
if mkdir -p "$PREFIX/bin" 2>/dev/null && [ -w "$PREFIX/bin" ]; then
    install -m 0755 "$SRC_BIN" "$DEST_BIN"
elif command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p "$PREFIX/bin"
    sudo install -m 0755 "$SRC_BIN" "$DEST_BIN"
else
    mkdir -p "$PREFIX/bin"
    install -m 0755 "$SRC_BIN" "$DEST_BIN"
fi
echo -e "  [✓] Binary terinstall : ${GREEN}$DEST_BIN${RESET}"

# Install Bash completion
if [ -f "$SRC_BASH_COMP" ]; then
    BASH_COMP_DIR="/usr/share/bash-completion/completions"
    [ ! -d "$BASH_COMP_DIR" ] && [ -d "/etc/bash_completion.d" ] && BASH_COMP_DIR="/etc/bash_completion.d"

    if [ -w "$BASH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$BASH_COMP_DIR"
        install -m 0644 "$SRC_BASH_COMP" "$BASH_COMP_DIR/adbqr" 2>/dev/null && echo -e "  [✓] Bash completion   : ${GREEN}$BASH_COMP_DIR/adbqr${RESET}" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$BASH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_BASH_COMP" "$BASH_COMP_DIR/adbqr" 2>/dev/null && echo -e "  [✓] Bash completion   : ${GREEN}$BASH_COMP_DIR/adbqr${RESET}" || true
    fi
fi

# Install Zsh completion
if [ -f "$SRC_ZSH_COMP" ]; then
    ZSH_COMP_DIR="/usr/share/zsh/site-functions"
    if [ -w "$ZSH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$ZSH_COMP_DIR"
        install -m 0644 "$SRC_ZSH_COMP" "$ZSH_COMP_DIR/_adbqr" 2>/dev/null && echo -e "  [✓] Zsh completion    : ${GREEN}$ZSH_COMP_DIR/_adbqr${RESET}" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$ZSH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_ZSH_COMP" "$ZSH_COMP_DIR/_adbqr" 2>/dev/null && echo -e "  [✓] Zsh completion    : ${GREEN}$ZSH_COMP_DIR/_adbqr${RESET}" || true
    fi
fi

# Install Fish completion
if [ -f "${SRC_FISH_COMP:-}" ]; then
    FISH_COMP_DIR="/usr/share/fish/vendor_completions.d"
    if [ -w "$FISH_COMP_DIR" ] 2>/dev/null; then
        mkdir -p "$FISH_COMP_DIR"
        install -m 0644 "$SRC_FISH_COMP" "$FISH_COMP_DIR/adbqr.fish" 2>/dev/null && echo -e "  [✓] Fish completion   : ${GREEN}$FISH_COMP_DIR/adbqr.fish${RESET}" || true
    elif command -v sudo >/dev/null 2>&1; then
        sudo mkdir -p "$FISH_COMP_DIR" 2>/dev/null || true
        sudo install -m 0644 "$SRC_FISH_COMP" "$FISH_COMP_DIR/adbqr.fish" 2>/dev/null && echo -e "  [✓] Fish completion   : ${GREEN}$FISH_COMP_DIR/adbqr.fish${RESET}" || true
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}[✓] Instalasi adbqr selesai!${RESET}"
echo -e "Pastikan ${CYAN}$PREFIX/bin${RESET} ada di PATH Anda, lalu jalankan:"
echo -e "  ${BOLD}adbqr -w${RESET}      (Buka Menu Wizard Interaktif)"
echo -e "  ${BOLD}adbqr -p${RESET}      (Scan QR Code Pairing Android)"
echo -e "  ${BOLD}adbqr --help${RESET}  (Lihat semua opsi)"

