#include <windows.h>
#include <regex.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#define MAXKEYS 4096

#define ISNUM(c) (('0' <= c && '9' >= c) \
                    || ('A' <= c && 'Z' >= c) \
                    || ('a' <= c && 'z' >= c))

#define ISALPHANUM(c) (('0' <= c && '9' >= c) \
                    || ('A' <= c && 'Z' >= c) \
                    || ('a' <= c && 'z' >= c))

typedef unsigned int vk_t;

typedef struct __opts {
    vk_t keys[MAXKEYS];
    ssize_t n_keys;
    HWND win;
} opts_t;

#define EQ(str) !strcasecmp(name, str)

vk_t name_to_vk(char *name)
{
    if (EQ("tab"))
        return VK_TAB;
    if (EQ("space"))
        return VK_SPACE;
    if (strlen(name) == 1 && ISALPHANUM(name[0]))
        return name[0];
    return 0;
}

void post_key(HWND hwnd, vk_t vk)
{
    LPARAM lp = 1 | (MapVirtualKey(vk, 0) << 16);
    PostMessage(hwnd, WM_KEYDOWN, vk, lp);
    PostMessage(hwnd, WM_CHAR, '1', 0);
    PostMessage(hwnd, WM_KEYUP, vk, (1 << 31) | lp);
}

void add_key(opts_t *opts, char *name)
{
    vk_t key = name_to_vk(name);
    if (key == 0) {
        fprintf(stderr, "No such key: %s\n", name);
        exit(1);
    }
    opts->keys[opts->n_keys++] = key;
}

char *search_str;
char buff[1024];

BOOL CALLBACK find_name_cb(HWND hwnd, LPARAM lparam)
{
    HWND *hwnd_p = (HWND *) lparam;
    regex_t regex;
    GetWindowText(hwnd, buff, sizeof(buff)-1);
    if (!strcasecmp(search_str, buff)) {
        *hwnd_p = hwnd;
        return FALSE;
    }
    else if (!regcomp(&regex, search_str, REG_NOSUB)
          && !regexec(&regex, buff, sizeof(buff)-1, NULL, 0)) {
        *hwnd_p = hwnd;
        return FALSE;
    }
    else
        return TRUE;
}

void find_name(opts_t *opts, char *name)
{
    search_str = name;
    if (EnumWindows(find_name_cb, (LPARAM) &opts->win)) {
        fprintf(stderr, "No window with name: %s\n", name);
        exit(1);
    }
}

BOOL CALLBACK find_class_cb(HWND hwnd, LPARAM lparam)
{
    HWND *hwnd_p = (HWND *) lparam;
    regex_t regex;
    GetClassName(hwnd, buff, sizeof(buff)-1);
    if (!strcasecmp(search_str, buff)) {
        *hwnd_p = hwnd;
        return FALSE;
    }
    else if (!regcomp(&regex, search_str, REG_NOSUB)
          && !regexec(&regex, buff, sizeof(buff)-1, NULL, 0)) {
        *hwnd_p = hwnd;
        return FALSE;
    }
    else
        return TRUE;
}

void find_class(opts_t *opts, char *class)
{
    search_str = class;
    if (EnumWindows(find_class_cb, (LPARAM) &opts->win)) {
        fprintf(stderr, "No window with class: %s\n", class);
        exit(1);
    }
}

opts_t parse_args(int argc, char **argv)
{
    opts_t opts = { .n_keys = 0, 
                    .win = 0 };
    char *keyname;
    while (argc > 0) {
        if (!strcmp(argv[0], "-key")) {
            keyname = strtok(argv[1], ",");
            add_key(&opts, keyname);
            while (NULL != (keyname = strtok(NULL, ",")))
                add_key(&opts, keyname);
            argc -= 2;
            argv += 2;
        }
        else if (!strcmp(argv[0], "-name")) {
            find_name(&opts, argv[1]);
            argc -= 2;
            argv += 2;
        }
        else if (!strcmp(argv[0], "-class")) {
            find_class(&opts, argv[1]);
            argc -= 2;
            argv += 2;
        }
        else {
            fprintf(stderr, "invalid option: %s\n", argv[0]);
            exit(1);
        }
    }

    if (!opts.win)
        opts.win = GetFocus();

    if (!opts.win)
        opts.win = GetForegroundWindow();

    return opts;
}

int main(int argc, char **argv)
{
    opts_t opts = parse_args(argc-1, argv+1);

    int i;
    for(;;) {
        for (i = 0; i < opts.n_keys; i++) {
            post_key(opts.win, opts.keys[i]);
            usleep(30000);
        }
    }

    return 0;
}
