#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "y.tab.h"
#include "ins_ctr.h"

extern FILE *yyin;

extern char *output_file;

int main(int argc, char *argv[])
{
    int opt;
    char *output_name;
    while ((opt = getopt(argc, argv, "o:")) != -1) {
        switch (opt) {
        case 'o':
            output_name = optarg;
            break;
        case '?':
            fprintf(stderr, "Usage: %s [-o output] input\n", argv[0]);
            exit(EXIT_FAILURE);
            break;
        default: /* '?' */
            break;
        }
    }

    if (optind >= argc) {
        fprintf(stderr, "Expected argument after options\n");
        fprintf(stderr, "Usage: %s [-o output] input\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    yyin = fopen(argv[optind], "r");
    if (!yyin)
        fprintf(stderr, "cannot access %s: No such file or directory\n", argv[optind]);

    output_file = fopen(output_name ? output_name : "a.out", "w");
    if (!output_file)
        fprintf(stderr, "get output file error");

    yyparse();
    codegen_ins();

    return 0;
}