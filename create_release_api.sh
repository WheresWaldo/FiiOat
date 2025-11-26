#!/bin/bash
# Script alternativo usando la API de GitHub directamente
# Requiere: curl y un token de GitHub

set -e

VERSION="v17_r38"
REPO="kuiporro/FiiOat"
ZIP_FILE="FiiOat-v17_r38-main.zip"
NOTES_FILE="RELEASE_NOTES_v17_r38.md"

echo "=========================================="
echo "  Crear Release vía API de GitHub"
echo "=========================================="
echo ""

# Verificar token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN no está configurado"
    echo ""
    echo "Para crear un token:"
    echo "1. Ve a: https://github.com/settings/tokens"
    echo "2. Genera un nuevo token con permisos 'repo'"
    echo "3. Ejecuta: export GITHUB_TOKEN=tu_token"
    echo "4. Vuelve a ejecutar este script"
    exit 1
fi

# Verificar archivos
if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE no encontrado"
    exit 1
fi

if [ ! -f "$NOTES_FILE" ]; then
    echo "ERROR: $NOTES_FILE no encontrado"
    exit 1
fi

# Leer notas
RELEASE_NOTES=$(cat "$NOTES_FILE" | jq -Rs .)

echo "Creando release..."
echo ""

# Crear el release
RELEASE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/releases" \
    -d "{
        \"tag_name\": \"$VERSION\",
        \"target_commitish\": \"main\",
        \"name\": \"FiiOat $VERSION - Stable Release\",
        \"body\": $RELEASE_NOTES,
        \"draft\": false,
        \"prerelease\": false
    }")

# Verificar respuesta
if echo "$RELEASE_RESPONSE" | grep -q "upload_url"; then
    UPLOAD_URL=$(echo "$RELEASE_RESPONSE" | jq -r .upload_url | sed 's/{?name,label}//')
    RELEASE_ID=$(echo "$RELEASE_RESPONSE" | jq -r .id)
    
    echo "✓ Release creado (ID: $RELEASE_ID)"
    echo ""
    echo "Subiendo archivo..."
    
    # Subir el ZIP
    UPLOAD_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/zip" \
        --data-binary "@$ZIP_FILE" \
        "$UPLOAD_URL?name=$ZIP_FILE")
    
    if echo "$UPLOAD_RESPONSE" | grep -q "browser_download_url"; then
        echo "✅ Archivo subido exitosamente!"
        echo ""
        echo "Release disponible en:"
        echo "https://github.com/$REPO/releases/tag/$VERSION"
    else
        echo "❌ Error al subir el archivo"
        echo "Respuesta: $UPLOAD_RESPONSE"
        exit 1
    fi
else
    echo "❌ Error al crear el release"
    echo "Respuesta: $RELEASE_RESPONSE"
    exit 1
fi

