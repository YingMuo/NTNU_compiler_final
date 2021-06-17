#include <stdio.h>

#include "ilist.h"

Ilist head1;
Ilist head2;
Ilist head3;

int main(void)
{
    INIT_LIST_HEAD(&head1);
    INIT_LIST_HEAD(&head2);
    INIT_LIST_HEAD(&head3);
    char *arg[3];
    arg[0] = "LLL[I]"; arg[1] = "T&I";
    il_add(&head2, NULL, "F_UMINUS", 2, arg);
    arg[0] = "T&1"; arg[1] = "B"; arg[2] = "T&2";
    il_add(&head2, NULL, "F_ADD", 3, arg);
    arg[0] = "T&2"; arg[1] = "D"; arg[2] = "T&3";
    il_add(&head2, NULL, "F_MUL", 3, arg);
    arg[0] = "T&3"; arg[1] = "C"; arg[2] = "T&4";
    il_add(&head1, NULL, "F_SUB", 3, arg);
    arg[0] = "T&4"; arg[1] = "100"; arg[2] = "T&5";
    il_add(&head1, NULL, "F_ADD", 3, arg);
    arg[0] = "T&5"; arg[1] = "100.11"; arg[2] = "T&6";
    il_add(&head1, NULL, "F_ADD", 3, arg);
    arg[0] = "A"; arg[1] = "T&6";
    il_add(&head3, NULL, "F_STORE", 2, arg);

    il_print(&head1);
    printf("\n");
    il_print(&head2);
    printf("\n");
    il_print(&head3);
    printf("\n");
    il_splice_tail(&head2, &head1);
    il_splice_tail(&head2, &head3);
    // il_print(&head1);
    // printf("\n");
    il_print(&head2);
    printf("\n");
    il_del(&head1);
    il_del(&head2);
    il_del(&head3);
    return 0;
}