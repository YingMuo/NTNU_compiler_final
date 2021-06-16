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
    il_add(&head2, NULL, "F_UMINUS", "LLL[I]", "T&I", NULL);
    il_add(&head2, NULL, "F_ADD", "T&1", "B", "T&2");
    il_add(&head2, NULL, "F_MUL", "T&2", "D", "T&3");
    il_add(&head1, NULL, "F_SUB", "T&3", "C", "T&4");
    il_add(&head1, NULL, "F_ADD", "T&4", "100", "T&5");
    il_add(&head1, NULL, "F_ADD", "T&5", "100.11", "T&6");
    il_add(&head3, NULL, "F_STORE", "A", "T&6", NULL);

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