`include "TOP_CORE.sv"
`include "DataMem.sv"
`include "TEST.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;

module top();

rintf inf();
RISC_V rprocessor(.reset(inf.reset),.clk(inf.clk),.I_Req(inf.I_Req),.Rdata(inf.Rdata),.inst_data(inf.inst_data),
		.inst_addr(inf.inst_addr),.Data_addr(inf.Data_addr),.Wdata(inf.Wdata),.we(inf.we),.reg31(inf.reg31)
		,.PC(inf.PC),.IACK(inf.IACK));


DataMem dmem(.clk(inf.clk),.Data_addr(inf.Data_addr),.Wdata(inf.Wdata),.we(inf.we),.Rdata(inf.Rdata));



initial
begin
inf.clk=0;
forever
#5 inf.clk = ~inf.clk;
end


initial
begin

uvm_config_db #(virtual rintf)::set(null,"*","inf",inf);
run_test("test");
end


endmodule