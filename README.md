# OS Dev Project

A learning experience working with OS development from the ground up on x86 architecture.

Contents:
```
|- src
|   |- boot.asm      # The x86 assembler source of the bootloader segment
|   |- main.rs       # The Rust source of the kernel
|- build.sh          # A shell script that builds the bootloader to bin/boot.bin
|- run.sh            # A shell script to run the bootloader in QEMU
```

## What? Why?
Why would anyone want to make an operating system from scratch? Doesn't that take hundreds 
of engineers?

Well, yes and no. Early operating systems like DOS and Unix were actually not as complicated
as one might think. I find it quite fascinating to follow in the footsteps of some of those 
early hackers who laid the foundations for the behemoths that we run from day to day.

I have no intentions of trying to replace Windows or Linux, however in the 
same way that a "todos" app can help with both broadening and deepening an individual's 
understanding of a framework or language, I believe that understanding modern PCs at a 
fundamental level makes for better decisions and problem solving skills when it comes to more 
practical endeavors.

## Requirements

A Linux-based host environment is _highly recommended_. In addition, the following tools will 
need to be installed to go about building and running the project:

- Netwide Assembler (nasm) or a syntax compatible assembler
- QEMU, another x86 emulator capable of loading a raw binary file, or a PC you _really_ don't need
- RustC, Cargo, and RustUp

# Building and running
The simplest way to get started is:
```bash
./build.sh && ./run.sh
```

To build the kernel:
```bash
cargo bootimage --release
```

And then run it with:
```bash
qemu-system-x86_64 -drive format=raw,file=target/x86_64-tos/release/bootimage-tos.bin
```