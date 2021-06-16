#include <stdio.h>

#include "vlist.h"

Vlist head1;
Vlist head2;

int main(void)
{
    INIT_LIST_HEAD(&head1);
    INIT_LIST_HEAD(&head2);
    vl_add(&head2, "a", 0);
    vl_add(&head2, "b", 0);
    vl_add(&head2, "c", 0);
    vl_add(&head1, "d", 0);
    vl_add(&head1, "AAA", 0);
    vl_add(&head1, "LLL", 100);

    vl_print(&head1);
    printf("\n");
    vl_print(&head2);
    printf("\n");
    vl_splice_tail(&head2, &head1);
    // vl_print(&head1);
    // printf("\n");
    vl_print(&head2);
    printf("\n");
    vl_del(&head1);
    vl_del(&head2);
    return 0;
}