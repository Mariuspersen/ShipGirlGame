#ifndef RLMEMORY
#define RLMEMORY

#include <stdio.h>

extern void* rlMalloc(size_t a0);
extern void* rlCalloc(size_t a0, size_t a1);
extern void* rlRealloc(void* a0, size_t a1);
extern void rlFree(void* ptr);
#define RL_MALLOC(sz) rlMalloc(sz)
#define RL_CALLOC(n,sz) rlCalloc(n,sz)
#define RL_REALLOC(ptr,sz) rlRealloc(ptr,sz)
#define RL_FREE(ptr) rlFree(ptr)

#endif
