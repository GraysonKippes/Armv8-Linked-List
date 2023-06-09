// Node struct for the linked list.
	.struct		0
ListNode:
	value:		.hword	0
	link:		.quad	0
	.equ		NodeSize, .-ListNode
	.equ		ValSize, .-value

	.data
	// Head pointer.
	Head:		.quad	0
	// Node buffer.
	Nodes:		.skip	128 * NodeSize
	// Pointer to the next free node.
	FreePtr:	.quad	Nodes

	// Output buffer.
	.equ		OutputSize, 128
	Output:		.skip	OutputSize * ValSize

	.text
	.global 	main
	.arch 		armv8-a+simd
	.type 		main, %function
	.type		insert, %function
	.type		remove,	%function
	.type		traverse, %function
	.type		search, %function
	.type		alloc, %function

// Entrypoint.
main:
	ADR		X11, FreePtr
	ADR		X12, Head
	// Insertion test.
	MOV		X0, #1
	BL		insert
	MOV		X0, #2
	BL		insert
	MOV		X0, #3
	BL		insert
	MOV		X0, #4
	BL		insert
	// Put contents into memory.
	BL		traverse
	ADR		X9, Output
	ADR		X10, Nodes
	// Remove test.
	MOV		X0, #3
	BL		remove
	MOV		X0, #5
	BL		insert
	// Put contents to memory.
	BL		traverse
	ADR		X9, Output
	ADR		X10, Nodes
	B		end		// End here.

// Inserts a value into the list, according to an ascending sort.
// Inputs: a 16-bit data value (hword) passed in X0, to be inserted into the list.
// Returns: a 64-bit address of the newly created node, passed in X0.
// Register usage:
//	W19 - stores the data value parameter.
//	X20 - holds the current node in list traversal.
//	X21 - holds the previous node in list traversal, or the address to the head node if inserting at the front of the list.
//	X22 - reset-head flag, indicates whether the head pointer must be reset to the new node because it is being inserted at the front of the list.
//	W23 - holds the value of the current node.
insert:
	// Push LR onto the stack.
	SUB		SP, SP, #16
	STUR	X30, [SP]

	// Save the data value parameter.
	MOV		W19, W0
	// X20 holds the current node to check.
	// X21 holds the previous node.
	ADR		X20, Head
	LDR		X20, [X20]
	// Insert-at-start flag: X22 is set to 1 if the new node will be the first node in the list.
	MOV		X22, #1

	// Traversal Loop
	insert_loop:
	// Special case: if the pointer to the current node is 0, that means the end of the list has been reached. Insert the node now.
	CBZ		X20, insert_end

	// Compare the value to be inserted with the value in the current node.
	LDRH	W23, [X20, value]
	CMP		W19, W23
	// If the inserted value <= current value, stop and insert the new node here.
	BLE		insert_end

	insert_incr:
	// Go to the next node and begin the next iteration.
	MOV		X21, X20
	LDR		X20, [X20, link]
	MOV		X22, #0	// Zero-out the list-empty flag.
	B		insert_loop

	// Do the insertion here.
	insert_end:
	// Create a new node and set its value and link.
	BL 		alloc
	STRH	W19, [X0, value]
	STR		X20, [X0, link]	// Link the new node to the current node, even if it is null.
	// If the insert-at-start flag (X22) is 1 at the end of the traversal, set Head to the new node.
	// Otherwise, link the previous node (which may be Head) to the new node.
	CBNZ	X22, insert_head
	// Link the previous node to the new node.
	STR		X0, [X21, link]
	B		insert_return
	insert_head:
	// Set the head to the new node.
	ADR		X21, Head
	STR		X0, [X21]
	insert_return:
	// Pop LR off the stack.
	LDUR	X30, [SP]
	ADD		SP, SP, #16
	RET

// Removes the first instance of a value in the list.
// Inputs: a 16-bit data value (hword) passed in X0, to be removed from the list.
// Returns: 1 if the value was found, 0 otherwise, passed in X0.
// Register usage:
//	X19 - holds the current node in list traversal.
//	X20 - holds the previous node in list traversal.
//	X21 - reset-head flag, indicates whether the head pointer must be reset because the front node is being removed.
//	W22 - holds the value of the current node.
//	X23 - holds the link field of the node to be removed, which will be stored in the link field of the previous node.
remove:
	// Store the current node pointer in X19, beginning with Head.
	// Store the previous node pointer in X20.
	ADR		X19, Head
	LDR		X19, [X19]
	// Reset-Head flag (X21): starts at 1; if it is not 0 at the end of the loop, the Head node is being deleted and the Head pointer must be updated.
	MOV		X21, #1

	// Traversal Loop
	remove_loop:
	// 1. check if the end of the list has been reached (current node == null); if it has, move 0 into X0 and return.
	// 2. if not, get the value of the current node (store in W22).
	// 3. compare the delend with the value in W22; if they are equal, delete the node.
	// 4. if they are not equal, increment the current node and begin the next iteration.
	CBNZ	X19, remove_cmp		// If current node pointer is null, end the function now.
	MOV		X0, XZR				// Set return value (X0) to 0.
	RET

	// Load the current node value and compare it to the delend.
	remove_cmp:
	LDRH	W22, [X19, value]
	CMP		W0, W22
	BEQ		remove_del

	// Increment current node pointer and begin next iteration here.
	remove_incr:
	MOV		X20, X19			// Set the previous node pointer to the current node pointer.
	LDR		X19, [X19, link]	// Increment the current node pointer.
	MOV		X21, XZR			// Clear the Reset-Head flag.
	B		remove_loop			// Begin the next iteration.

	// Delete node here.
	remove_del:
	// Load the link field of the current node into X23. It will go into the link field of the previous node.
	LDR		X23, [X19, link]
	// If the Reset-Head flag is 1, set Head pointer to X23. Otherwise, put X23 in the link field of the previous node.
	CBNZ	X21, remove_reset_head
	STR		X23, [X20, link]
	B		remove_end
	remove_reset_head:
	ADR		X21, Head	// Load the address of the head pointer in X21, it's not needed for the Reset-Head flag anymore.
	STR		X23, [X21]
	remove_end:
	// Return 1.
	MOV		X0, #1
	RET

// Traverses the list and stores the data from each node in subsequent halfwords in memory.
// Inputs: nothing.
// Returns: nothing.
// Register usage:
//	X9 - holds the current node pointer in the list traversal.
//	X10 - holds the output buffer address.
//	W11 - holds the value of the current node.
traverse:
	ADR		X9, Head	// Current node pointer.
	LDR		X9, [X9]
	ADR		X10, Output	// Output buffer address.
	traverse_loop:
	// Check if end of list has been reached.
	CBZ		X9, traverse_end
	// Get the value of the current node and store it.
	LDRH	W11, [X9, value]
	STRH	W11, [X10]
	// Increment the output buffer address, the current node, and begin the next iteration.
	ADD		X10, X10, #2
	LDR		X9, [X9, link]
	B		traverse_loop
	traverse_end:
	// Store 0 in memory.
	MOV		W11, #0
	STRH	W11, [X10]
	RET

// Searches for a value in the list, starting from the front.
// Inputs: a 16-bit value to search for, passed in X0.
// Returns: the 64-bit address to the node containing the value, or 0 if no match was found, passed in X0.
// Register usage:
//	X0 - holds the pointer to the current node; when this equals 0, or the value inside the node equals the search value, return.
//	W19 - holds the value to search for.
//	W20 - holds the value of the current node.
search:
	// Move the search value into W19, store the current node pointer in X0.
	MOV		W19, W0
	ADR		X0, Head
	LDR		X0, [X0]
	search_loop:
	CBZ		X0, search_end
	LDR		W20, [X0, value]
	CMP		W19, W20
	BEQ		search_end
	LDR		X0, [X0, link]
	B		search_loop
	search_end:
	RET

// Allocates a new node on the node buffer.
// Inputs: nothing.
// Returns: the address to the new node, passed in X0.
// Register usage:
//	X9 - FreePtr is loaded into here.
//	X10 - the address of FreePtr is loaded into here.
alloc:
	// Load FreePtr into X0.
	ADR		X0, FreePtr
	LDR		X0, [X0]
	// Set X9 = FreePtr + NodeSize.
	ADD		X9, X0, NodeSize
	// Get the address of FreePtr and use it to store the incremented address into it.
	ADR		X10, FreePtr
	STR		X9, [X10]
	RET

// Ends the program.
end:
	B		end
