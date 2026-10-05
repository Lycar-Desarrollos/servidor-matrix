#!/bin/bash
# Script para detener el Servidor Matrix en macOS / Linux
echo "Deteniendo Servidor Matrix Synapse..."
docker compose down
echo "Servidor detenido con éxito."
