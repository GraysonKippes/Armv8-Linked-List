	.data
	.type	v, %object
	.size	v, 3

v:
	.xword	1, 2, 3

	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function

main:
	ADR		X9, v
	LDUR	X10, [X9, #0]
	LDUR	X11, [X9, #8]
	ADD		X10, X10, X11
	LDUR	X11, [X9, #16]
	ADD		X10, X10, X11
