# LowMonitor — diagnóstico de hardware x86-64

Proyecto académico de Arquitectura de Computadoras. Aplicación nativa Linux ELF64 escrita en NASM, con llamadas al sistema (`syscall`) y uso de CPUID, RDTSC y SSE2.

## Requisitos
- CPU x86-64 y Ubuntu Linux 64 bits (el enunciado indica Ubuntu 26.04 o posterior)
- `nasm` (2.15 o posterior), `make` y `binutils`

```bash
sudo apt update
sudo apt install nasm make binutils
nasm -v
make
file lowmonitor
./lowmonitor
```

Ejecutar diagnóstico completo: elegir `7`. Prueba automática básica: `make test`. Limpiar: `make clean`.

## Módulos

1. **CPU:** CPUID muestra fabricante, marca, familia/modelo/stepping y bits de SSE/SSE2/AVX/AVX2/AVX-512F. La presencia de bits AVX no prueba que el sistema operativo haya habilitado el estado extendido (`XGETBV`).
2. **Puertos:** muestra puertos estándar y restricciones de privilegio. **Limitación pendiente:** no realiza IN/OUT efectivos ni maneja flags de operaciones; hacerlo desde una cuenta regular requiere permisos que Linux no proporciona normalmente. No se escriben puertos físicos para proteger el equipo.
3. **RAM:** reserva 1 MiB con `mmap`, escribe/verifica 0xAA, 0x55 y patrón incremental y cuenta bits discrepantes. Esto **no** prueba toda la RAM física. Lee `MemTotal` de `/proc/meminfo`.
4. **Rendimiento:** usa `LFENCE` + `RDTSC` para medir ciclos de un bucle. Reporta operaciones estimadas/ciclo y ciclos/operación; **no son IPC/CPI reales de instrucciones retiradas**, que requieren contadores PMU. No se calcula GFLOPS.
5. **Jerarquía:** benchmark de acceso dependiente sobre buffers de 16 KiB, 128 KiB, 2 MiB y 32 MiB. Estos tamaños **no garantizan** que los accesos ocurran en L1/L2/L3/RAM; se necesitan pruebas adicionales y detección de cachés CPUID para caracterización rigurosa.
6. **SIMD:** usa SSE2 para suma (`paddd`), multiplicación de enteros sin signo de índices pares (`pmuludq`) y comparación (`pcmpeqd`). No hay implementación AVX2/AVX-512 ni GFLOPS.

## Seguridad
No ejecutar como root para intentar acceder a puertos. Las operaciones sobre memoria se hacen exclusivamente sobre memoria virtual del propio proceso. No se modifican dispositivos.

## Validación
En el equipo de entrega:

```bash
make clean && make
file lowmonitor
printf '7\n0\n' | ./lowmonitor | tee evidencias/diagnostico.txt
```

Adjuntar capturas reales de ejecución en `evidencias/`. Nunca presentar datos de ejemplo como resultados reales.

## Estado y pendientes
Este repositorio es una **base funcional para continuar**, no una afirmación de cumplimiento total del enunciado. Falta validar compilación/ejecución en Ubuntu, realizar accesos IN/OUT bajo permisos adecuados (o acordar con el docente una alternativa), implementar mediciones IPC/CPI con PMU, identificar tamaños reales de caché, registrar resultados reales y preparar un informe final basado en esas pruebas.

## Entrega
Subir código, Makefile, README, reporte PDF y binario ELF64 **compilado en Ubuntu** a GitHub. Verificar con `file lowmonitor`. La URL del repositorio será `https://github.com/TU-USUARIO/LowMonitor`.
