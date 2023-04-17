// struct node
	.struct		0
ListNode:
	value:		.hword	0
	link:		.quad	0
	.equ		NodeSize, .-ListNode

// data
	.data
	Head:		.quad	0
	Nodes:		.skip	100 * NodeSize
	FreePtr:	.quad	Nodes

// code
	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function

main:
	ADR		X9, FreePtr
