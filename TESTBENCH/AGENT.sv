`include "uvm_macros.svh"
import uvm_pkg::*;
`include "DRIVER.sv"
`include "MONITOR.sv"
`include "TRANSACTION.sv"
`include "COVERAGE_COLLECTOR.sv"

`ifndef AGENT
`define AGENT
class agent extends uvm_agent;
`uvm_component_utils(agent);

driver drv;
monitor mon;
uvm_sequencer#(transaction)seqr;
coverage covr;
function new(string path="agent",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
drv = driver::type_id::create("drv",this);
mon = monitor::type_id::create("mon",this);
seqr = uvm_sequencer#(transaction)::type_id::create("seqr",this);
covr = coverage::type_id::create("covr",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
drv.seq_item_port.connect(seqr.seq_item_export);
mon.send.connect(covr.analysis_export);
endfunction

endclass

`endif