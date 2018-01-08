#include <windows.h>
#include <stdio.h>
#include <unistd.h>

#define STRL 1024

typedef struct __block {
    char hwnd[STRL+1];
    char class[STRL+1];
    char name[STRL+1];
    struct __block *children;
    size_t children_size;
    size_t n;
} block_t;

#define NULL_BLOCK ((block_t) { .hwnd = "", .class = "", .name = "", .children = NULL, .children_size = 0, .n = 0 })

block_t new_block(HWND);

void free_block(block_t block)
{
    int i;
    for (i = 0; i < block.n; i++) {
        free_block(block.children[i]);
    }
    free(block.children);
}

void __print_block(int n, int marg0, int marg1, block_t block)
{
    // printf("%*s%*s \"%*s\" \"%s\"\n", n, "", marg0, block.hwnd, marg1, block.class, block.name);
    printf("%*s%-*s %-*s %s\n", n, "", marg0, block.hwnd, marg1, block.class, block.name);
    // printf("%*s%*s\n", n, "", marg0, block.hwnd);
    int i;
    size_t _marg0 = 0, _marg1 = 0, len;
    for (i = 0; i < block.n; i++) {
        if ((len = strnlen(block.children[i].hwnd, STRL)) > _marg0)
            _marg0 = len;
        if ((len = strnlen(block.children[i].class, STRL)) > _marg1)
            _marg1 = len;
    }
    for (i = 0; i < block.n; i++) {
        __print_block(n+2, _marg0, _marg1, block.children[i]);
    }
}

void print_block(block_t block)
{
    __print_block(0, 0, 0, block);
}

BOOL CALLBACK PrintWindowProps(HWND hwnd, LPARAM lParam)
{
    static char class[2048], name[2048];
    GetClassName(hwnd, class, sizeof(class) - 1);
    GetWindowText(hwnd, name, sizeof(name) - 1);
    printf("%p \"%s\" \"%s\"\n", (void *) hwnd, class, name);
    return TRUE;
}

BOOL CALLBACK fill_block(HWND hwnd, LPARAM lParam)
{
    block_t *block = (block_t *) lParam;
    size_t n = block->n++;
    if (n == block->children_size)
        block->children = realloc(block->children, 1 + block->children_size * 2);
    block->children[n] = new_block(hwnd);
    // printf("%s, %s\n", entries->strs[n][0], entries->strs[n][1]);
    return TRUE;
}

block_t new_block(HWND hwnd)
{
    block_t block = NULL_BLOCK;
    snprintf(block.hwnd, STRL, "%p", (void *) hwnd);
    GetClassName(hwnd, block.class, STRL);
    GetWindowText(hwnd, block.name, STRL);

    EnumChildWindows(hwnd, fill_block, (LPARAM) &block);

    return block;
}

block_t complete_block(void)
{
    HWND hwnd = GetDesktopWindow();
    return new_block(hwnd);
}

int main(void)
{
//     HWND root = GetDesktopWindow();
//     EnumChildWindows(root, PrintWindowProps, 0);
//     return 0;
    // complete_block();
    print_block(complete_block());
    return 0;
}
