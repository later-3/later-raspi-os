# exception_level
arm编程手册中`Fundamentals of ARMv8`介绍了关于异常级别相关内容。Exception level determines the privilege level, so execution at ELn corresponds to privilege PLn. Exception levels provide a logical separation of software execution privilege that applies across all operating states og the ARMv8 architecture. It is similar to, and supports the concept of, hierarchical protection domains common in computer science.

The following is a typical example of what software runs at each Exception level:
EL0 Normal user applications.
EL1 Operating system kernel typically described as privileged.
EL2 Hypervisor.
EL3 Low-level firmware, including the Secure Monitor.

# Execution states
The ARMv8 architecture defines two Execution States, AArch64 and Arch32. Each state is used to describe execution using 64-bit wide general-purpose registers or 32-bit wide general-purpose registers, respectively. While ARMv8 AArch32 retains the ARMv7 definitions
of privilege, in AArch64, privilege level is determined by the Exception level. Therefore,
execution at ELn corresponds to privilege PLn.

When in AArch64 state, the processor executes the A64 instruction set. When in AArch32 state,
the processor can execute either the A32 (called ARM in earlier versions of the architecture) or
the T32 (Thumb) instruction set.

# changing Exception levels
 ![](https://raw.githubusercontent.com/later-3/img_picgo/main/img/20240605213511.png)

When an exception occurs, the core saves the
current execution state and the return address, enters the required mode, and possibly disables
hardware interrupts.(ARMv7)

Movement between Exception levels follows these rules:
• Moves to a higher Exception level, such as from EL0 to EL1, indicate increased software
execution privilege.
• An exception cannot be taken to a lower Exception level.
• There is no exception handling at level EL0, exceptions must be handled at a higher
Exception level.
• An exception causes a change of program flow. Execution of an exception handler starts,
at an Exception level higher than EL0, from a defined vector that relates to the exception
taken. Exceptions include:
— Interrupts such as IRQ and FIQ.
— Memory system aborts.
— Undefined instructions.
— System calls. These permit unprivileged software to make a system call to an
operating system.
— Secure monitor or hypervisor traps.

• Ending exception handling and returning to the previous Exception level is performed by
executing the ERET instruction.

• Returning from an exception can stay at the same Exception level or enter a lower
Exception level. It cannot move to a higher Exception level.

• The security state does change with a change of Exception level, except when retuning
from EL3 to a Non-secure state. See Switching between Secure and Non-secure state on
page 17-8.

# changing execution state
There are times when you must change the execution state of your system. This could be, for
example, if you are running a 64-bit operating system, and want to run a 32-bit application at
EL0. To do this, the system must change to AArch32.

When the application has completed or execution returns to the OS, the system can switch back
to AArch64. Figure 3-7 on page 3-9 shows that you cannot do it the other way around. An
AArch32 operating system cannot host a 64-bit application.

![](https://raw.githubusercontent.com/later-3/img_picgo/main/img/20240605215125.png)

To change between execution states at the same Exception level, you have to switch to a higher
Exception level then return to the original Exception level. For example, you might have 32-bit
and 64-bit applications running under a 64-bit OS. In this case, the 32-bit application can
execute and generate a Supervisor Call (SVC) instruction, or receive an interrupt, causing a
switch to EL1 and AArch64. (See Exception handling instructions on page 6-21.) The OS can
then do a task switch and return to EL0 in AArch64. Practically speaking, this means that you
cannot have a mixed 32-bit and 64-bit application, because there is no direct way of calling
between them.

You can only change execution state by changing Exception level. Taking an exception might
change from AArch32 to AArch64, and returning from an exception may change from AArch64
to AArch32.

Code at EL3 cannot take an exception to a higher exception level, so cannot change execution
state, except by going through a reset.

# EL2 and EL1 change
## system register
In AArch64, system configuration is controlled through system registers, and accessed using
MSR and MRS instructions. The name of a register tells you the lowest
Exception level that it can be accessed from.

For example:
• TTBR0_EL1 is accessible from EL1, EL2, and EL3.
• TTBR0_EL2 is accessible from EL2 and EL3.

Registers that have the suffix _ELn have a separate, banked copy in some or all of the levels,
though usually not EL0. Few system registers are accessible from EL0, although the Cache Type
Register (CTR_EL0) is an example of one that can be accessible.

Code to access system registers takes the following form:
MRS x0, TTBR0_EL1 // Move TTBR0_EL1 into x0
MSR TTBR0_EL1, x0 // Move x0 into TTBR0_EL1

AArch64 does not include support for coprocessors. 

