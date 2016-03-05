CC=g++
CFLAGS=-g -Wall
all: kalman

kalman: main.cc
	$(CC) $(CFLAGS) -o main main.cc kalman.cc mvrandom.cc

clean: 
	rm main
