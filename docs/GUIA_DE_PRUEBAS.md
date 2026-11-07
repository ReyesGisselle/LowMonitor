# Guía de pruebas y evidencias

1. Capturar versión de NASM: `nasm -v`.
2. Compilar: `make clean && make`.
3. Verificar ELF: `file lowmonitor`.
4. Ejecutar cada opción del menú y registrar cualquier fallo.
5. Ejecutar `make test` y guardar salida completa.
6. Revisar que los tres patrones de RAM den 0 errores en el buffer probado.
7. Comparar varias ejecuciones de RDTSC: la frecuencia, el escalado dinámico y la carga del sistema alteran las mediciones.
8. No afirmar que se probaron puertos físicos cuando el programa solo explica las restricciones.
9. Adjuntar capturas y resultados reales al informe técnico.
