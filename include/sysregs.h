#ifndef _SYSREGS_H
#define _SYSREGS_H

// ***************************************
// SCTLR_EL1, System Control Register (EL1), Page 2654 of AArch64-Reference-Manual.
// ***************************************

#define SCTLR_RESERVED                  (3 << 28) | (3 << 22) | (1 << 20) | (1 << 11)
#define SCTLR_EE_LITTLE_ENDIAN          (0 << 25)
#define SCTLR_EOE_LITTLE_ENDIAN         (0 << 24)
#define SCTLR_I_CACHE_DISABLED          (0 << 12)
#define SCTLR_D_CACHE_DISABLED          (0 << 2)
#define SCTLR_MMU_DISABLED              (0 << 0)
#define SCTLR_MMU_ENABLED               (1 << 0)

#define SCTLR_VALUE_MMU_DISABLED	(SCTLR_RESERVED | SCTLR_EE_LITTLE_ENDIAN | SCTLR_I_CACHE_DISABLED | SCTLR_D_CACHE_DISABLED | SCTLR_MMU_DISABLED)

// ***************************************
// HCR_EL2, Hypervisor Configuration Register (EL2), Page 2487 of AArch64-Reference-Manual.
// ***************************************

#define HCR_RW	    			(1 << 31) // Execution state control for lower Exception levels:
                                            // 1 The Execution state for EL1 is AArch64.
                                            // 0 Lower levels are all AArch32.
#define HCR_VM                  (1 << 0)  // VM, bit [0]
                                          // Virtualization enable. Enables stage 2 address translation for the EL1&0 translation regime, when EL2 is enabled in the current Security state.
#define HCR2_VALUE			HCR_RW

// ***************************************
// SCR_EL3, Secure Configuration Register (EL3), Page 2648 of AArch64-Reference-Manual.
// ***************************************

#define SCR_SMD             (1 << 7) // Secure Monitor Call disable. SMC instructions are always UNDEFINED at EL0. 
#define SCR_HCE             (1 << 8) // Hypervisor Call instruction enable. HVC instructions are always UNDEFINED at EL0
#define SCR_RESERVED	    (3 << 4) // why? reserved
#define SCR_RW				(1 << 10) // Execution state control for lower Exception levels. aarch32 or aarch64
#define SCR_NS				(1 << 0) // Non-secure bit. When Secure state is not implemented, SCR_EL3.NS is RES1 and its effective value is 1.
#define SCREL3_VALUE	    	    	(SCR_RESERVED | SCR_RW | SCR_NS)

// ***************************************
// SPSR_EL3, Saved Program Status Register (EL3) Page 389 of AArch64-Reference-Manual.
// ***************************************

#define SPSR_MASK_ALL 			(7 << 6) // FIQ, bit [6] IRQ, bit [7]  A, bit [8]
#define SPSREL3_EL1h			(5 << 0) // M[3:0] AArch64 Exception level and selected Stack Pointer. 
                                    // 0b0101	EL1 with SP_EL1 (EL1h).
                                    // 0b1001	EL2 with SP_EL2 (EL2h).

#define SPSREL3_VALUE			(SPSR_MASK_ALL | SPSREL3_EL1h)

#define SPSREL2_M               (4 << 0) // 0b0100	EL1 with SP_EL0 (EL1t).                              
#define SPSREL2_D               (1 << 9) // Debug exception mask. 
                                         // Set to the value of PSTATE.
                                        //D on taking an exception to EL2, and copied to PSTATE.
                                        //D on executing an exception return operation in EL2, bit [9]
#define SPSREL2_VALUE			(SPSR_MASK_ALL | SPSREL2_M | SPSREL2_D)


// System Control Register (EL1)
#define SCTLR_EOS      (1 << 11)     //bit [11] EL1, 
//TSCXT, bit [20]
//EIS, bit [22]
//SPAN, bit [23]

#endif
