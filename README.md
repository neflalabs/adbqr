# adbqr 📱⚡

[![CI](https://github.com/neflalabs/adbqr/actions/workflows/ci.yml/badge.svg)](https://github.com/neflalabs/adbqr/actions/workflows/ci.yml)
[![License: GPL v2](https://img.shields.io/badge/License-GPLv2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

Tool CLI & Wizard Linux untuk menghubungkan **Android Wireless Debugging** (Android 11 – 16+) menggunakan **QR Code** di terminal secara instan tanpa perlu Android Studio atau mengetik IP & port pairing secara manual.

---

## ✨ Fitur Utama

- ⚡ **Deteksi Instan (<100ms)**: Menggunakan streaming event mDNS Avahi secara real-time.
- 📶 **Deteksi Wi-Fi Aktif**: Menampilkan nama SSID Wi-Fi yang sedang terhubung di laptop.
- 🔄 **Auto-Connect**: Otomatis mencari port debugging dan langsung menghubungkan perangkat setelah pairing sukses.
- 🖥️ **Integrasi scrcpy (`-s` / `--screen`)**: Otomatis membuka mirror layar HP segera setelah terhubung.
- 🔔 **Notifikasi Desktop**: Mengirim notifikasi sistem saat HP berhasil tersambung.
- 📋 **Integrasi Clipboard**: Perintah `adb connect` otomatis disalin ke clipboard Wayland (`wl-copy`) / X11 (`xclip`).
- 🔌 **1-Click USB to Wireless**: Beralih dari mode kabel USB ke Wireless ADB (`adb tcpip 5555`) dalam satu langkah.
- 📜 **Device History**: Menyimpan riwayat IP & perangkat yang pernah terhubung di `~/.config/adbqr/`.
- ⌨️ **Shell Auto-Completion**: Dukungan autocomplete TAB untuk **Bash** dan **Zsh**.
- 🖼️ **Dukungan Terminal Luas**: Rendering gambar beresolusi tinggi di terminal Ghostty/Kitty/WezTerm serta fallback ANSI UTF-8 untuk terminal standar.

---

## 📦 Dependensi

```sh
# Fedora
sudo dnf install android-tools qrencode avahi-tools

# Debian / Ubuntu
sudo apt install adb qrencode avahi-utils

# Arch Linux
sudo pacman -S android-tools qrencode avahi
```

*(Opsional)* Pasang `scrcpy` untuk fitur screen mirroring: `sudo dnf install scrcpy` / `sudo apt install scrcpy`.

---

## 🚀 Instalasi & Hapus

### One-line Install (Langsung dari GitHub)
```sh
curl -fsSL https://raw.githubusercontent.com/neflalabs/adbqr/main/install.sh | bash
```

### Atau via Clone Repo Manual
```sh
# Install ke /usr/local/bin (beserta shell completions)
sudo ./install.sh

# Uninstall
sudo ./uninstall.sh

# Uninstall & hapus seluruh riwayat perangkat (~/.config/adbqr)
sudo ./uninstall.sh --purge
```

---

## 💻 Penggunaan

```sh
adbqr                 # Scan QR code & auto-connect (Mode default)
adbqr -s              # Konek wireless & langsung buka mirror scrcpy
adbqr --wizard        # Menu TUI Wizard interaktif
adbqr --connect       # Hubungkan ke perangkat aktif di Wi-Fi
adbqr --usb           # Ubah koneksi kabel USB ke Wi-Fi (port 5555)
adbqr --manual        # Pairing manual dengan 6-digit code & IP:Port
adbqr --list          # Lihat riwayat perangkat tersimpan
adbqr --diag          # Diagnostik sistem, firewall, dan status mDNS
adbqr --reset         # Putus koneksi & restart ADB server
adbqr --help          # Bantuan & opsi lengkap
```

### 📱 Langkah di HP Android:
1. Buka **Settings** > **Developer options**.
2. Aktifkan **Wireless debugging** lalu ketuk menu tersebut.
3. Pilih **Pair device with QR code** dan arahkan kamera HP ke QR di terminal.

---

## ⚠️ Catatan Wi-Fi Publik / Isolasi AP
Jika berada di Wi-Fi publik (kampus, kafe, kantor) yang mengaktifkan *AP Isolation*, mDNS antar perangkat akan diblokir oleh router. Gunakan **Hotspot HP** atau opsi **1-Click USB to Wireless** (`adbqr --usb`).

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **GNU General Public License v2.0 (GPL-2.0)**.


