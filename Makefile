all:
	lex lexer.l
	yacc -d parser.y
	gcc -c vlist.c
	gcc -c ilist.c
	gcc -c var_ctr.c
	gcc -c ins_ctr.c
	gcc -c tok_spn.c
	gcc -c main.c
	gcc lex.yy.c y.tab.c vlist.o ilist.o var_ctr.o ins_ctr.o tok_spn.o main.o -ly -lfl -o compiler

clean:
	rm compiler *.o

test_vlist:
	gcc -g -c vlist.c
	gcc -g -c test_vlist.c
	gcc -g vlist.o test_vlist.o -o test_vlist

test_ilist:
	gcc -g -c ilist.c
	gcc -g -c test_ilist.c
	gcc -g ilist.o test_ilist.o -o test_ilist