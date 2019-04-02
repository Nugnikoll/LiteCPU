`define cpu_fetch_begin 0
`define cpu_fetch_io 1
`define cpu_fetch_end 2
`define cpu_exec_begin 3
`define cpu_exec_load_begin 4
`define cpu_exec_load_io 5
`define cpu_exec_load_end 6
`define cpu_exec_calc 7
`define cpu_exec_store_begin 8
`define cpu_exec_store_io 9

`define io_idle 0
`define io_read_begin 1
`define io_read_wait 2
`define io_write_begin 3
`define io_write_wait 4
