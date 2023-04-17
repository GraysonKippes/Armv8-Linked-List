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
	// X9 holds the current node to check.
	MOV		X9, Head
	insert_loop:
	// Case 1: if the pointer to the current node is 0, that means the end of the list has been reached. Insert the node now.
	CBZ		X9, insert_end

	// Go here if inserting in the middle of the list.
	insert_middle:
	RET

	// Go here if inserting at the end of the list.
	insert_end:
	// Create a new node.
	MOV		X10, FreePtr	// Get the address of the next available node.
	STRH	W0, [X10]		// Set the value field.
	// Return the pointer to the newly created node.
	MOV		X0, FreePtr
	// Allocate memory for another node (10 bytes) on the node buffer.
	//ADD			FreePtr, FreePtr, #10
	RET

// Removes the first instance of a value in the list.
// Input: a 16-bit data value (hword) passed in X0, to be removed from the list.
// Returns: 1 if the value was found, 0 otherwise, passed in X0.
remove:
