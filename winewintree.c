#include <windows.h>
#include <stdio.h>
#include <unistd.h>

#define STRL 1024

typedef struct __block {
    char hwnd[STRL+1];
    char class[STRL+1];
    char name[STRL+1];
    struct __block *children;
    size_t n;
} block_t;

typedef struct {
    HWND hwnds[128];
    char strs[128][2][STRL+1];
    size_t n;
} entries_t;

void free_block(block_t block)
{
    int i;
    for (i = 0; i < block.n; i++) {
        free_block(block.children[i]);
    }
    free(block.children);
}

void __print_block(size_t n, size_t marg0, size_t marg1, block_t block)
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

BOOL CALLBACK fill_entries(HWND hwnd, LPARAM lParam)
{
    entries_t *entries = (entries_t *) lParam;
    size_t n = entries->n++;
    entries->hwnds[n] = hwnd;
    GetClassName(hwnd, entries->strs[n][0], STRL);
    GetWindowText(hwnd, entries->strs[n][1], STRL);
    return TRUE;
}

block_t new_block(HWND hwnd, char *class, char* name)
{
    block_t block = { .n = 0 } ;
    snprintf(block.hwnd, STRL, "%p", (void *) hwnd);
    strncpy(block.class, class, STRL);
    strncpy(block.name, name, STRL);

    entries_t entries = { .n = 0 };
    EnumChildWindows(hwnd, fill_entries, (LPARAM) &entries);

    if (entries.n > 0) {
        block_t *blocks = malloc(entries.n * sizeof(block_t));
        int i;

        for (i = 0; i < entries.n; i++) {
            blocks[i] = new_block(entries.hwnds[i], entries.strs[i][0], entries.strs[i][1]); 
        }
        block.n = entries.n;
        block.children = blocks; 
    }
    return block;
}

block_t complete_block(void)
{
    HWND hwnd = GetDesktopWindow();
    static char class[STRL+1], name[STRL+1];
    GetClassName(hwnd, class, STRL);
    GetWindowText(hwnd, name, STRL);
    return new_block(hwnd, class, name);
}

int main(void)
{
//     HWND root = GetDesktopWindow();
//     EnumChildWindows(root, PrintWindowProps, 0);
//     return 0;
    print_block(complete_block());
    return 0;
}
