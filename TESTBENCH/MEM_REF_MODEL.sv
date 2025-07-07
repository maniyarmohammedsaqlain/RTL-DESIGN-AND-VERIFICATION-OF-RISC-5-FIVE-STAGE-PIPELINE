`include "uvm_macros.svh"
import uvm_pkg::*;


`ifndef MEMREFMODEL
`define MEMREFMODEL
class mem_ref_model extends uvm_object;

`uvm_object_utils(mem_ref_model);

logic[7:0]mem[(2**16-1):0];

function new(string path="mem_ref_model");
super.new(path);
endfunction


function void init_mem();
for(int i=0;i<2**16;i++)
mem[i]=0;
endfunction


function void write_mem(logic[15:0]addr,int data_wsize,logic[31:0]data);
for(int i=0;i<data_wsize/8;i++)
begin
mem[addr+i] = data[7:0];
data = data >> 8;
end
endfunction

function logic[31:0]read_mem(logic[15:0]addr,int data_wsize);
logic[31:0]temp;

if(data_wsize==32)

temp = {mem[addr+3] , mem[addr+2] , mem[addr+1] , mem[addr]};

else if(data_wsize==16)
temp = {mem[addr+1] , mem[addr]};

else

temp = mem[addr];


return temp;
endfunction

endclass
`endif
