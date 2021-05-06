# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Created by Leonardo Agüero on 04-05-2021
#
# Collaborators:
# * Collaborator 1
#
# DESCRIPTION:
# Se debe correr este Makefile dentro del repositorio base (no en firmware, ni en test, ni en ningun otro solo en el directorio base del emulador)
# Colocar archivo de c a compilar en directorio base.
#
# Variables configurables (no cambiar variables fuera de esta lista)
# CFILE: nombre del archivo de C a utilizar sin extension.
# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

# CONFIG variables
CFILE=forloop

all: build

build:
	# pasos para compilar codigo de c
	cd firmware && \
	/opt/riscv/bin/riscv32-unknown-elf-gcc -S $(CFILE).c -o $(CFILE).asm && \
	/opt/riscv/bin/riscv32-unknown-elf-as $(CFILE).asm -o $(CFILE).o && \
	/opt/riscv/bin/riscv32-unknown-elf-ld $(CFILE).o -o $(CFILE).elf --entry main && \
	/opt/riscv/bin/riscv32-unknown-elf-objcopy -O binary $(CFILE).elf $(CFILE).bin && \
	od -tx4 -w4 -v -An $(CFILE).bin > test.mem && \
	cd ..

run:
	# realiza los pasos para compilar en test
	# make y despliego de las se;ales
	cd test && $(MAKE) && \
	$(MAKE) wave

clean:
	# EN DESARROLLO
	# SOLO USAR ESTE TARGET SI SE SABE LO QUE SE ESTA HACIENDO
	cd firmware/ && \
	rm -f $(CFILE).asm && \
	rm -f $(CFILE).o && \
	rm -f $(CFILE).elf && \
	rm -f $(CFILE).bin && \

.PHONY: all clean run build