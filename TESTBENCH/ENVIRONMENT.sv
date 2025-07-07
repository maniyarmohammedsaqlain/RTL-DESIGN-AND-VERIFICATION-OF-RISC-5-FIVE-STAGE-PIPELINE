`include "AGENT.sv"
`include "SCOREBOARD.sv"
`include "MEM_REF_MODEL.sv"
`include "REG_REF_MODEL.sv"

`ifndef ENVIRONMENT
`define ENVIRONMENT
class envmnt extends uvm_env;

`uvm_component_utils(envmnt);

agent ag;
scoreboard scb;
mem_ref_model mrm;
reg_ref_model rrm;


function new(string path="envmnt",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
ag = agent::type_id::create("ag",this);
scb = scoreboard::type_id::create("scb",this);
mrm = mem_ref_model::type_id::create("mrm",this);
rrm = reg_ref_model::type_id::create("rrm",this);
uvm_config_db #(mem_ref_model)::set(this,"*","mrm",mrm);
uvm_config_db #(reg_ref_model)::set(this,"*","rrm",rrm);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
ag.mon.send.connect(scb.SB_ex_port);
endfunction
endclass
`endif