# Guía de Instalación y Prueba - FiiOat v17_r38

## ⚠️ IMPORTANTE: Versión NO PROBADA

Esta versión (v17_r38) **NO ha sido probada** y está en el branch `v17_r38-unstable`. Úsala bajo tu propio riesgo.

## Requisitos Previos

- FiiO JM21 o M21 con firmware 1.0.8 (o versión anterior para compatibilidad)
- Magisk v20.4 o superior instalado
- Acceso root funcionando
- Conexión a Internet para descargar el módulo

## Paso 1: Descargar el Módulo

### Opción A: Descargar desde GitHub (Recomendado)

1. Ve a: https://github.com/kuiporro/FiiOat
2. Haz clic en el botón **"Code"** (verde) y selecciona **"Download ZIP"**
3. O descarga directamente el branch `v17_r38-unstable`:
   - Ve a: https://github.com/kuiporro/FiiOat/tree/v17_r38-unstable
   - Haz clic en **"Code"** → **"Download ZIP"**

### Opción B: Clonar el Repositorio (Para Desarrolladores)

```bash
git clone https://github.com/kuiporro/FiiOat.git
cd FiiOat
git checkout v17_r38-unstable
```

## Paso 2: Preparar el Módulo para Instalación

### Opción A: Usar el Script de Build (Recomendado)

Si clonaste el repositorio o tienes acceso a los archivos fuente:

1. Abre una terminal en la carpeta del módulo
2. Ejecuta el script de build:
   ```bash
   chmod +x build_module.sh
   ./build_module.sh
   ```
3. El script creará automáticamente el ZIP con el nombre correcto: `FiiOat-v17_r38-v17_r38-unstable.zip`

### Opción B: Crear el ZIP Manualmente

Si descargaste el código fuente y necesitas crear el ZIP manualmente:

1. Abre una terminal en la carpeta del módulo
2. Usa `zip`, `7z` o `python3`:

   **Con zip:**
   ```bash
   zip -r FiiOat-v17_r38-unstable.zip META-INF/ FiiOat.sh service.sh module.prop customize.sh
   ```

   **Con 7z:**
   ```bash
   7z a -tzip FiiOat-v17_r38-unstable.zip META-INF/ FiiOat.sh service.sh module.prop customize.sh
   ```

   **Con Python3:**
   ```python
   import zipfile
   import os
   
   with zipfile.ZipFile('FiiOat-v17_r38-unstable.zip', 'w') as zipf:
       for root, dirs, files in os.walk('META-INF'):
           for file in files:
               zipf.write(os.path.join(root, file))
       for file in ['FiiOat.sh', 'service.sh', 'module.prop', 'customize.sh']:
           if os.path.exists(file):
               zipf.write(file)
   ```

### Estructura del ZIP (para referencia):

```
FiiOat.zip
├── META-INF/
│   └── com/
│       └── google/
│           └── android/
│               ├── update-binary
│               └── updater-script
├── FiiOat.sh
├── service.sh
├── module.prop
└── customize.sh
```

## Paso 3: Transferir el Módulo al Dispositivo

1. Conecta tu FiiO JM21/M21 a la computadora vía USB
2. Transfiere el archivo `FiiOat-v17_r38-unstable.zip` a la memoria interna del dispositivo
3. O transfiere vía ADB:
   ```bash
   adb push FiiOat-v17_r38-unstable.zip /sdcard/Download/
   ```

## Paso 4: Instalar el Módulo en Magisk

### Método 1: Desde la App de Magisk (Recomendado)

1. Abre la aplicación **Magisk** en tu dispositivo
2. Ve a la pestaña **"Módulos"** (Modules)
3. Toca el botón **"Instalar desde almacenamiento"** o **"Install from storage"**
4. Navega hasta donde guardaste el ZIP (generalmente `/sdcard/Download/`)
5. Selecciona `FiiOat-v17_r38-unstable.zip`
6. Toca **"Instalar"** o **"Install"**
7. Espera a que termine la instalación
8. **IMPORTANTE**: Toca **"Reboot"** o **"Reiniciar"** para aplicar los cambios

### Método 2: Desde ADB (Para Usuarios Avanzados)

```bash
# Conecta el dispositivo vía ADB
adb shell

# Eleva a root
su

# Instala el módulo
magisk --install-module /sdcard/Download/FiiOat-v17_r38-unstable.zip

# Reinicia
reboot
```

## Paso 5: Verificar la Instalación

### Después del Reinicio:

1. Abre la app de **Magisk**
2. Ve a **"Módulos"**
3. Verifica que **"FiiO Android Tweaker"** aparezca en la lista y esté activado
4. Deberías ver la versión `v17_r38`

### Verificar los Logs:

1. Conecta el dispositivo vía ADB o usa un explorador de archivos con root
2. Navega a: `/data/adb/modules/fiioat/`
3. Revisa los archivos:
   - `info.log` - Logs informativos
   - `error.log` - Errores (si los hay)

#### Ver logs desde ADB:

```bash
adb shell
su
cat /data/adb/modules/fiioat/info.log
cat /data/adb/modules/fiioat/error.log
```

## Paso 6: Probar el Módulo

### Pruebas Básicas:

1. **Reproducir Música**:
   - Abre tu app de música favorita
   - Reproduce una canción
   - Verifica que no hay cortes o problemas de audio

2. **Verificar Rendimiento**:
   - Abre varias apps
   - Verifica que el sistema responde bien
   - No debería haber lag excesivo

3. **Verificar Apps Deshabilitadas**:
   ```bash
   adb shell
   su
   pm list packages -d | grep -i fiio
   ```
   Esto mostrará los paquetes deshabilitados relacionados con FiiO

4. **Verificar Optimizaciones de CPU**:
   ```bash
   adb shell
   su
   cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
   cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
   ```
   Deberían mostrar `300000` (300 MHz)

5. **Verificar que ZRAM está desactivado**:
   ```bash
   adb shell
   su
   cat /proc/swaps
   ```
   No debería mostrar dispositivos zram

### Pruebas Avanzadas:

1. **Verificar UCLAMP Settings**:
   ```bash
   adb shell
   su
   cat /dev/cpuset/top-app/uclamp.max
   cat /dev/cpuset/top-app/uclamp.min
   ```

2. **Verificar Firmware Detection**:
   ```bash
   adb shell
   su
   grep "1.0.8" /data/adb/modules/fiioat/info.log
   ```

## Paso 7: Reportar Resultados

### Si el Módulo Funciona Correctamente:

1. Verifica que no hay errores críticos en `error.log`
2. Verifica que todas las optimizaciones se aplicaron (revisa `info.log`)
3. Prueba la reproducción de música durante al menos 30 minutos
4. Verifica que el sistema es estable

### Si Encuentras Problemas:

1. **Captura los logs completos**:
   ```bash
   adb pull /data/adb/modules/fiioat/info.log
   adb pull /data/adb/modules/fiioat/error.log
   ```

2. **Documenta el problema**:
   - ¿Qué estabas haciendo cuando ocurrió?
   - ¿Qué error específico viste?
   - ¿El dispositivo se reinició?
   - ¿Hay apps que no funcionan?

3. **Crea un Issue en GitHub** con:
   - Versión del firmware
   - Modelo del dispositivo (JM21 o M21)
   - Logs completos
   - Descripción detallada del problema

## Paso 8: Desinstalar (Si es Necesario)

### Si necesitas desinstalar el módulo:

1. Abre **Magisk**
2. Ve a **"Módulos"**
3. Toca en **"FiiO Android Tweaker"**
4. Toca **"Desinstalar"** o **"Uninstall"**
5. Reinicia el dispositivo

### O desde ADB:

```bash
adb shell
su
rm -rf /data/adb/modules/fiioat
reboot
```

## Checklist de Prueba

Antes de reportar que funciona, verifica:

- [ ] El módulo aparece en Magisk como instalado
- [ ] No hay errores críticos en `error.log`
- [ ] El log `info.log` muestra "All optimizations completed"
- [ ] La música se reproduce sin problemas
- [ ] El sistema es estable (no se reinicia)
- [ ] Las apps funcionan normalmente
- [ ] La detección de firmware 1.0.8 funciona (si aplica)
- [ ] Los paquetes se deshabilitan correctamente
- [ ] Las optimizaciones de CPU se aplican

## Próximos Pasos Después de Probar

Una vez que hayas probado el módulo:

1. **Si funciona correctamente**:
   - Reporta los resultados
   - Podemos crear un Pull Request para mergear a `main`
   - Crear un release oficial

2. **Si hay problemas**:
   - Reporta los issues con logs
   - Haremos correcciones
   - Crearemos una nueva versión

## Contacto y Soporte

- **GitHub Issues**: https://github.com/kuiporro/FiiOat/issues
- **Branch**: `v17_r38-unstable`
- **Versión**: v17_r38 (UNTESTED)

---

**¡Gracias por probar esta versión!** Tu feedback es esencial para mejorar el módulo.

