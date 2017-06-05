all:
	./arm/arm-none-eabi-linux-as -o cripto.o cripto.s
	./arm/arm-none-eabi-linux-ld -T mapa.lds -o cripto cripto.o
	./arm/armsim -c -l cripto -d devices.txt
