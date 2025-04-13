#!/bin/bash

https://raw.githubusercontent.com/MasPras0/scku/main/install/nob.zip
unzip nob.zip
chmod +x /root/nob/install.sh
/root/nob/./install.sh
systemctl restart noobzvpns
rm -rf nob
