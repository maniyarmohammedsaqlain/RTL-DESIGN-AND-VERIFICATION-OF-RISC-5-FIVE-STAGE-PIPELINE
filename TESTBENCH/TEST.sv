
`include "ENVIRONMENT.sv"
`include "SEQUENCE.sv"
`ifndef TEST
`define TEST
class test extends uvm_test;
`uvm_component_utils(test);

function new(string path="test",uvm_component parent=null);
super.new(path,parent);
endfunction

envmnt env;

reset_seq rseq;
riscv_seq riseq;
riscv_seq_i riseqi;
invalid_instr inv;

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
env = envmnt::type_id::create("env",this);
rseq = reset_seq::type_id::create("rseq",this);
riseq = riscv_seq::type_id::create("riseq",this);
riseqi = riscv_seq_i::type_id::create("riseqi",this);
inv = invalid_instr::type_id::create("inv",this);
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);

repeat(20000)
begin
rseq.start(env.ag.seqr);
end
$display("SEQUENCE 1 COMPLETED");
repeat(20000)
begin

riseq.start(env.ag.seqr);
end
$display("SEQUENCE 2 COMPLETED");
repeat(20000)
begin

riseqi.start(env.ag.seqr);
end
$display("SEQUENCE 3 COMPLETED");
repeat(20000)
begin

inv.start(env.ag.seqr);
end
$display("SEQUENCE 4 COMPLETED");


phase.drop_objection(this);
endtask
endclass

`endif
