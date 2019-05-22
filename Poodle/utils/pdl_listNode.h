
struct pdl_listNode {
    void *val;
    struct pdl_listNode *next;
};

extern int pdl_listLength(struct pdl_listNode *list);

extern struct pdl_listNode *pdl_createListWithArray(void **vals, int count);
extern void pdl_destroyList(struct pdl_listNode *list);
extern void pdl_printList(struct pdl_listNode *list);
