all:
	lex lexer.l
	yacc -d parser.y
	gcc -c vlist.c
	gcc -c ilist.c
	gcc -c var_ctr.c
	gcc -c ins_ctr.c
	gcc -c tok_spn.c
	gcc lex.yy.c y.tab.c vlist.o ilist.o var_ctr.o ins_ctr.o tok_spn.o -ly -lfl -o final

clean:
	rm final test_vlist test_ilist

test_vlist:
	gcc -g -c vlist.c
	gcc -g -c test_vlist.c
	gcc -g vlist.o test_vlist.o -o test_vlist

test_ilist:
	gcc -g -c ilist.c
	gcc -g -c test_ilist.c
	gcc -g ilist.o test_ilist.o -o test_ilist