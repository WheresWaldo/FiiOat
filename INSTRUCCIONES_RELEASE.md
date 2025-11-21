# Instrucciones para Crear el Release v17_r38

## Opción 1: Usando GitHub CLI (Recomendado)

### Prerequisitos:
```bash
# Instalar GitHub CLI (si no lo tienes)
# Arch Linux:
sudo pacman -S github-cli

# Ubuntu/Debian:
sudo apt install gh

# Autenticarse
gh auth login
```

### Crear el Release:
```bash
cd /home/kuiper/Escritorio/jm21_fw/modules/FiiOat
./create_release.sh
```

El script automáticamente:
- Verifica que el ZIP existe
- Crea el release con las notas
- Sube el archivo ZIP

## Opción 2: Manualmente desde GitHub Web

1. **Ve a la página de releases**:
   https://github.com/kuiporro/FiiOat/releases/new

2. **Completa el formulario**:
   - **Tag**: `v17_r38` (debe coincidir exactamente)
   - **Target**: `main`
   - **Release title**: `FiiOat v17_r38 - Stable Release`
   - **Description**: Copia el contenido completo de `RELEASE_NOTES_v17_r38.md`

3. **Adjunta el archivo**:
   - Haz clic en "Attach binaries"
   - Selecciona: `FiiOat-v17_r38-main.zip`

4. **Publica**:
   - Asegúrate de que NO esté marcado como "Pre-release"
   - Haz clic en "Publish release"

## Opción 3: Usando la API de GitHub

### Prerequisitos:
```bash
# Necesitas un token de GitHub con permisos 'repo'
# Crear token: https://github.com/settings/tokens
export GITHUB_TOKEN=tu_token_aqui
```

### Crear el Release:
```bash
cd /home/kuiper/Escritorio/jm21_fw/modules/FiiOat
./create_release_api.sh
```

## Verificación

Después de crear el release, verifica:

1. **URL del Release**: https://github.com/kuiporro/FiiOat/releases/tag/v17_r38
2. **Archivo ZIP**: Debe estar disponible para descarga
3. **Notas**: Deben mostrarse correctamente formateadas

## Contenido del Release

- **Tag**: v17_r38
- **Título**: FiiOat v17_r38 - Stable Release
- **Archivo**: FiiOat-v17_r38-main.zip
- **Notas**: Contenido de RELEASE_NOTES_v17_r38.md

## Notas Importantes

- El tag `v17_r38` ya existe en el repositorio (fue creado anteriormente)
- Si GitHub te pregunta si quieres usar el tag existente, selecciona "Use existing tag"
- Asegúrate de que el release esté marcado como "Latest release" si es la versión más reciente

