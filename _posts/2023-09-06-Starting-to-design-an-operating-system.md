---
layout: post
author: Jacob Garby
---

Making an operating system is a project I've been looking at for a while now, and I've given it a few attempts. This is the first in a series of posts about how I'm making a new one, from scratch. In this post I'm 

## What is an operating system for?

An operating system can be simply thought of as a collection of software that makes it easier for applications to run on a computer. This usually consists of:

 - Some way for applications to access hardware devices (such as keyboards, mice, network interfaces, storage, etc.,)
 - A filesystem that applications can use to persistently store data, and share that data so that it can be accessed from other applications.
 - A system that facilitates a large number of applications running at the same time on the computer, while managing the computer's resources.

### As an Interface Between Application Software and Hardware

A computer invariably has a lot of different hardware attached to it, of all different types, brands, and models. This includes keyboards, mice, network interfaces, storage devices, graphics cards, and more. Within each of these broad categories of device, there is also a lot of variation. For instance, there are many different chipsets that network interface cards use, and importantly each of these chipsets expects to communicate with the processor in different ways.

An operating system means that people writing applications don't need to understand and implement all of these standards. It would be annoying if developing a web browser involved reading hundreds of pages of NIC specifications, for example.

In fact, not only do developers not need to implement the interfaces for all of these peripherals themselves, but they don't even need to know that the computer which their software is running on even has different physical hardware than their own (most of the time). The operating system can provide a transparent interface for communicating with, say, a _generic_ NIC, or a _generic_ storage device.

There's also a security benefit. If applications had to interact with hardware directly, they would need full access to the computer's various IO buses. This would give them the unrestrictied ability to use the computer's hardware in nefarious ways (for example reading arbitrary blocks of a disk to see confidential information). The operating system layer provides an access control mechanism: applications can request that the operating system communicates with some hardware, but the operating system can refuse to do so, or do so in a restricted way, if needed.

### As a Manager of System Resources

Distinct from hardware attached to the computer are the system's two core resources: processing power and memory.

Imagine a 4GHz 64-bit processor attached to 32GB of memory. Theoretically, these two components are all that are needed for a working computer system (and for some microcontrollers, these are all that are present).

Every computer has an internal clock that times the execution of instructions and makes sure everything runs synchronously. This computer's clock "ticks" four billion times a second. On complex modern processor architectures (like x86-64), it's difficult to say how many ticks each instruction will take to complete, because different instructions take vastly different times. Also, modern processors use pipelining which allows several instructions to be processed in an overlapping manner. Either way, there is a particular amount of "processing power" which a CPU is capable of.

Memory is simply a volatile store of data, which running code can use to store temporary values. Some CPU instructions directly access memory (for example `MOV`, which is capable of moving a word of data from memory into a CPU register and vice versa). There is a limited amount of memory available on a given system.

One of the most important things the operating system does is managing these two resources. If there are a number of applications running on a computer, the amount of memory they use must be monitored to make sure no one process uses an unfair share. Additionally, the specific memory which each process is allowed to access has to be controlled by the operating system to make sure processes can't access each others' sensitive information.

In a similar way, the CPU's processing power is shared between all the currently running processes. A (single core) CPU is only capable of running on process at any given time, so the processing power is shared by _scheduling_ the processes. This refers to rapidly switching which process is running on the CPU, which gives the illusion of all of the processes running at the same time.

If you consider the input/output buses of a computer to be system resources too, then you can generalise a huge amount of what the operating system has to do as managing different types of resources in specialised ways.

## From an application programmer's point of view

To see how an operating is useful, and get a better idea of exactly what it does, let's look at how an application program uses it. I'll look specifically at Linux here, and examine the program `cat`, which by default (if given a filename) will output its contents.

To see how it does this, in terms of interacting with the OS, we'll use the `strace` command to record which syscalls the process uses. Syscalls (short for system calls) are the mechanism by which processes invoke the operating system to do things for them. Linux implements a lot of syscalls, and they include common functions such as opening, closing, reading and writing files, spawning new processes, and communicating between processes.

If you want to try this experiment for yourself, you'll need a Linux system (a virtual machine is fine), and the `strace` application installed. If you're on Arch Linux (or most distributions, I imagine), it exists on your package manager simply called "strace". 

According to its man page:

_In the simplest case strace runs the specified command until it exits. It intercepts and records the system calls which are called by a process and the signals which are received by a process. The name of each system call, its arguments and its return value are printed on standard error or to the file specified with the -o option._

So, if I create a file named `test.txt` and run the command `strace cat test.txt`, I get this result:

```
execve("/usr/bin/cat", ["cat", "test.txt"], 0x7ffd91379fc8 /* 93 vars */) = 0
brk(NULL)                               = 0x5578e5dc6000
arch_prctl(0x3001 /* ARCH_??? */, 0x7fff7623ddc0) = -1 EINVAL (Invalid argument)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=193595, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 193595, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3b7b19d000
close(3)                                = 0
openat(AT_FDCWD, "/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220~\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=2366592, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3b7b19b000
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 2411920, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f3b7ae00000
mmap(0x7f3b7ae26000, 1437696, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x26000) = 0x7f3b7ae26000
mmap(0x7f3b7af85000, 348160, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x185000) = 0x7f3b7af85000
mmap(0x7f3b7afda000, 417792, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1d9000) = 0x7f3b7afda000
mmap(0x7f3b7b040000, 52624, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f3b7b040000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3b7b198000
arch_prctl(ARCH_SET_FS, 0x7f3b7b198740) = 0
set_tid_address(0x7f3b7b198a10)         = 56166
set_robust_list(0x7f3b7b198a20, 24)     = 0
rseq(0x7f3b7b199060, 0x20, 0, 0x53053053) = 0
mprotect(0x7f3b7afda000, 409600, PROT_READ) = 0
mprotect(0x5578e591e000, 4096, PROT_READ) = 0
mprotect(0x7f3b7b1fe000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
munmap(0x7f3b7b19d000, 193595)          = 0
getrandom("\x3c\x17\x4e\xc3\xd1\x31\xfc\x0f", 8, GRND_NONBLOCK) = 8
brk(NULL)                               = 0x5578e5dc6000
brk(0x5578e5de7000)                     = 0x5578e5de7000
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=6006304, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 6006304, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3b7a800000
close(3)                                = 0
newfstatat(1, "", {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0x3), ...}, AT_EMPTY_PATH) = 0
openat(AT_FDCWD, "test.txt", O_RDONLY)  = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=14, ...}, AT_EMPTY_PATH) = 0
fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3b7b1ab000
read(3, "Hello, world!\n", 131072)      = 14
write(1, "Hello, world!\n", 14Hello, world!
)         = 14
read(3, "", 131072)                     = 0
munmap(0x7f3b7b1ab000, 139264)          = 0
close(3)                                = 0
close(1)                                = 0
close(2)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

This looks like a list of function calls, and each of these function calls represents one call to a Linux syscall, followed by the return value. For a lot of syscalls, the return value is some status code, but there are exceptions. The `open` and `openat` syscalls (which open a file) return a file descriptor of the newly opened file, for example.

A lot of the syscalls in this output are to do with loading shared libraries (specifically libc, the C standard library), and setting up memory maps to allow the `cat` program to use these. Let's look at the most interesting/relevant syscalls.

```
execve("/usr/bin/cat", ["cat", "test.txt"], 0x7ffd91379fc8 /* 93 vars */) = 0
```

The `execve()` syscall executes a program file, not by spawning a new process but by changing the image of the current process to the new one. This is run by the shell (bash, zsh, etc.) normally, when you type `cat test.txt` in a terminal. In our case, this call is actually made by strace. In either case, the shell or strace forks itself (spawning a new identical process) and then calls `execve()` as the newly spawned one.

The first parameter is the path to the `cat` executable, and the second parameter is an array of the command-line arguments for the program. By convention, the first argument is always the name of executable in the format it was invoked (i.e. if you run `cat test.txt` the first argument will be "cat", but if you run `/usr/bin/cat test.txt` the first argument will be "/usr/bin/cat"). The third parameter is an array of strings corresponding to the environment variables.

```
openat(AT_FDCWD, "test.txt", O_RDONLY)  = 3
```

This is the first syscall corresponding to an operating that we expect cat to do, which is opening the file that it's told to read. `openat()` is similar to the more common `open()` syscall. It opens a file (in this case "test.txt") with specific access permissions (in this case `O_RDONLY`, which means read-only). 

The addition of `openat()` is the first parameter. This can be set as a file descriptor referring to a directory, in which case the syscall will lookup relative file paths with respect to that directory. If `AT_FDCWD` is passed instead of a file descriptor, the current working directory (CWD) is used as the base directory for relative file paths.

```
read(3, "Hello, world!\n", 131072)      = 14
write(1, "Hello, world!\n", 14Hello, world!
)         = 14
read(3, "", 131072)                     = 0
```

I'm grouping these three calls together as they work in similar ways, and also are probably familiar to lots of people anyway.

First, note that the `openat()` call returned 3, so any references to the file descriptor 3 are referring to that file.

So, the first `read()` syscall is reading up to 131,072 bytes of data from our test.txt file. For this particular case, I'll talk about how exactly this happens at all levels of the computer.

### How the `read()` syscall works

A user application invokes a system call by putting specific values in a few system registers and then making a software interrupt with a specific interrupt number. On Linux, the interrupt number for syscalls is 0x80. The value of the register RAX determines which syscall is invoked.

For a `read()` syscall, RAX must be 0. RDI, RSI, and RDX must be set to represent the parameters of the syscall. RDI is the file descriptor, RSI is the buffer to read data into, and RDX is the maximum amount of bytes to try and read.

When this interrupt is processed, the processor switches from user mode to kernel mode. In this mode, kernel code can be executed (it cannot be in user mode for security reasons), and the kernel's data can be accessed. Additionally, the CPU has full access to hardware I/O, again unlike in user mode.

As well as switching modes, the interrupt causes the CPU to look up the index 0x80 in the interrupt descriptor table, which the kernel has already set up in memory prior to this. The matching entry in the table tells the CPU which address in memory to jump to to serve this interrupt. In this case, for Linux, it is [a piece of kernel code](https://elixir.bootlin.com/linux/latest/source/arch/x86/entry/entry_64.S#L87) which eventually runs one of many functions from a syscall table.

So here the kernel's `read()` syscall handler function is called, which will look at the supplied file descriptor to make sure it's a valid opened file that has read access. It will then call the kernel virtual filesystem function [`vfs_read()`](https://elixir.bootlin.com/linux/latest/source/fs/read_write.c#L450) after finding the `struct file` corresponding to the given file descriptor. This structure represents an opened file, containing (to name a few) its mode (i.e. read/write), its owner, and importantly for us a [`struct file_operations *`](https://elixir.bootlin.com/linux/latest/source/include/linux/fs.h#L1774) member, which contains functions for how this file is operated on, including reading, writing, and many more. These functions are implemented by the filesystem which the file is in.

The filesystem's `read()` function is responsible for taking raw data from the disk [^1], interpreting it into structured file data, and handling operations on it. For this, the kernel needs to read data from a physical "block device".

A block device is a data storage device which can present data in fixed size blocks. This is true of all mass storage devices, like hard drives, SSDs, flash drives, etc. Each type of drive (or equivalently, each different drive interface type) has its own driver code, either as an integrated part of Linux, or as a module loaded on top.

Now, at the lowest level, the required blocks of raw data are read from the correct disk (if the data is not already cached in memory). The filesystem code then interprets this data as needed, and fills a kernel buffer with a sequence of bytes from the file. The kernel can then write the data from this buffer to the userspace buffer provided in the read syscall parameter.

The operation of the `write()` syscall works in a similar way to the `read()` syscall. Hopefully this brief overview gives you some idea of how the operating system is useful: it allows programs to interact with hardware in a structured and uniform way, while also limiting that which they access.

[^1]: _Usually_ raw data from a disk, but depending on the filesystem it could also be data read over the internet (for example sshfs), or data entirely fabricated in software (for example sysfs)