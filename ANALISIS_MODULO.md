# Análisis del Módulo FiiOat v17_r38

## ¿Qué hace este módulo?

**FiiOat** es un módulo de Magisk diseñado específicamente para los DAPs (Digital Audio Players) FiiO JM21 y M21. Su objetivo principal es optimizar el rendimiento del sistema Android para mejorar la experiencia de reproducción de música, reduciendo latencia, jitter y mejorando la gestión de memoria.

## Funcionalidades Principales

### 1. **Optimizaciones de CPU y Scheduler**
- **Schedutil Rate-Limits**: Limita la frecuencia de cambios del gobernador de CPU para reducir overhead
- **Frecuencias Mínimas**: Establece frecuencias mínimas para cores E (efficiency) y P (performance) a 300MHz
- **Child Runs First (CRF)**: Prioriza procesos hijos para mejor responsividad
- **Timer Migration**: Desactiva la migración de timers para reducir latencia

### 2. **Gestión de Memoria (RAM)**
- **Eliminación de ZRAM/ZSWAP**: Desactiva completamente la memoria comprimida para reducir latencia
- **Ajustes de Swappiness**: Configura el uso de swap a 60
- **VFS Cache Pressure**: Reduce la presión de caché a 50 para mejor rendimiento
- **Stat Interval**: Reduce el intervalo de estadísticas a 30 para menos jitter
- **MGLRU Tweaks**: Optimiza el Multi-Generational LRU si está disponible en el kernel

### 3. **Optimizaciones del Kernel**
- **Desactivación de Logs**: Desactiva logs del scheduler, printk y iostats para reducir overhead
- **Perf CPU Time**: Limita el tiempo máximo de perf a 10%
- **SPI CRC**: Desactiva verificación CRC en SPI si está disponible

### 4. **UCLAMP Scheduler Tweaks**
Ajusta los valores de UCLAMP (utilization clamping) para diferentes grupos de procesos:
- **Top-App**: Máxima prioridad (max boost, latency sensitive)
- **Foreground**: Prioridad media (50% max)
- **Background**: Prioridad baja pero garantizada (20% min)
- **System-Background**: Mínima prioridad (40% max)

### 5. **Optimizaciones de Red**
- **TCP Timestamps**: Desactivados para reducir overhead
- **TCP Low Latency**: Activado para mejor latencia de red

### 6. **Debloating (Eliminación de Apps Innecesarias)**
Desactiva aplicaciones del sistema que no son necesarias para un DAP:
- Apps de prueba y debugging
- Configuraciones de carrier (no aplicables en DAPs)
- Servicios de broadcast celular
- Overlays de emulación de pantalla
- Apps de Google innecesarias
- Servicios Qualcomm no esenciales

### 7. **Control de Aplicaciones en Segundo Plano**
- **Force Stop**: Detiene aplicaciones secundarias de FiiO que no deben ejecutarse
- **AppOps Background**: Configura permisos para que ciertas apps no corran en segundo plano
- **Device Idle Whitelist**: Añade apps de música a la lista blanca para que no entren en modo idle

### 8. **Optimizaciones del Sistema**
- **Animaciones**: Desactiva todas las animaciones (scale = 0)
- **Blur Effects**: Desactiva efectos de desenfoque
- **Logging**: Desactiva logging de actividades y errores
- **Transparencia**: Reduce transparencia para mejor rendimiento

## Cambios en v17_r38 (Actualización para Firmware 1.0.8)

### Mejoras Implementadas:

1. **Detección de Firmware 1.0.8**
   - El módulo ahora detecta automáticamente si está ejecutándose en firmware 1.0.8
   - Aplica ajustes específicos para esta versión

2. **Funciones Helper Mejoradas**
   - `package_exists()`: Verifica si un paquete está instalado antes de intentar modificarlo
   - `disable_pkg()`: Desactiva paquetes solo si existen
   - `force_stop_pkg()`: Detiene paquetes solo si existen
   - `set_appops_background()`: Configura permisos solo si el paquete existe
   - `whitelist_pkg()`: Añade a whitelist solo si el paquete existe

3. **Cache de Paquetes Instalados**
   - Cachea la lista de paquetes instalados al inicio
   - Esto es especialmente importante en firmware 1.0.8 donde algunas apps cambiaron de ubicación
   - Reduce el tiempo de ejecución y evita errores

4. **Mejor Logging**
   - Logs más informativos sobre qué paquetes se procesan
   - Registra cuando se omite un paquete porque no existe
   - Mejor manejo de errores

5. **Correcciones de Typos**
   - "frrequency" → "frequency"
   - "permisssions" → "permissions"
   - "spotfy" → "spotify"

6. **Código Limpio**
   - Eliminado wait duplicado para `sys.boot_completed`
   - Mejor estructura y organización del código

## ¿Por qué estos cambios son importantes?

### Firmware 1.0.8
En la versión 1.0.8 del firmware de FiiO, algunas aplicaciones del sistema cambiaron de ubicación o fueron removidas. El código anterior intentaba deshabilitar paquetes que podrían no existir, generando errores en los logs. Las nuevas funciones helper verifican la existencia antes de intentar modificarlos.

### Beneficios de las Mejoras
1. **Menos Errores**: No intenta modificar paquetes que no existen
2. **Mejor Rendimiento**: Cache de paquetes reduce tiempo de ejecución
3. **Logs Más Claros**: Sabes exactamente qué se procesó y qué se omitió
4. **Compatibilidad**: Funciona mejor con diferentes versiones de firmware

## Estructura del Módulo

```
FiiOat/
├── FiiOat.sh          # Script principal con todas las optimizaciones
├── service.sh          # Punto de entrada que ejecuta FiiOat.sh
├── module.prop         # Metadatos del módulo (versión, autor, etc.)
├── customize.sh        # Script de personalización (si existe)
├── META-INF/           # Archivos de instalación de Magisk
└── README.md           # Documentación del módulo
```

## Logs

El módulo genera dos archivos de log:
- `info.log`: Información general sobre las operaciones realizadas
- `error.log`: Errores encontrados durante la ejecución

Ubicación: `/data/adb/modules/fiioat/`

## Notas Importantes

⚠️ **Este módulo NO modifica el sonido directamente**. Solo optimiza el sistema para reducir latencia y jitter, lo que puede mejorar indirectamente la calidad de reproducción.

⚠️ **No es un módulo de gaming/performance**. Está específicamente diseñado para DAPs y reproducción de música.

⚠️ **Los cambios son systemless**. Todo se puede revertir desinstalando el módulo.

## Compatibilidad

- **Dispositivos**: FiiO JM21, FiiO M21
- **Firmware**: Optimizado para 1.0.8, compatible con versiones anteriores
- **Android**: Android 13
- **Magisk**: Requiere Magisk v20.4 o superior

## Créditos

- Autor original: @WheresWaldo (Github/Head-Fi)
- Basado en: YAKT por NotZeetea
- Contribuciones: MattClark18 y otros miembros de Head-Fi.org

