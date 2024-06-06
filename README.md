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

# 系统寄存器
列出此次操作的相关寄存器。

> ELR_ELn

Exception Link Register
Holds the address of the instruction which caused the exception. 1, 2, 3

> HCR_ELn 

Hypervisor Configuration Register
Controls virtualization settings and trapping of exceptions to EL2. See Exception handling on page 18-8

HCR_EL2:

E2H, bit [34]

In ARMv8.2 and ARMv8.1
EL2 Host. Enables a configuration where a Host Operating System is running in EL2, and the Host
Operating System's applications are running in EL0.

0 EL2 is running a hypervisor.

1 EL2 is running a Host Operating System.

In ARMv8.0.

Reserved,RES0

RW, bit [31]

Execution state control for lower Exception levels:

0 Lower levels are all AArch32.

1 The Execution state for EL1 is AArch64. The Execution state for EL0 is determined by
the current value of PSTATE.nRW when executing at EL0

TGE, bit [27]

Trap General Exceptions, from Non-secure EL0.

0 This control has no effect on execution at EL0.

1 When the value of SCR_EL3.NS is 0, this control has no effect on execution at EL0.
When the value of SCR_EL3.NS is 1, in all cases:
• All exceptions that would be routed to EL1 are routed to EL2.

处于el2，可以设置hcr_el2寄存器吗？

在EL2级别，可以设置HCR_EL2寄存器。 HCR_EL2寄存器是用于控制Hypervisor（虚拟机监控器）的一些特性和行为的寄存器。通过设置HCR_EL2寄存器，可以控制虚拟化扩展的一些行为，如使能虚拟中断、使能虚拟定时器等。

> SCR_ELn 

Secure Configuration Register
Controls Secure state and trapping of exceptions to EL3. See Handling synchronous exceptions on page 10-7. 3

Defines the configuration of the current Security state. It specifies:
• The Security state of EL0 and EL1, either Secure or Non-secure.
• The Execution state at lower Exception levels.
• Whether IRQ, FIQ, and External Abort interrupts are taken to EL3.

RW, bit [10]

Execution state control for lower Exception levels.

0 Lower levels are all AArch32.

1 The next lower level is AArch64.

SMD, bit [7]

Secure Monitor Call disable. Disables SMC instructions at EL1 and above, from both Security states
and both Execution states.

0 SMC instructions are enabled at EL1 and above.

1 SMC instructions are UNDEFINED at EL1 and above.

Note
SMC instructions are always UNDEFINED at EL0

NS, bit [0]

Non-secure bit.

0 Indicates that EL0 and EL1 are in Secure state, and so memory accesses from those
Exception levels can access Secure memory

1 Indicates that EL0 and EL1 are in Non-secure state, and so memory accesses from those
Exception levels cannot access Secure memory

> SCTLR_ELn

SCTLR_ELn System Control Register
Controls architectural features, for example the MMU, caches and alignment checking. 0, 1, 2, 3

> SPSR_ELn 

Saved Program Status Register
Holds the saved processor state when an exception is taken to this mode or Exception level.
abt, fiq, irq, und, 1,2, 3

> TCR_ELn 

Translation Control Register
Determines which of the Translation Table Base Registers define the base address for a translation table walk required for the stage 1 translation of a memory access from ELn. Also controls the translation table format and holds cacheability and shareability information. See Separation of kernel and application Virtual Address spaces on page 12-7. 1, 2, 3
TPIDR_ELn

> CNTHCTL, Counter-timer Hyp Control register

Purpose
Controls the generation of an event stream from the physical counter, and access from Non-secure
EL1 modes to the physical counter and the Non-secure EL1 physical timer.

Configurations
AArch32 System register CNTHCTL is architecturally mapped to AArch64 System register
CNTHCTL_EL2.
If EL2 is not implemented, this register is RES0 from EL3.
RW fields in this register reset to architecturally UNKNOWN values.

Attributes
CNTHCTL is a 32-bit register

> CNTHCTL_EL2, Counter-timer Hypervisor Control register

The CNTHCTL_EL2 characteristics are:

Purpose
Controls the generation of an event stream from the physical counter, and access from Non-secure
EL1 to the physical counter and the Non-secure EL1 physical timer.

Configurations
AArch64 System register CNTHCTL_EL2 is architecturally mapped to AArch32 System register
CNTHCTL.
If EL2 is not implemented, this register is RES0 from EL3.
RW fields in this register reset to architecturally UNKNOWN values.

Attributes
CNTHCTL_EL2 is a 32-bit register.



