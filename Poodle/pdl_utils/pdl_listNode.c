#import "pdl_listNode.h"
#import <stdlib.h>
#import <stdio.h>

int pdl_listLength(struct pdl_listNode *list) {
    int length = 0;
    struct pdl_listNode *current = list;
    while (current) {
        current = current->next;
        length++;
    }
    return length;
}

struct pdl_listNode *pdl_createListWithArray(void **vals, int count) {
    struct pdl_listNode *ret = NULL;
    for (int i = count - 1; i >= 0; i--) {
        struct pdl_listNode *node = malloc(sizeof(struct pdl_listNode));
        node->val = vals[i];
        node->next = ret;
        ret = node;
    }
    return ret;
}

void pdl_destroyList(struct pdl_listNode *list) {
    struct pdl_listNode *node = list;
    while (node) {
        struct pdl_listNode *temp = node;
        node = node->next;
        free(temp);
    }
}

void pdl_printList(struct pdl_listNode *list) {
    struct pdl_listNode *node = list;
    printf("printList: ");
    while (node) {
        printf("%p", node->val);
        node = node->next;
        if (node) {
            printf(" ");
        }
    }
    printf("\n");
}
