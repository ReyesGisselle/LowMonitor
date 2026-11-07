# LowMonitor — reporte técnico
**Estudiante:** 
Jason Anibal Miza Ovalle – Carné: 0910-23-17929
Carlos Rolando Molina Reynosa – Carné: 9941-18-19380
Bryon Josue Salvador Rosario Lopez – Carné: 7690-23-6328
Stephany Gisselle Reyes Aguilar – Carné: 5190-23-12936

**Curso:** Arquitectura de Computadoras  


## 1. Objetivo y entorno
Desarrollar una aplicación Linux ELF64 con NASM para diagnosticar características del procesador, verificar memoria de usuario y explorar mediciones de tiempo y SIMD. Registrar versión de Ubuntu, CPU, NASM y equipo en que se validó.

## 2. Arquitectura de la solución
El código contiene secciones `.data`, `.bss`, `.text`, punto de entrada `_start` y rutinas auxiliares. La salida usa `write` (syscall 1), la entrada `read` (0), la memoria `mmap` (9) y `munmap` (11). `CPUID` identifica capacidades del procesador; `RDTSC` obtiene marcas de ciclos y SSE2 procesa datos vectoriales.

## 3. Pruebas de los módulos
**CPU:** [Completar marca, familia, modelo y extensiones detectadas].

**Puertos:** El programa informa restricciones de privilegio; el acceso real con IN/OUT queda pendiente. Documentar si el docente permite esta limitación.

**Memoria:** Se comprueba un buffer de 1 MiB con patrones AA, 55 e incremental. Registrar bits discrepantes: [resultados reales]. Este test no sustituye MemTest86 ni evalúa toda la RAM física.

**Rendimiento:** Registrar ciclos TSC y operaciones estimadas del bucle: [resultados reales]. No llamar a los cocientes IPC/CPI arquitectónicos sin PMU.

**Jerarquía:** Registrar ciclos medios de los buffers de 16 KiB, 128 KiB, 2 MiB y 32 MiB: [resultados reales]. Los nombres L1/L2/L3 son aproximaciones y requieren validación contra tamaños reales de caché.

**SIMD:** SSE2 realiza suma, multiplicación de índices pares y comparación de cuatro enteros de 32 bits. Registrar resultados reales y validar que la CPU admita SSE2.

## 4. Limitaciones y mejoras
Pendientes para cumplimiento pleno: IN/OUT seguros y autorizados, PMU para instrucciones retiradas, medición rigurosa de latencias por nivel, AVX2 opcional y pruebas reales en Ubuntu. Documentar errores observados y cambios realizados.

## 5. Evidencias y referencias
Adjuntar capturas de terminal, versión de NASM, salida de `file lowmonitor` y `diagnostico.txt`. Citar el enunciado del curso, manual NASM y manual Intel/AMD utilizado.

> **Importante:** Este es un borrador, no el reporte final: reemplazar todos los campos entre corchetes con pruebas reales y exportar a PDF (máximo cinco páginas).
