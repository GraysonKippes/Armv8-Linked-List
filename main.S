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

// Entrypoint.
main:
	MOV		X0, #5
	BL		insert
	BL		main		// End here.

// Inserts a value into the list, according to an ascending sort.
// Input: a 16-bit data value (hword) passed in X0, to be inserted into the list.
// Returns: a 64-bit address of the newly created node, passed in X0.
insert:
	// Save the data value parameter.
	MOV		W19, W0
	// X9 holds the current node to check.
	LDR		X9, Head
	insert_loop:
	// Case 1: if the pointer to the current node is 0, that means the end of the list has been reached. Insert the node now.
	CBZ		X9, insert_end

	// Go here if inserting in the middle of the list.
	insert_middle:
	RET

	// Go here if inserting at the end of the list.
	insert_end:
	// Allocate space for a new node.
	LDR		X10, FreePtr
	MOV		X0, X10		// Pass the previous FreePtr, which now points to the new node.
	ADD		X10, X10, NodeSize
	ADR		X11, FreePtr	// Get the address of FreePtr and use it to store the incremented address into it.
	STR		X10, [X11]
	// Set the value of the new node.
	STR		W19, [X0, value]
	RET

// Removes the first instance of a value in the list.
// Input: a 16-bit data value (hword) passed in X0, to be removed from the list.
// Returns: 1 if the value was found, 0 otherwise, passed in X0.
remove:
