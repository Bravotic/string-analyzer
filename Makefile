ASM=nasm
ASMFLAGS=-felf32 -o string_analyzer.o -g string_analyzer.s
LD=ld
LDFLAGS=-melf_i386
OBJ=string_analyzer.o

string_analyer: string_analyzer.s
	$(ASM) $(ASMFLAGS)
	$(LD) $(LDFLAGS) -o string_analyzer $(OBJ)

.PHONY: debug
debug: string_analyzer.s
	$(ASM) $(ASMFLAGS) -F dwarf
	$(LD) $(LDFLAGS) -o string_analyzer_debug $(OBJ)

.PHONY: clean
clean:
	rm -f *.o string_analyzer string_analyzer_debug
	

