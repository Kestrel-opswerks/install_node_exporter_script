#!/bin/bash

URL="$1"

if [ -z "$1" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

TAR_FILE=$(basename "$URL")
EXTRACT_DIR="${TAR_FILE%.tar.gz}"

wget -q --show-progress "$URL"

tar -xzf "$TAR_FILE"

cd "$EXTRACT_DIR"

sudo cp node_exporter /usr/local/bin 

sudo useradd --no-create-home --shell /bin/false node_exporter 

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service >/dev/null
[Unit] 
Description=Node Exporter 
Wants=network-online.target 
After=network-online.target 

[Service] 
User=node_exporter  
Group=node_exporter 
Type=simple 
ExecStart=/usr/local/bin/node_exporter 

[Install] 
WantedBy=multi-user.target 
EOF


sudo systemctl daemon-reload 

sudo systemctl enable --now node_exporter 

SERVICE="node_exporter"
if systemctl is-active --quiet "$SERVICE"; then
  echo "$SERVICE is running."
else
  echo "$SERVICE is not running."
fi
