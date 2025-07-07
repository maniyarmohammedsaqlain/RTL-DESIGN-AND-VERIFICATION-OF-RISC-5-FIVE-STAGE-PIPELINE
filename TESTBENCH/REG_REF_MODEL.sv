`include "uvm_macros.svh"
import uvm_pkg::*;
`ifndef REG_REF_MODEL
`define REG_REF_MODEL

class reg_ref_model extends uvm_object;

`uvm_object_utils(reg_ref_model);

function new(string path="reg_ref_model");
super.new(path);
endfunction

logic[31:0]regfile[31:0];

function void init_reg();
for(int i=0;i<32;i++)
regfile[i]=0;
endfunction

function void write_reg(int regnum,logic[31:0]data);
regfile[regnum] = data;
endfunction

function logic[31:0]read_reg(int regnum);
return regfile[regnum];
endfunction
endclass

`endif