---
layout: post
author: Jacob Garby
title: Implementing a Memory Allocator for My Own Operating System
---

If I'm writing some code for Linux (or other UNIXy systems) and I want to allocate a piece of memory at runtime, we all know that I can just use `malloc(n)`, along with `free(...)` to release the allocation. This neatly solves several problems for us, which can be a headache to implement from scratch:

 1) Dividing up the unstructured memory regions that the OS gives us into smaller sections.
 2) Keeping track of the length of allocated regions, to allow `free(...)` to function.
 3) Organising the allocations in an optimal way, that reduces the amount of _fragmentation_.

Unfortunately, I'm working on implementing [my own operating system](https://github.com/j4cobgarby/fors-kernel)
