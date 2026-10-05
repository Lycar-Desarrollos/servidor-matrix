#!/bin/bash
cd "$(dirname "$0")"

if [ ! -f .env ] || [ ! -f data/homeserver.yaml ]; then
  echo "Primero ejecuta ./setup.sh"
  exit 1
fi

source .env
docker compose up -d

echo ""
echo "================================================="
echo "  Servidor Matrix iniciado"
echo "  Navegador:          http://$SERVER_IP"
echo "  App Element (URL):  http://$SERVER_IP:8008"
echo "================================================="
