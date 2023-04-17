// Node struct for the linked list.
	.struct		0
ListNode:
	value:		.hword	0
	link:		.quad	0
	.equ		NodeSize, .-ListNode

	.data
	// Head pointer
	Head:		.quad	0
	// Node buffer
	Nodes:		.skip	100 * NodeSize
	FreePtr:	.quad	Nodes

	.text
	.global 	main
	.arch 		armv8-a+fp+simd
	.type 		main, %function
	.type		insert, %function
	.type		remove,	%function

// Entrypoint
main:
	MOV		X0, #5
	BL		insert

// Inserts a value into the list, according to an ascending sort.
// Input: a 16-bit data value (hword) passed in X0, to be inserted into the list.
// Returns: a 64-bit address of the newly created node, passed in X0.
insert:

	insert_loop:

// Removes the first instance of a value in the list.
// Input: a 16-bit data value (hword) passed in X0, to be removed from the list.
// Returns: 1 if the value was found, 0 otherwise, passed in X0.
remove:
