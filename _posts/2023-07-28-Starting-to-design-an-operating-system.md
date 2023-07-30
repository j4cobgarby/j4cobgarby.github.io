Making an operating system is a project I've been looking at for a while now, and I've given it a few attempts. Each time, my code ends up getting really disorganised and difficult to add new features. This time, I'm going to thoroughly plan out as much as possible before starting any significant programming.

## What is an operating system for?

An operating system can be simply thought of as a collection of software that allows applications to run on a computer. This usually consists of:

 - Some way for applications to access hardware devices (such as keyboards, mice, network interfaces, storage devices, etc.,)
 - A filesystem that applications can use to persistently store data, and share that data so that it can be accessed from other applications.
 - A system that manages a large number of applications running at the same time on the computer.

Generally, operating systems are designed to run on a variety of CPU architectures. Common architectures today include x86-64, which is used by modern Intel and AMD CPUs; ARM, a family of CPU architectures including those used by the most recent Apple computers, as well as a lot of embedded computers like Raspberry Pis; and RISC-V, which is far newer than the other two, and at the moment is mostly used for some embedded systems. All of these architectures do things in quite different ways. For one, they all use different instruction sets, so ARM machine code would not work at all if executed on an x86 machine, for instance. There are more subtle differences too, for example the way they handle interrupts, the mechanisms they use to manage memory, and the way they provide low level access to hardware, to name a few.

A programmer wants their programs to be able to run on as many different computers as possible, to make sure that their effort programming them was as worthwhile as possible. Compilers help with this, allowing them to write their code in a high level language (like C or Rust), _compiling_ it into machine-readable code that can be understood by any specific type of CPU they want. This doesn't completely solve the problem though, as even though they can run their code on any of these processors, the specific semantics of each architecture, and the configuration of each computer, means that a given task (like waiting for a keyboard key to be pressed) may have to be implemented in completely different ways.

This is where the operating system comes in. It provides an architecture-specific _layer_ which provides functionality for applications to interact with generic _classes_ of hardware. For example, an application running on top of an operating system is able to send a piece of data out to the internet without knowing the specific model of network interface card installed on the computer. The programmers of the operating system still need to write a seperate implementation for each type of network interface card they want to support, which takes a lot of work, but this work then only needs to be done once, not again and again whenever a new programmer wants to use that piece of hardware.

## How do they work?

### From an application programmer's point of view