#!/bin/bash

# File konfigurasi SSH
sshd_config="/etc/ssh/sshd_config"

# Baris yang akan ditambahkan
cipher_line="Ciphers aes128-ctr,aes192-ctr,aes256-ctr"

# Cek apakah baris sudah ada di dalam file
if grep -Fxq "$cipher_line" $sshd_config
then
    echo "Baris cipher sudah ada di dalam $sshd_config, tidak perlu ditambahkan."
else
    echo "$cipher_line" >> $sshd_config
    echo "Baris cipher telah ditambahkan ke $sshd_config."
fi
systemctl reload ssh sshd
systemctl stop ws ws-ovpn
file_path="/etc/handeling"

# Cek apakah file ada
if [ ! -f "$file_path" ]; then
    # Jika file tidak ada, buat file dan isi dengan dua baris
    echo -e "HunterTunnel Server Connected\nGreen" | sudo tee "$file_path" > /dev/null
    echo "File '$file_path' berhasil dibuat."
else
    # Jika file ada, cek apakah isinya kosong
    if [ ! -s "$file_path" ]; then
        # Jika file ada tetapi kosong, isi dengan dua baris
        echo -e "HunterTunnel Server Connected\nGreen" | sudo tee "$file_path" > /dev/null
        echo "File '$file_path' kosong dan telah diisi."
    else
        # Jika file ada dan berisi data, tidak lakukan apapun
        echo "File '$file_path' sudah ada dan berisi data."
    fi
fi

if ! command -v python3 &> /dev/null; then
    echo "Python 3 belum terinstal. Menginstal Python 3 sekarang..."
    sudo apt update
    sudo apt install python3 -y
else
    echo "Python 3 sudah terinstal."
fi

# Cek apakah python3-pip terinstal
if ! command -v pip3 &> /dev/null; then
    echo "pip3 belum terinstal. Menginstal pip3 sekarang..."
    sudo apt update
    sudo apt install python3-pip -y
else
    echo "pip3 sudah terinstal."
fi

# Cek dan install requests pada Python 3
if ! dpkg -l | grep -q python3-requests; then
    echo "Library 'requests' belum terinstal, menginstal sekarang..."
    sudo apt install python3-requests -y
else
    echo "Library 'requests' sudah terinstal untuk Python 3."
fi

wget -O /usr/local/bin/ws.py "https://raw.githubusercontent.com/supremo198/tunnel/main/fodder/websocket/ws.py"
chmod +x /usr/local/bin/ws.py

# Installing Service
cat >/etc/systemd/system/ws.service <<EOF
[Unit]
Description=Python Proxy HunterTunnel
Documentation=https://t.me/RozTun
After=network.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 -O /usr/local/bin/ws.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ws.service
systemctl start ws.service
systemctl restart ws.service

wget -O /usr/local/bin/ws-ovpn "https://raw.githubusercontent.com/supremo198/tunnel/main/fodder/websocket/ws.py"
chmod +x /usr/local/bin/ws-ovpn

# Installing Service
cat > /etc/systemd/system/ws-ovpn.service <<EOF
[Unit]
Description=Proxy Mod By HunterTunnel
Documentation=https://t.me/RozTun
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-ovpn 2086
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ws-ovpn
systemctl start ws-ovpn


rm insshws.*
