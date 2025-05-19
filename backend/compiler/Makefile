CC = gcc
CFLAGS = -Wall -g

all: compiler

compiler: lexer.o parser.o
	$(CC) $(CFLAGS) -o compiler lexer.o parser.o -lfl

parser.tab.h: parser.y
	bison -d parser.y

lexer.o: lexer.l parser.tab.h
	flex lexer.l
	$(CC) $(CFLAGS) -c lex.yy.c -o lexer.o

parser.o: parser.tab.c
	$(CC) $(CFLAGS) -c parser.tab.c -o parser.o

clean:
	rm -f compiler lexer.o parser.o lex.yy.c parser.tab.c parser.tab.h 