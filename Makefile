all:
	lex lexer.l
	yacc -d parser.y
	gcc -c -g vlist.c
	gcc -g lex.yy.c y.tab.c vlist.o -ly -lfl -o final

clean:
	rm *.c *.h *.o final