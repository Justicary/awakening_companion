#!/usr/bin/env bash
# =========================================================================
# Awakening: Companion - Script de Empaquetado para Producción
# =========================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${REPO_DIR}/dist"
ADDON_NAME="AwakeningCompanion"

# Extraer versión del .toc
VERSION=$(grep -m1 "## Version:" "${REPO_DIR}/${ADDON_NAME}.toc" | awk '{print $3}' | tr -d '\r')
if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
fi

ZIP_NAME="${ADDON_NAME}-v${VERSION}.zip"
TEMP_DIR="${DIST_DIR}/temp/${ADDON_NAME}"

echo "=================================================="
echo " Empaquetando ${ADDON_NAME} v${VERSION}"
echo "=================================================="

# Limpiar dist anterior
rm -rf "${DIST_DIR}"
mkdir -p "${TEMP_DIR}"

# Copiar solo los archivos esenciales para el cliente de WoW
echo "-> Copiando archivos de juego..."
cp "${REPO_DIR}/${ADDON_NAME}.toc" "${TEMP_DIR}/"
cp -r "${REPO_DIR}/Core" "${TEMP_DIR}/"
cp -r "${REPO_DIR}/Data" "${TEMP_DIR}/"
cp -r "${REPO_DIR}/Media" "${TEMP_DIR}/"
cp -r "${REPO_DIR}/Modules" "${TEMP_DIR}/"

# Limpiar posibles archivos basura de SO o Python dentro de las carpetas
find "${TEMP_DIR}" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "${TEMP_DIR}" -type f -name ".DS_Store" -delete 2>/dev/null || true
find "${TEMP_DIR}" -type f -name "Thumbs.db" -delete 2>/dev/null || true
find "${TEMP_DIR}" -type f -name "*.swp" -delete 2>/dev/null || true

# Crear archivo ZIP listo para descomprimir en Interface/AddOns/
echo "-> Generando archivo ZIP: dist/${ZIP_NAME}..."
cd "${DIST_DIR}/temp"
if command -v zip >/dev/null 2>&1; then
    zip -r -q "${DIST_DIR}/${ZIP_NAME}" "${ADDON_NAME}"
elif command -v python3 >/dev/null 2>&1; then
    python3 -c "
import sys, os, zipfile
zip_path = sys.argv[1]
source_dir = sys.argv[2]
base_dir = os.path.dirname(os.path.abspath(source_dir))
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, base_dir)
            zf.write(full_path, rel_path)
" "${DIST_DIR}/${ZIP_NAME}" "${ADDON_NAME}"
else
    echo "ERROR: Se requiere 'zip' o 'python3' para empaquetar el release."
    exit 1
fi

# Limpiar temporal
rm -rf "${DIST_DIR}/temp"

echo "=================================================="
echo " [OK] Paquete de produccion creado con exito:"
echo " ${DIST_DIR}/${ZIP_NAME}"
echo "=================================================="
