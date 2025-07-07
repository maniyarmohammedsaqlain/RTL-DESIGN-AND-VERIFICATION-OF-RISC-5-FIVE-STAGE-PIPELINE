`include "uvm_macros.svh"
import uvm_pkg::*;
`include "TRANSACTION.sv"
`ifndef COVERAGE
`define COVERAGE
class coverage extends uvm_subscriber#(transaction);
`uvm_component_utils(coverage);

transaction trans;

covergroup instructions;

option.per_instance=1;

R_type: coverpoint trans.inst_data[14:12] iff(!trans.reset & trans.inst_data[6:0]==7'b0110011)

{
bins ADD = {3'b000} iff(trans.inst_data[6:0]==7'b0000000);
bins SUB = {3'b000} iff(trans.inst_data[6:0]==7'b0100000);
bins SLL = {3'b001};
bins SLT = {3'b010};
bins SLTU = {3'b011};
bins XOR = {3'b100};
bins SRL = {3'b101} iff(trans.inst_data[31:25]==7'b0000000);
bins SRA = {3'B101} iff(trans.inst_data[31:25]==7'b0100000);
bins OR = {3'b110};
bins AND = {3'b111};
}

I_Type: coverpoint trans.inst_data[14:12] iff(!trans.reset & (trans.inst_data[6:0]==7'b0000011 || trans.inst_data[6:0]==7'b0010011))

{
bins LB = {3'b000};
bins LH = {3'b001};
bins LW = {3'b010};
bins LBU = {3'b100};
bins LHU = {3'b101};
bins ADDI = {3'b000} iff(trans.inst_data[6:0]==7'b0010011);
bins SLTI = {3'b010} iff(trans.inst_data[6:0]==7'b0010011);
bins SLTIU = {3'b011} iff(trans.inst_data[6:0]==7'b0010011);
bins XORI = {3'b100} iff(trans.inst_data[6:0]==7'b0010011);
bins ORI = {3'b110} iff(trans.inst_data[6:0]==7'b0010011);
bins ANDI = {3'b111} iff(trans.inst_data[6:0]==7'b0010011);
}

S_Type: coverpoint trans.inst_data[14:12] iff(!trans.reset & (trans.inst_data[6:0]==7'b0100011))

{
bins SB = {3'b000};
bins SH = {3'b001};
bins SW = {3'b010};
}

B_Type: coverpoint trans.inst_data[14:12] iff(!trans.reset & (trans.inst_data[6:0]==7'b1100011))

{
bins BEQ = {3'b000};
bins BNE = {3'b001};
bins BLT = {3'b100};
bins BGE = {3'b101};
bins BLTE = {3'b110};
bins BGEU = {3'b111};
}
endgroup

function new(string path="coverage",uvm_component parent=null);
super.new(path,parent);

instructions = new();
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction



function void write(transaction t);
trans=transaction::type_id::create("trans");
$cast(trans,t);
instructions.sample();
endfunction

endclass
`endif










