// a sample program to calculate the sum of 1, 2, 3 ... 100

	mov $0, %r0					// 4c 00
	mov $0, %r1					// 4d 00
label_loop: // label_loop = 4
	add %r1, %r0				// 14 
	add $1, %r1					// 5d 01
	mov $10, %r2				// 4e 0a
	sub %r1, %r2				// 26
	test %r2, %r2				// 3a
	add %r2, %r2				// 1a
	add %r2, %ip				// 1b
	mov label_end, %ip			// 4f 11
	mov label_loop, %ip			// 4f 04
label_end: // label_end = 17
	mov $255, %r2				// 4e ff
	mov %r0, (%r2)				// 82
label_lock: // label_lock = 20
	mov label_lock, %ip			// 4f 14
