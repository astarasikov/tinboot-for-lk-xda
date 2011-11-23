@
@ This script wraps LK bootloader to the CE XIP format
@ (C) 2011 Alexander Tarasikov <alexander.tarasikov@gmail.com>
@ based on Tinboot which is (C) Martin Johnson - M.J.Johnson@massey.ac.nz
@
.equ    LOAD_START,     0x01600000
.equ	TARGET_ADDR, 	0x00000000

.macro _DSB
	@dsb
	mov r0, #0
	mcr p15, 0, r0, c7, c10, 4
.endm

.macro vibrate
	ldr r0, gpio_base_addr
	ldr r1, [r0]
	orr r1, r1, #0x1000000
	str r1, [r0]
.endm

@works without this, but liberty bootloader does it
.macro msm_hax
		@aux control
		@mrc p15, 0, r0, c1, c0, 1
		@orr r0, r0, #0x80000000
		@mcr p15, 0, r0, c1, c0, 1

		_DSB

		@control - enable FIQ
		@mrc p15, 0, r0, c1, c0, 0
		@orr r0, r0, #0x200000
		@mcr p15, 0, r0, c1, c0, 0
		@
		@_DSB

		@remap 2GB@0x80000000 peripheral port
		ldr r0, =0x80000016
		mcr p15, 0, r0, c15, c2, 4

		@unused
		@vibrate
.endm

		.org 0
		b boot

		.org 0x40
		.word 0x43454345
		.word romhdr+0x81500000				@ location of wince romhdr
		.word romhdr

		.org 0x00001000
		b boot

		.org 0x00001010
		.asciz "1.42.13.37"

		.org 0x00001020

boot:
		msm_hax

		@ldr r0,smi_mpu_addr @disable MPU to allow us to copy the bootloader
		@mov r1, #0
		@str r1, [r0]

		ldr r0,blob_ptr
		ldr r1,target_addr_ptr
		ldr r3,blobend_ptr

copycode:
		ldr r2,[r0],#4
		str r2,[r1],#4
		cmp r0,r3
		blo copycode

		mov pc, #0

gpio_base_addr:
		.word 0xa9200808 
smi_mpu_addr:
		.word 0xa8250800
blob_ptr:
		.word LOAD_START + kernel
target_addr_ptr:
		.word TARGET_ADDR
blobend_ptr:
		.word LOAD_START + blobend

romhdr:
		.word 0x0		@ dllfirst
		.word 0x0		@ dlllast
		.word 0x81500000	@ physfirst
		.word 0x81500000+blobend	@ physlast
		.word 0			@ num mods
		.word 0x81500000+blobend	@ ramstart
		.word 0x81500000	@ ramfree
		.word 0x8c800000	@ ramend
		.word 0			@ copyentries
		.word 0x81500000	@ copyoffset
		.word 0			@ profilelen
		.word 0			@ profileoffset
		.word 0			@ numfiles
		.word 0			@ flags
		.word 0x20		@ fsrampercent
		.word 0			@ drvglobstart
		.word 0			@ drvgloblen
		.word 0x201c2		@ cputype/flags
		.word 0x81500000	@ pextensions
		.word 0			@ trackingstart
		.word 0			@ trackinglen

		.align 12
kernel:
		.incbin "lk.bin"
		.align
blobend:
		.end
