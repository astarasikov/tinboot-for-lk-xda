@
@ Tinboot for HTC Photon
@ Alexander Tarasikov - alexander.tarasikov@gmail.com
@ based on tinboot for HTC Vogue by
@ Martin Johnson - M.J.Johnson@massey.ac.nz
@

.equ	CE_LOAD_VIRT,			0x81500000

.if 1
	.equ	CE_LOAD_PHYS,			0x01600000
	.equ	DST_ADDR, 				0x00200000
	.equ	RAM_SIZE, 				0x0b100000
.else
	.equ	CE_LOAD_PHYS,			0x00208000
	.equ	DST_ADDR, 				0x03200000
	.equ	RAM_SIZE, 				0x09100000
.endif

.equ	TAGS_OFFSET,			0x100
.equ	KERNEL_OFFSET,			0x8000
.equ	INITRD_OFFSET,			0x800000

.equ	MTYPE,					3162

.macro copy dst src src_end
	ldr r0, \dst
	ldr r1, \src
	ldr r2, \src_end
	bl copyloop
.endm

.macro _DSB
	@dsb
	mov r0, #0
	mcr p15, 0, r0, c7, c10, 4
.endm

	.org 0
	b boot

	.org 0x40
	.word 0x43454345
	.word romhdr+CE_LOAD_VIRT				@ location of wince romhdr 
	.word romhdr

	.org 0x100
tags:
	.word 5,0x54410001,1,0x1000,0 			@ ATAG_CORE, pagesize=4K
	.word 4,0x54410002,RAM_SIZE,DST_ADDR		@ ATAG_MEM
	.word 4,0x54420005,initrd_dst,initrd_end - initrd	@ ATAG_INITRD2
cmdline_start:
	.word (cmdline_end-cmdline_start+3)/4,0x54410009	@ ATAG_CMDLINE
	.asciz "rw mtdparts=msm_nand:0x00300000@0x02820000(boot)"

	.align
cmdline_end:
	.word 0,0					@ ATAG_END
tags_end:

	.org 0x00001000
	b boot

	.org 0x00001010
	.asciz "1.42.13.37"

	.org 0x00001020

boot:
	b do_boot

copyloop:
	ldr r3, [r1], #4
	str r3, [r0], #4
	cmp r1, r2
	blo copyloop
	bx lr

do_boot:
	_DSB

	@remap 2GB@0x80000000 peripheral port
	ldr r0, periph_cfg
	mcr p15, 0, r0, c15, c2, 4

	copy kernel_dst, kernel_src, kernel_src_end
	copy initrd_dst, initrd_src, initrd_src_end
	copy tags_dst, tags_src, tags_src_end

	mov r0, #0
	ldr r1, mtype
	ldr r2, tags_dst
	ldr pc, kernel_dst

periph_cfg:
	.word 0x80000016
mtype:
	.word MTYPE
initrd_dst:
	.word DST_ADDR + INITRD_OFFSET
kernel_dst:
	.word DST_ADDR + KERNEL_OFFSET
tags_dst:
	.word DST_ADDR + TAGS_OFFSET
initrd_src:
	.word CE_LOAD_PHYS + initrd
initrd_src_end:
	.word CE_LOAD_PHYS + initrd_end
kernel_src:
	.word CE_LOAD_PHYS + kernel
kernel_src_end:
	.word CE_LOAD_PHYS + kernel_end
tags_src:
	.word CE_LOAD_PHYS + tags
tags_src_end:
	.word CE_LOAD_PHYS + tags_end

romhdr:
	.word 0x0		@ dllfirst
	.word 0x0		@ dlllast
	.word CE_LOAD_VIRT	@ physfirst
	.word CE_LOAD_VIRT+fin	@ physlast
	.word 0			@ num mods
	.word CE_LOAD_VIRT+fin	@ ramstart
	.word CE_LOAD_VIRT	@ ramfree
	.word CE_LOAD_VIRT+RAM_SIZE	@ ramend
	.word 0			@ copyentries
	.word CE_LOAD_VIRT	@ copyoffset
	.word 0			@ profilelen
	.word 0			@ profileoffset
	.word 0			@ numfiles
	.word 0			@ flags
	.word 0x20		@ fsrampercent
	.word 0			@ drvglobstart
	.word 0			@ drvgloblen
	.word 0x201c2		@ cputype/flags
	.word CE_LOAD_VIRT	@ pextensions
	.word 0			@ trackingstart
	.word 0			@ trackinglen

	.align 12
kernel:
	.incbin "Image"
kernel_end:
	.align 12
initrd:
	.incbin	"initrd"
initrd_end:
	.align
fin:
