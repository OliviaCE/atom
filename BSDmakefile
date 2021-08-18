CC ?= cc

all:
	rm -rf atom/
	git clone --depth 1 --quiet https://github.com/atomlang/atomc
	$(CC) -std=gnu11 -w -o v atomc/atom.c -lm -lexecinfo
	rm -rf vc/
	@echo "atom has been successfully built"
