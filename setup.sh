#!/bin/bash
# Configuración inicial (solo se ejecuta UNA vez) en macOS.
# Uso:  ./setup.sh            -> detecta la IP de la Mac automáticamente
#       ./setup.sh 192.168.0.50 -> usa la IP indicada
set -e
cd "$(dirname "$0")"

if [ -f data/homeserver.yaml ]; then
  echo "Ya existe data/homeserver.yaml. El servidor ya fue configurado."
  echo "Si quieres empezar de cero: docker compose down -v && rm -rf data .env element-config.json"
  exit 1
fi

# 1. IP de la Mac
SERVER_IP="$1"
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || true)"
fi
if [ -z "$SERVER_IP" ]; then
  echo "No se pudo detectar la IP. Ejecuta: ./setup.sh <IP_DE_LA_MAC>"
  exit 1
fi
echo "IP del servidor: $SERVER_IP"

# 2. Contraseña aleatoria de PostgreSQL (se guarda en .env, que NO se sube a GitHub)
POSTGRES_PASSWORD="$(openssl rand -hex 24)"
cat > .env <<EOF
SERVER_IP=$SERVER_IP
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
EOF

# 3. Generar configuración oficial de Synapse (comando 'generate' de la documentación)
mkdir -p data
docker run --rm \
  -v "$(pwd)/data:/data" \
  -e SYNAPSE_SERVER_NAME="$SERVER_IP" \
  -e SYNAPSE_REPORT_STATS=no \
  matrixdotorg/synapse:latest generate

# 4. Cambiar SQLite por PostgreSQL y permitir registro de usuarios
perl -0pi -e "s|database:\n  name: sqlite3\n  args:\n    database: /data/homeserver.db\n|database:\n  name: psycopg2\n  args:\n    user: synapse\n    password: $POSTGRES_PASSWORD\n    database: synapse\n    host: db\n    cp_min: 5\n    cp_max: 10\n|" data/homeserver.yaml

cat >> data/homeserver.yaml <<EOF

enable_registration: true
enable_registration_without_verification: true
EOF

# 5. Configuración de Element Web
sed "s/SERVER_IP/$SERVER_IP/g" element-config.example.json > element-config.json

echo ""
echo "Configuración lista. Ahora ejecuta: ./iniciar.sh"
