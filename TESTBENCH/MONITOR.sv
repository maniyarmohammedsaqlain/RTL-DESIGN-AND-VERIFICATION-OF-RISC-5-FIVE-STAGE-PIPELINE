`include "uvm_macros.svh"
import uvm_pkg::*;
`include "TRANSACTION.sv"
`ifndef MONITOR
`define MONITOR
class monitor extends uvm_monitor;
`uvm_component_utils(monitor);
transaction tr;
uvm_analysis_port #(transaction)send;
virtual rintf inf;

function new(string path="monitor",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
tr=transaction::type_id::create("tr");
send=new("send",this);
if(!uvm_config_db #(virtual rintf)::get(this,"","inf",inf))
`uvm_info("MON","ERROR IN CONFIG DB OF",UVM_NONE);

endfunction

virtual task run_phase(uvm_phase phase);
forever
begin
@(posedge inf.clk);
@(posedge inf.clk);
if(inf.reset)
begin
tr.opera=2'b00;
`uvm_info("MON_RST","RESET DETECTED IN DUT",UVM_NONE);
send.write(tr);
end
else if(!inf.reset && !inf.I_Req && inf.inst_data!=32'b0)
begin
tr.opera=2'b01;
tr.reset = inf.reset;
tr.I_Req = inf.I_Req;
tr.Rdata = inf.Rdata;
tr.inst_data = inf.inst_data;
tr.inst_addr = inf.inst_addr;
tr.Data_addr = inf.Data_addr;
tr.Wdata = inf.Wdata;
tr.reg31 = inf.reg31;
tr.PC = inf.PC;
`uvm_info("MON_RISC5",$sformatf("DATA CAPTURED IN TRANSACTION [MONITOR] is Rdata=%0h inst_data=%0h inst_addr=%0h Data_addr=%0h Wdata=%0h reg31=%0h PC=%0h",tr.Rdata,tr.inst_data,tr.inst_addr,tr.Data_addr,tr.Wdata,tr.reg31,tr.PC),UVM_NONE);
send.write(tr);
end
else if(inf.I_Req && !inf.reset )
begin
tr.opera=2'b10;
tr.reset = inf.reset;
tr.I_Req = inf.I_Req;
`uvm_info("MON_INTRUPT","INTERRUPT DETECTED IN DUT",UVM_NONE);
send.write(tr);
end
else if(!inf.I_Req && !inf.reset && inf.inst_data==32'b0)
begin
tr.opera=2'b11;
tr.reset = inf.reset;
tr.I_Req = inf.I_Req;
tr.Rdata = inf.Rdata;
tr.inst_data = 32'b00000000;
`uvm_info("MON_INVALID","INVALID INSTRUCTION DETECTED IN DUT",UVM_NONE);
send.write(tr);
end
end
endtask
endclass
`endif
