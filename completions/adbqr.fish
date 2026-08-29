# Fish completion for adbqr

complete -c adbqr -f

# Modes & Actions
complete -c adbqr -s w -l wizard -d "Buka menu wizard TUI interaktif"
complete -c adbqr -s p -l pair -d "Pairing via QR Code dan auto-connect"
complete -c adbqr -s c -l connect -d "Quick-connect ke perangkat aktif di Wi-Fi"
complete -c adbqr -s u -l usb -d "Alihkan perangkat USB ke Wireless ADB port 5555"
complete -c adbqr -s m -l manual -d "Pairing manual dengan 6-digit code & IP:Port"
complete -c adbqr -s l -l list -d "Lihat riwayat perangkat tersimpan"
complete -c adbqr -s d -l diag -d "Jalankan diagnostik sistem & firewall"
complete -c adbqr -s r -l reset -d "Restart ADB server & disconnect perangkat"

# Mirroring & Streaming
complete -c adbqr -s s -l screen -d "Auto-launch scrcpy mirror screen setelah konek"
complete -c adbqr -s b -l bitrate -x -a "1M 2M 4M 6M 8M 12M 16M" -d "Set custom scrcpy video bitrate"
complete -c adbqr -l screen-off -l off -d "Matikan layar HP saat mirror screen"
complete -c adbqr -l scrcpy-args -x -d "Kirim argumen custom ke scrcpy"

# General Options
complete -c adbqr -s t -l timeout -x -a "10 30 60 120" -d "Set timeout deteksi mDNS (detik)"
complete -c adbqr -s v -l version -d "Tampilkan informasi versi & pembuat"
complete -c adbqr -s h -l help -d "Tampilkan bantuan"
