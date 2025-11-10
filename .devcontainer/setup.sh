#!/usr/bin/env bash
set -e

echo "📦 Instalando suiup..."
curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh

echo "📦 Instalando sui..."
suiup install sui -y

echo "--- Iniciando configuración interactiva de SUI Client ---"

# Este bloque (<< EOF ... EOF) alimenta las siguientes líneas
# al comando 'sui client' una por una.
sui client << EOF
y

0
EOF

sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443

echo "--- Configuración de SUI Client completada ---"

