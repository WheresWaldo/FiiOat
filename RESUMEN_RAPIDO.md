# Resumen Rápido - Instalación FiiOat v17_r38

## ⚠️ Versión NO PROBADA - Usar bajo tu propio riesgo

## Pasos Rápidos

### 1. Obtener el Módulo
```bash
git clone https://github.com/kuiporro/FiiOat.git
cd FiiOat
git checkout v17_r38-unstable
```

### 2. Crear el ZIP
```bash
chmod +x build_module.sh
./build_module.sh
```

### 3. Transferir al Dispositivo
```bash
adb push FiiOat-v17_r38-v17_r38-unstable.zip /sdcard/Download/
```

### 4. Instalar en Magisk
- Abre Magisk Manager
- Módulos → Instalar desde almacenamiento
- Selecciona el ZIP
- Reinicia

### 5. Verificar
```bash
adb shell
su
cat /data/adb/modules/fiioat/info.log
cat /data/adb/modules/fiioat/error.log
```

## Documentación Completa

Para instrucciones detalladas, ver: [GUIA_INSTALACION_PRUEBA.md](GUIA_INSTALACION_PRUEBA.md)

## Después de Probar

1. Si funciona: Reporta los resultados y crearemos un PR para mergear a `main`
2. Si hay problemas: Crea un Issue en GitHub con los logs

