/* a sample program to calculate the sum of 1, 2, 3 ... (n - 1) */

label_begin:
	mov $0xfe, %r2
	mov (%r2), %r2
	mov $0x80, %r1
	mov %r2, (%r1)
	mov $0, %r0
	mov $0, %r1
label_loop:
	add %r1, %r0
	add $1, %r1
	mov $0x80, %r2
	mov (%r2), %r2
	sub %r1, %r2
	test %r2, %r2
	add %r2, %r2
	add %r2, %ip
	mov $label_end, %ip
	mov $label_loop, %ip
label_end:
	mov $0xff, %r2
	mov %r0, (%r2)
	mov $label_begin, %ip
