CC=gcc
CFLAGS=-Wall -g -Iinclude -Itest/include -IUOCPlay/include
SRC=$(wildcard src/*.c) $(wildcard test/src/*.c) $(wildcard UOCPlay/src/*.c)
EXEC=UOCPlayApp

all: $(EXEC)

$(EXEC): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f src/*.o test/src/*.o UOCPlay/src/*.o $(EXEC)