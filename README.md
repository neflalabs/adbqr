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
- 🔌 **1-Click USB to Wireless**: Beralih dari mode kabel USB ke Wireless ADB (`adb tcpip 5555`) dalam satu langkah.
- 📜 **Device History**: Menyimpan riwayat IP & perangkat yang pernah terhubung di `~/.config/adbqr/`.
- 🔄 **Self-Updater**: Perbarui tool dan auto-completions langsung dari GitHub dengan `adbqr update`.
- ⌨️ **Shell Auto-Completion**: Dukungan autocomplete TAB untuk **Bash**, **Zsh**, dan **Fish**.
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

### One-line Uninstall
```sh
# Uninstall standar
curl -fsSL https://raw.githubusercontent.com/neflalabs/adbqr/main/uninstall.sh | bash

# Uninstall beserta hapus riwayat & config (~/.config/adbqr)
curl -fsSL https://raw.githubusercontent.com/neflalabs/adbqr/main/uninstall.sh | bash -s -- --purge
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
adbqr                 # Menampilkan menu bantuan (help)
adbqr -p              # Scan QR code & auto-connect
adbqr -w              # Menu TUI Wizard interaktif
adbqr -c              # Quick-connect ke perangkat aktif di Wi-Fi
adbqr -u              # Ubah koneksi kabel USB ke Wi-Fi (port 5555)
adbqr -s              # Konek & otomatis buka mirror scrcpy (Smooth Wi-Fi preset)
adbqr -c -s -b 2M     # Quick connect + scrcpy bitrate 2M
adbqr -s --screen-off # Konek + scrcpy dengan layar HP mati (--turn-screen-off)
adbqr -s -- -b 2M --stay-awake # Teruskan argumen mentah ke scrcpy via '--'
adbqr -m              # Pairing manual dengan 6-digit code & IP:Port
adbqr -l              # Lihat riwayat perangkat tersimpan
adbqr -d              # Diagnostik sistem, firewall, dan status mDNS
adbqr -r              # Putus koneksi & restart ADB server
adbqr update          # Periksa & unduh pembaruan adbqr dari GitHub
adbqr -v              # Tampilkan versi & info pembuat
```

### 📱 Langkah di HP Android:
1. Buka **Settings** > **Developer options**.
2. Aktifkan **Wireless debugging** lalu ketuk menu tersebut.
3. Pilih **Pair device with QR code** dan arahkan kamera HP ke QR di terminal.

### ⚡ Mirroring Lancar di Wi-Fi (`scrcpy`)
Secara default saat menggunakan flag `-s`, `adbqr` menerapkan tuning optimal untuk koneksi nirkabel (jitter buffer 50ms, cap 60 FPS, max resolution 1280px) agar streaming mulus tanpa patah-patah / micro-stutters. Anda juga bisa mengatur default argumen melalui environment variable:
```sh
export SCRCPY_ARGS="-b 4M --video-buffer=50 --turn-screen-off"
```

---

## ⚠️ Catatan Wi-Fi Publik / Isolasi AP
Jika berada di Wi-Fi publik (kampus, kafe, kantor) yang mengaktifkan *AP Isolation*, mDNS antar perangkat akan diblokir oleh router. Gunakan **Hotspot HP** atau opsi **1-Click USB to Wireless** (`adbqr --usb`).

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **GNU General Public License v2.0 (GPL-2.0)**.


