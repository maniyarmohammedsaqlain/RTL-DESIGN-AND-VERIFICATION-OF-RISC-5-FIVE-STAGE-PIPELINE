`include "TRANSACTION.sv"

`ifndef SEQUENCES
`define SEQUENCES
//------------------BASE SEQUENCE---------------//
class base_seq extends uvm_sequence#(transaction);
`uvm_object_utils(base_seq);

function new(string path="base_seq");
super.new(path);
endfunction
endclass
//---------------------------------------------//

//----------------RESET SEQUENCE----------------------------//
class reset_seq extends base_seq;
`uvm_object_utils(reset_seq);

function new(string path="rstseq");
super.new(path);
endfunction

transaction tr_rst;

virtual task body();
begin
tr_rst=transaction::type_id::create("tr_rst");
start_item(tr_rst);
assert(tr_rst.randomize() with {
reset == 1;
I_Req == 0;
inst_data == 32'b00000000000000000000000000010011;});
tr_rst.opera = 2'b00;
`uvm_info("RESET",$sformatf("RESET=%0d VALUE APPLIED TO RISC 5",tr_rst.reset),UVM_NONE);
finish_item(tr_rst);
end
endtask
endclass
//-------------------------------------------------//

//----------------------RISC 5 SEQUENCE------------------------//

class riscv_seq extends base_seq;
`uvm_object_utils(riscv_seq);

function new(string path="riscv_seq");
super.new(path);
endfunction

transaction tr;

virtual task body();
begin
tr=transaction::type_id::create("tr");
start_item(tr);
assert(tr.randomize() with {
reset == 0;
I_Req == 0;});
tr.opera = 2'b01;
`uvm_info("SEQUENCE","INSTRUCTION IS APPLIED TO DUT",UVM_NONE);
finish_item(tr);
end
endtask
endclass
//------------------------------------------//

// INSTRUCTION WITH INTERUPT //
class riscv_seq_i extends base_seq;
`uvm_object_utils(riscv_seq_i);

function new(string path="riscv_seq_i");
super.new(path);
endfunction

transaction tr_i_i;

virtual task body();
begin
tr_i_i=transaction::type_id::create("tr_i_i");
start_item(tr_i_i);
assert(tr_i_i.randomize() with {
reset == 0;
I_Req == 1;});
tr_i_i.opera = 2'b10;
`uvm_info("INTERRUPT","INSTRUCTION IS APPLIED WITH INTERRUPT",UVM_NONE);
finish_item(tr_i_i);
end
endtask
endclass
//-----------------------------------------//

//-------------------INVALID INSTRUCTION------------------------------//

class invalid_instr extends base_seq;
`uvm_object_utils(invalid_instr);

function new(string path="invalid_instr");
super.new(path);
endfunction

transaction tr_inv;

virtual task body();
begin
tr_inv=transaction::type_id::create("tr_inv");
start_item(tr_inv);
tr_inv.reset = 0;
tr_inv.I_Req = 0;
tr_inv.inst_data[31:0]=32'b0;
tr_inv.opera = 2'b11;
`uvm_info("INVALID","INVALID INSTRUCTION APPLIED",UVM_NONE);
finish_item(tr_inv);
end
endtask
endclass

`endif
