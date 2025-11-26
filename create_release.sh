#!/bin/bash
# Script para crear un release en GitHub
# Requiere: curl, jq (opcional), y un token de GitHub

set -e

VERSION="v17_r38"
REPO="kuiporro/FiiOat"
ZIP_FILE="FiiOat-v17_r38-main.zip"
NOTES_FILE="RELEASE_NOTES_v17_r38.md"

echo "=========================================="
echo "  Crear Release en GitHub"
echo "=========================================="
echo ""
echo "Versión: $VERSION"
echo "Repositorio: $REPO"
echo ""

# Verificar que el ZIP existe
if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE no encontrado"
    echo "Ejecuta primero: ./build_module.sh"
    exit 1
fi

# Verificar que las notas existen
if [ ! -f "$NOTES_FILE" ]; then
    echo "ERROR: $NOTES_FILE no encontrado"
    exit 1
fi

# Leer las notas de release
RELEASE_NOTES=$(cat "$NOTES_FILE")

echo "Archivos listos:"
echo "  - $ZIP_FILE ($(du -h "$ZIP_FILE" | cut -f1))"
echo "  - $NOTES_FILE"
echo ""

# Verificar si hay gh CLI
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI (gh) encontrado"
    echo ""
    echo "Creando release con GitHub CLI..."
    echo ""
    
    gh release create "$VERSION" \
        "$ZIP_FILE" \
        --title "FiiOat $VERSION - Stable Release" \
        --notes-file "$NOTES_FILE" \
        --target main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Release creado exitosamente!"
        echo ""
        echo "Ver release en: https://github.com/$REPO/releases/tag/$VERSION"
    else
        echo ""
        echo "❌ Error al crear el release"
        exit 1
    fi
else
    echo "GitHub CLI (gh) no encontrado"
    echo ""
    echo "Opciones para crear el release:"
    echo ""
    echo "1. Instalar GitHub CLI:"
    echo "   - Arch: sudo pacman -S github-cli"
    echo "   - Ubuntu/Debian: sudo apt install gh"
    echo "   - Luego: gh auth login"
    echo ""
    echo "2. Crear release manualmente:"
    echo "   - Ve a: https://github.com/$REPO/releases/new"
    echo "   - Tag: $VERSION"
    echo "   - Title: FiiOat $VERSION - Stable Release"
    echo "   - Description: Copia el contenido de $NOTES_FILE"
    echo "   - Attach: $ZIP_FILE"
    echo "   - Publicar release"
    echo ""
    echo "3. Usar API de GitHub (requiere token):"
    echo "   export GITHUB_TOKEN=tu_token"
    echo "   ./create_release_api.sh"
    echo ""
    echo "Archivos listos para subir:"
    echo "  - $ZIP_FILE"
    echo "  - $NOTES_FILE (para las notas del release)"
fi

