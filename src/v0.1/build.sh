#!/bin/bash

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
qemu-img create -f raw os.img 1440K
dd if=boot.bin of=os.img bs=512 count=1
dd if=kernel.bin of=os.img bs=512 seek=1
