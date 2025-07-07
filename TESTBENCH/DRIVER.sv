`include "uvm_macros.svh"
`include "TRANSACTION.sv"
import uvm_pkg::*;
`ifndef DRIVER
`define DRIVER
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver);

transaction tr;
virtual rintf inf;

function new(string path="driver",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);



if(!uvm_config_db #(virtual rintf)::get(this,"","inf",inf))
`uvm_info("DRV","ERROR IN CONFIG DB OF DRIVER",UVM_NONE);

endfunction

virtual task run_phase(uvm_phase phase);
forever
begin
tr=transaction::type_id::create("tr");
seq_item_port.get_next_item(tr);
if(tr.opera==2'b00)
begin
@(posedge inf.clk);
inf.reset<=tr.reset;
@(posedge inf.clk);
`uvm_info("RESET",$sformatf("RESET=%0d VALUE APPLIED TO DUT",tr.reset),UVM_NONE);
end
else if(tr.opera==2'b01)
begin
@(posedge inf.clk);
inf.reset<=tr.reset;
inf.I_Req<=tr.I_Req;
inf.inst_data<=tr.inst_data;
@(posedge inf.clk);
if(tr.inst_data[6:0] == 7'b0110011)
begin
`uvm_info("RISC 5",$sformatf("R TYPE INSTR APPLIED TO DUT INSTR=%0h",tr.inst_data),UVM_NONE);
end
else if(tr.inst_data[6:0] == 7'b0000011)
begin
`uvm_info("RISC 5",$sformatf("LOAD TYPE INSTR APPLIED TO DUT INSTR=%0h",tr.inst_data),UVM_NONE);
end
else if(tr.inst_data[6:0] == 7'b0010011)
begin
`uvm_info("RISC 5",$sformatf("I TYPE INSTR APPLIED TO DUT INSTR=%0h",tr.inst_data),UVM_NONE);
end
else if(tr.inst_data[6:0] == 7'b0100011)
begin
`uvm_info("RISC 5",$sformatf("S TYPE INSTR APPLIED TO DUT INSTR=%0h",tr.inst_data),UVM_NONE);
end
else if(tr.inst_data[6:0] == 7'b1100011)
begin
`uvm_info("RISC 5",$sformatf("B TYPE INSTR APPLIED TO DUT INSTR=%0h",tr.inst_data),UVM_NONE);
end
end
else if(tr.opera==2'b10)
begin
@(posedge inf.clk);
inf.reset<=tr.reset;
inf.I_Req<=tr.I_Req;
inf.inst_data<=tr.inst_data;
@(posedge inf.clk);
`uvm_info("RISC 5 INT",$sformatf("INTERRUPT SEQUENCE APPLIED TO DUT"),UVM_NONE);
end
else if(tr.opera==2'b11)
begin
@(posedge inf.clk);
inf.reset<=tr.reset;
inf.I_Req<=tr.I_Req;
inf.inst_data<=tr.inst_data;
@(posedge inf.clk);
`uvm_info("RISC 5 INV","INVALID SEQUENCE APPLIED TO DUT",UVM_NONE);
end
seq_item_port.item_done(tr);
end
endtask
/*
task drive(transaction tr);
@(posedge tr.clk);
if(!tr.reset)
begin
inf.I_Req = tr.I_Req;
inf.reset = tr.reset;
inf.inst_data = tr.inst_data;
//@(posedge tr.clk);
`uvm_info("DRV", $sformatf("Driving data: I_Req=%0b, reset=%0b, inst=%h", tr.I_Req, tr.reset, tr.inst_data), UVM_LOW)

end
else
begin
inf.reset = tr.reset;
//@(posedge tr.clk);
`uvm_info("DRV","RESET OR INVALID DETECTED",UVM_NONE);
end
endtask
*/

endclass
`endif




