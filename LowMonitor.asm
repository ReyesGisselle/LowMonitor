
default rel
section .data
banner db 10,'=== LOWMONITOR | x86-64 ===',10,0
menu db 10,'1 CPU',10,'2 Puertos E/S',10,'3 Memoria',10,'4 Rendimiento',10,'5 Jerarquia',10,'6 SIMD',10,'7 Diagnostico completo',10,'0 Salir',10,'Opcion: ',0
cpu_title db 10,'[CPU]',10,0
brand_lbl db 'Procesador: ',0
vendor_lbl db 'Fabricante: ',0
family_lbl db 'Familia: ',0
model_lbl db 'Modelo: ',0
step_lbl db 'Stepping: ',0
ext_lbl db 'Extensiones (hardware; AVX requiere soporte OS): ',0
sse db 'SSE ',0
sse2 db 'SSE2 ',0
avx db 'AVX ',0
avx2 db 'AVX2 ',0
avx512 db 'AVX-512F ',0
none db 'ninguna',0
newline db 10,0
ports_title db 10,'[PUERTOS E/S]',10,0
ports_msg db 'IN/OUT 8/16/32 bits requieren privilegios I/O (ioperm/iopl).',10,'Sin permisos no se ejecutan instrucciones de acceso: estado NO DISPONIBLE.',10,'Puertos previstos: 0x60 teclado, 0x61 panel, 0x3F8 COM1.',10,'No se escribe en puertos de hardware para evitar cambios peligrosos.',10,0
mem_title db 10,'[MEMORIA: buffer de 1 MiB]',10,0
mem_total db 'Memoria RAM del sistema (kB): ',0
patAA db 'Patron AA - bits diferentes: ',0
pat55 db 'Patron 55 - bits diferentes: ',0
patINC db 'Patron incremental - bits diferentes: ',0
perf_title db 10,'[RENDIMIENTO: benchmark controlado]',10,0
cycles_lbl db 'Ciclos TSC (aprox.): ',0
ops_lbl db 'Operaciones del bucle (estimadas): ',0
cpi_lbl db 'Ciclos por operacion estimados x1000: ',0
ipc_lbl db 'Operaciones por ciclo estimadas x1000: ',0
perf_note db 'Nota: no son IPC/CPI de instrucciones retiradas; para eso se requieren PMU/perf.',10,0
hier_title db 10,'[JERARQUIA: acceso dependiente, ciclos por salto aproximados]',10,0
reg_lbl db 'Registros (bucle): ',0
l1_lbl db 'Buffer 16 KiB (aprox. L1): ',0
l2_lbl db 'Buffer 128 KiB (aprox. L2): ',0
l3_lbl db 'Buffer 2 MiB (aprox. L3): ',0
ram_lbl db 'Buffer 32 MiB (aprox. RAM/LLC): ',0
hier_note db 'Los tamanos de cache dependen del CPU; los buffers NO garantizan un nivel concreto.',10,0
simd_title db 10,'[SIMD SSE2: suma, multiplicacion, comparacion]',10,0
simd_ok db 'SSE2 disponible: operaciones sobre 4 enteros de 32 bits realizadas.',10,0
simd_no db 'SSE2 no disponible.',10,0
simd_sum db 'Suma (primer elemento): ',0
simd_mul db 'Multiplicacion (primer elemento): ',0
simd_cmp db 'Comparacion igual (mascara primer elemento): ',0
error_msg db 'Error al reservar memoria (mmap).',10,0
bad db 'Opcion invalida.',10,0
prompt db 0
align 16
v1 dd 2,3,4,5
v2 dd 2,7,8,9
section .bss
choice resb 8
number resb 32
brand resb 49
vendor resb 13
maxleaf resd 1
features resd 3
meminfo resb 128
buffer resq 1
largeptr resq 1
bench_cycles resq 1
bench_ops resq 1
simd_res resd 4
section .text
global _start
_start:
    lea rdi,[banner]
    call puts
.loop:
    lea rdi,[menu]
    call puts
    xor eax,eax
    xor edi,edi
    lea rsi,[choice]
    mov edx,8
    syscall
    cmp rax,0
    jle .exit
    mov al,[choice]
    cmp al,'0'
    je .exit
    cmp al,'1'
    je .cpu
    cmp al,'2'
    je .ports
    cmp al,'3'
    je .mem
    cmp al,'4'
    je .perf
    cmp al,'5'
    je .hier
    cmp al,'6'
    je .simd
    cmp al,'7'
    je .all
    lea rdi,[bad]
    call puts
    jmp .loop
.cpu: call cpu_info
    jmp .loop
.ports: call ports_info
    jmp .loop
.mem: call memory_test
    jmp .loop
.perf: call performance
    jmp .loop
.hier: call hierarchy
    jmp .loop
.simd: call simd_test
    jmp .loop
.all:
    call cpu_info
    call ports_info
    call memory_test
    call performance
    call hierarchy
    call simd_test
    jmp .loop
.exit:
    mov eax,60
    xor edi,edi
    syscall

; puts(rdi) null-terminated, clobbers rax/rdi/rsi/rdx/rcx/r11
puts:
    push rdi
    mov rsi,rdi
    xor edx,edx
.len: cmp byte [rsi+rdx],0
    je .write
    inc rdx
    jmp .len
.write:
    mov eax,1
    mov edi,1
    syscall
    pop rdi
    ret

; print unsigned 64-bit in RAX
print_u64:
    lea rsi,[number+31]
    mov byte [rsi],0
    mov r8,10
.loop:
    xor edx,edx
    div r8
    dec rsi
    add dl,'0'
    mov [rsi],dl
    test rax,rax
    jnz .loop
    mov rdi,rsi
    call puts
    ret

print_nl:
    lea rdi,[newline]
    jmp puts

cpu_info:
    push rbx
    lea rdi,[cpu_title]
    call puts
    xor eax,eax
    cpuid
    mov [maxleaf],eax
    mov [vendor],ebx
    mov [vendor+4],edx
    mov [vendor+8],ecx
    mov byte [vendor+12],0
    lea rdi,[vendor_lbl]
    call puts
    lea rdi,[vendor]
    call puts
    call print_nl
    mov eax,0x80000000
    cpuid
    cmp eax,0x80000004
    jb .unknown_brand
    mov eax,0x80000002
    cpuid
    mov [brand],eax
    mov [brand+4],ebx
    mov [brand+8],ecx
    mov [brand+12],edx
    mov eax,0x80000003
    cpuid
    mov [brand+16],eax
    mov [brand+20],ebx
    mov [brand+24],ecx
    mov [brand+28],edx
    mov eax,0x80000004
    cpuid
    mov [brand+32],eax
    mov [brand+36],ebx
    mov [brand+40],ecx
    mov [brand+44],edx
    mov byte [brand+48],0
    jmp .brand_ready
.unknown_brand:
    mov byte [brand],'-'
    mov byte [brand+1],0
.brand_ready:
    lea rdi,[brand_lbl]
    call puts
    lea rdi,[brand]
    call puts
    call print_nl
    cmp dword [maxleaf],1
    jb .done
    mov eax,1
    cpuid
    mov [features],ecx
    mov [features+4],edx
    mov r8d,eax
    mov r9d,eax
    shr r8d,8
    and r8d,15
    mov r10d,eax
    shr r10d,20
    and r10d,255
    cmp r8d,15
    je .extfam
    jmp .famready
.extfam: add r8d,r10d
.famready:
    lea rdi,[family_lbl]
    call puts
    mov eax,r8d
    call print_u64
    call print_nl
    mov r8d,r9d
    shr r8d,4
    and r8d,15
    mov r10d,r9d
    shr r10d,16
    and r10d,15
    mov r11d,r9d
    shr r11d,8
    and r11d,15
    cmp r11d,6
    je .extmodel
    cmp r11d,15
    jne .modelready
.extmodel:
    shl r10d,4
    add r8d,r10d
.modelready:
    lea rdi,[model_lbl]
    call puts
    mov eax,r8d
    call print_u64
    call print_nl
    lea rdi,[step_lbl]
    call puts
    and r9d,15
    mov eax,r9d
    call print_u64
    call print_nl
    lea rdi,[ext_lbl]
    call puts
    test dword [features+4],1<<25
    jz .skip_sse
    lea rdi,[sse]
    call puts
.skip_sse:
    test dword [features+4],1<<26
    jz .skip_sse2
    lea rdi,[sse2]
    call puts
.skip_sse2:
    test dword [features],1<<28
    jz .skip_avx
    lea rdi,[avx]
    call puts
.skip_avx:
    cmp dword [maxleaf],7
    jb .endext
    mov eax,7
    xor ecx,ecx
    cpuid
    mov [features+8],ebx
    test ebx,1<<5
    jz .skip_avx2
    lea rdi,[avx2]
    call puts
.skip_avx2:
    test dword [features+8],1<<16
    jz .endext
    lea rdi,[avx512]
    call puts
.endext: call print_nl
.done:
    pop rbx
    ret

ports_info:
    lea rdi,[ports_title]
    call puts
    lea rdi,[ports_msg]
    call puts
    ret

; mmap anonymous private: 9, munmap: 11
alloc:
    mov rsi,rdi
    xor edi,edi
    mov eax,9
    mov edx,3
    mov r10d,0x22
    mov r8,-1
    xor r9d,r9d
    syscall
    ret

; memory test on a user-space allocation only; counts differing bits using POPCNT-free Kernighan loop
memory_test:
    lea rdi,[mem_title]
    call puts
    ; /proc/meminfo reading with open/read; report MemTotal first line
    lea rdi,[mem_total]
    call puts
    mov eax,2
    lea rdi,[rel mempath]
    xor esi,esi
    xor edx,edx
    syscall
    test eax,eax
    js .memunknown
    mov r12d,eax
    xor eax,eax
    mov edi,r12d
    lea rsi,[meminfo]
    mov edx,127
    syscall
    mov r13,rax
    mov byte [meminfo+r13],0
    mov eax,3
    mov edi,r12d
    syscall
    test r13,r13
    jle .memunknown
    lea rsi,[meminfo]
    xor rax,rax
.finddigit:
    cmp byte [rsi],0
    je .memunknown
    cmp byte [rsi],'0'
    jb .nextchar
    cmp byte [rsi],'9'
    jbe .digits
.nextchar: inc rsi
    jmp .finddigit
.digits:
    xor rax,rax
.digitloop:
    movzx rdx,byte [rsi]
    cmp dl,'0'
    jb .printmem
    cmp dl,'9'
    ja .printmem
    imul rax,rax,10
    sub rdx,'0'
    add rax,rdx
    inc rsi
    jmp .digitloop
.printmem: call print_u64
    call print_nl
    jmp .test
.memunknown:
    xor eax,eax
    call print_u64
    call print_nl
.test:
    mov edi,1048576
    call alloc
    test rax,rax
    js .error
    mov [buffer],rax
    mov r12,rax
    lea rdi,[patAA]
    mov r13d,0xAA
    call test_pattern
    lea rdi,[pat55]
    mov r13d,0x55
    call test_pattern
    lea rdi,[patINC]
    mov r13d,256
    call test_pattern
    mov eax,11
    mov rdi,[buffer]
    mov esi,1048576
    syscall
    ret
.error:
    lea rdi,[error_msg]
    call puts
    ret

; rdi label, r13 pattern (256 means byte index mod 256)
test_pattern:
    call puts
    xor rcx,rcx
.fill:
    mov eax,r13d
    cmp eax,256
    jne .store
    mov eax,ecx
.store:
    mov [r12+rcx],al
    inc rcx
    cmp rcx,1048576
    jb .fill
    xor r8,r8
    xor rcx,rcx
.verify:
    mov eax,r13d
    cmp eax,256
    jne .compare
    mov eax,ecx
.compare:
    xor al,[r12+rcx]
    movzx edx,al
.countbits:
    test edx,edx
    jz .next
    lea esi,[rdx-1]
    and edx,esi
    inc r8
    jmp .countbits
.next:
    inc rcx
    cmp rcx,1048576
    jb .verify
    mov rax,r8
    call print_u64
    call print_nl
    ret

; serialized-ish TSC: LFENCE/RDTSC, RDTSC/LFENCE
read_tsc:
    lfence
    rdtsc
    shl rdx,32
    or rax,rdx
    lfence
    ret

performance:
    lea rdi,[perf_title]
    call puts
    call read_tsc
    mov r12,rax
    mov rcx,10000000
    xor r8,r8
.loop:
    add r8,rcx
    xor r8,rcx
    dec rcx
    jnz .loop
    call read_tsc
    sub rax,r12
    mov [bench_cycles],rax
    mov qword [bench_ops],20000000
    lea rdi,[cycles_lbl]
    call puts
    mov rax,[bench_cycles]
    call print_u64
    call print_nl
    lea rdi,[ops_lbl]
    call puts
    mov rax,[bench_ops]
    call print_u64
    call print_nl
    lea rdi,[cpi_lbl]
    call puts
    mov rax,[bench_cycles]
    mov rcx,1000
    mul rcx
    mov rcx,[bench_ops]
    div rcx
    call print_u64
    call print_nl
    lea rdi,[ipc_lbl]
    call puts
    mov rax,[bench_ops]
    mov rcx,1000
    mul rcx
    mov rcx,[bench_cycles]
    test rcx,rcx
    jz .zero
    div rcx
    jmp .ipc
.zero: xor eax,eax
.ipc:
    call print_u64
    call print_nl
    lea rdi,[perf_note]
    call puts
    ret

; pointer chasing with a fixed stride; one cache line per hop; reported cycles are estimates
hierarchy:
    lea rdi,[hier_title]
    call puts
    mov edi,33554432
    call alloc
    test rax,rax
    js .error
    mov [largeptr],rax
    mov r12,rax
    lea rdi,[reg_lbl]
    call puts
    call register_bench
    lea rdi,[l1_lbl]
    mov esi,16384
    call chase_bench
    lea rdi,[l2_lbl]
    mov esi,131072
    call chase_bench
    lea rdi,[l3_lbl]
    mov esi,2097152
    call chase_bench
    lea rdi,[ram_lbl]
    mov esi,33554432
    call chase_bench
    mov eax,11
    mov rdi,[largeptr]
    mov esi,33554432
    syscall
    lea rdi,[hier_note]
    call puts
    ret
.error:
    lea rdi,[error_msg]
    call puts
    ret
register_bench:
    call read_tsc
    mov r9,rax
    mov rcx,1000000
    xor r8,r8
.rloop:
    inc r8
    dec rcx
    jnz .rloop
    call read_tsc
    sub rax,r9
    xor edx,edx
    mov rcx,1000000
    div rcx
    call print_u64
    call print_nl
    ret
; rdi label, esi buffer bytes; build a cyclic list with 64-byte stride
chase_bench:
    push rsi
    call puts
    pop rsi
    mov r13d,esi
    shr r13d,6
    ; construct a circular pointer-chasing chain at 64-byte offsets
    xor ecx,ecx
.build2:
    lea edx,[rcx+1]
    cmp edx,r13d
    jb .notlast2
    xor edx,edx
.notlast2:
    shl edx,6
    mov r8d,ecx
    shl r8d,6
    mov [r12+r8],edx
    inc ecx
    cmp ecx,r13d
    jb .build2
    xor r8d,r8d
    mov ecx,100000
    call read_tsc
    mov r9,rax
.chase:
    mov r8d,[r12+r8]
    dec ecx
    jnz .chase
    call read_tsc
    sub rax,r9
    xor edx,edx
    mov ecx,100000
    div rcx
    call print_u64
    call print_nl
    ret

simd_test:
    lea rdi,[simd_title]
    call puts
    push rbx
    mov eax,1
    cpuid
    test edx,1<<26
    jz .unsupported
    movdqu xmm0,[v1]
    movdqu xmm1,[v2]
    movdqa xmm2,xmm0
    paddd xmm2,xmm1
    movdqu [simd_res],xmm2
    lea rdi,[simd_sum]
    call puts
    mov eax,[simd_res]
    call print_u64
    call print_nl
    movdqa xmm2,xmm0
    pmuludq xmm2,xmm1 ; multiplies even-index unsigned 32-bit values
    movdqu [simd_res],xmm2
    lea rdi,[simd_mul]
    call puts
    mov eax,[simd_res]
    call print_u64
    call print_nl
    pcmpeqd xmm0,xmm1
    movdqu [simd_res],xmm0
    lea rdi,[simd_cmp]
    call puts
    mov eax,[simd_res]
    call print_u64
    call print_nl
    lea rdi,[simd_ok]
    call puts
    pop rbx
    ret
.unsupported:
    lea rdi,[simd_no]
    call puts
    pop rbx
    ret
section .rodata
mempath db '/proc/meminfo',0
