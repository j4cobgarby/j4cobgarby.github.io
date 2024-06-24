---
layout: post
author: Jacob Garby
title: Implementing a Memory Allocator for My Own Operating System
---

For an operating system kernel I'm working on ([on Github here](https://github.com/j4cobgarby/fors-kernel)), I needed to implement a memory allocator for the kernel's heap. In this context, I might mean three different things by a memory allocator:

 - Allocating page frames
 - Allocating virtual pages
 - Efficiently splitting up pages into smaller chunks

I'm mainly concerned with the third of these in this article; the other two are quite a lot simpler in my opinion, but do still have interesting complications, so I may well write about those at some later point. For now, I'll assume that the first two are already solved, which means that we can on demand allocate 4KB blocks of memory.
