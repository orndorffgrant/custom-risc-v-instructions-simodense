#!/bin/bash

export TOOL_DIR=/opt/riscv32im_custom

$TOOL_DIR/bin/riscv32-unknown-elf-gcc -march=rv32im -std=gnu99 CProgram.cpp -O3 -ffreestanding -Wl,-Bstatic -o firmware.elf   -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wredundant-decls -g -pedantic  -ffreestanding -fpermissive

$TOOL_DIR/bin/riscv32-unknown-elf-objcopy -O binary firmware.elf  firmware.bin 
$TOOL_DIR/bin/riscv32-unknown-elf-objdump -s -t -r -d -f --source firmware.elf > objdump.txt
cat objdump.txt | grep "start address"
cat objdump.txt | grep -A 1 "SYMBOL TABLE"
rm firmware.elf
cp firmware.bin ../simodense-verilog-cpu/firmware.bin
