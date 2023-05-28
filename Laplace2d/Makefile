CC=gcc
LD=gcc
CFLAGS=-O2
LDFLAGS= -fopenmp

all: exe run

exe: laplace2d.o jacobi.o
	$(LD) $(LDFLAGS) -o $@ $^ ${NVTXLIB} 

run: exe
	./exe

.PHONY: clean
clean:
	-rm -f *.o  core exe
.SUFFIXES: .c  .o
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $< 
