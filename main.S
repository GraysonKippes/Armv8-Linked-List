// Node struct for the linked list.
	.struct		0
ListNode:
	value:		.hword	0
	link:		.quad	0
	.equ		NodeSize, .-ListNode

	.data
	// Head pointer.
	Head:		.quad	0
	// Node buffer.
	Nodes:		.skip	100 * NodeSize
	// Pointer to the next free node.
	FreePtr:	.quad	Nodes

	.text
	.global 	main
	.arch 		armv8-a+fp+simd
	.type 		main, %function
	.type		insert, %function
	.type		remove,	%function
	.type		alloc, %function

// Entrypoint.
main:
	MOV		X0, #5
	BL		insert
	LDR		X9, [X0, value]
	BL		main		// End here.

// Inserts a value into the list, according to an ascending sort.
// Input: a 16-bit data value (hword) passed in X0, to be inserted into the list.
// Returns: a 64-bit address of the newly created node, passed in X0.
insert:
	// Save the data value parameter.
	MOV		W19, W0
	// X9 holds the current node to check.
	LDR		X20, Head
	insert_loop:
	// Case 1: if the pointer to the current node is 0, that means the end of the list has been reached. Insert the node now.
	CBZ		X20, insert_end

	// Go here if inserting in the middle of the list.
	insert_middle:
	RET

	// Go here if inserting at the end of the list.
	insert_end:
	// Allocate space for a new node.
	MOV		X21, X30
	BL		alloc
	// Set the value of the new node.
	STR		W19, [X0, value]
	RET		X21

// Removes the first instance of a value in the list.
// Input: a 16-bit data value (hword) passed in X0, to be removed from the list.
// Returns: 1 if the value was found, 0 otherwise, passed in X0.
remove:

// Allocates a new node on the node buffer.
// Input: nothing.
// Uses: X9 for loading FreePtr into, and X10 for loading the address of FreePtr into.
// Returns: the address to the new node, passed in X0.
alloc:
	// Load FreePtr into X9.
	LDR		X9, FreePtr
	// Pass FreePtr into X0, before it gets incremented. After allocation, this address will point to the new node.
	MOV		X0, X9
	// Increment the FreePtr by NodeSize.
	ADD		X9, X9, NodeSize
	// Get the address of FreePtr and use it to store the incremented address into it.
	ADR		X10, FreePtr
	STR		X9, [X10]
	RET
