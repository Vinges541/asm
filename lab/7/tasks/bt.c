/*
Шаблон прототипа двоичного дерева поиска на языке Си.
*/


typedef struct _BinaryNodeTree {
    
    struct _BinaryTree  *left;
    struct _BinaryTree  *rigth;
    char *key;
    char *value;
    
} BinaryNodeTree;


buf["key"] -> "value"


BinaryNodeTree * CreateBinaryNodeTree (char *key, char *value) {
    
    BinaryNodeTree * bnt = (BinaryNodeTree*) malloc (sizeof (BinaryNodeTree));
    if (!bnt) {
        return NULL;
        }

    bnt->key = (char*) malloc (strlen (key) + 1);
    strcpy (bnt->key, key);
    ...
    
    bnt->left = bnt->right = NULL;
    
    return bnt;
}


void InsertValueByKey (BinaryNodeTree *root, char *key, char *value) {
    
    if (strcmp (root->key, key) <= 0) {
        if (root->left) {
            InsertValueByKey (root->left, key, value);
            }
        else {
            root->left = CreateBinaryNodeTree (key, value);
            }
        }
    else {
        ...
        }
    
}


BinaryNodeTree *FindNodeByKey (BinaryNodeTree *root, char *key) {

BinaryNodeTree *currentNode = root;
    
    while (1) {
        if (!currentNode) {
            return NULL;
            }
        int res = strcmp (key, currentNode->key);
        if (!res) {
            return currentNode;
            }
        if (res < 0) {
            currentNode = currentNode->left;
            }
        else {
            currentNode = currentNode->right;
            }

    }
}


char * FindValueByKey (BinaryNodeTree *root, char *key) {
    
    BinaryNodeTree *bnt = FindNodeByKey (root, key);
    
    if (!bnt) {
        return NULL;
        }
    return bnt->value;
}

