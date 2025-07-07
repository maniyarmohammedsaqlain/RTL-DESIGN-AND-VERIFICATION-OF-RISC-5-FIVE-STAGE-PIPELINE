`include "uvm_macros.svh"
import uvm_pkg::*;
`ifndef TRANSACTION
`define TRANSACTION
class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction);

function new(string path="trans");
super.new(path);
endfunction

//inputs

logic clk;

// randomizable inputs
rand logic reset;
rand logic I_Req;            
rand logic [31:0] Rdata;  
rand logic [31:0] inst_data;
//outputs
logic [31:0] inst_addr;  
logic [31:0] Data_addr; 
logic [31:0] Wdata; 
logic [3:0] we;   
logic [31:0] reg31;
logic [31:0] PC;
logic IACK;

//tracking//
logic [1:0]opera;


constraint opcode{inst_data[6:0] inside {7'b0110011 , 7'b0000011 , 7'b0010011 , 7'b0100011 , 7'b1100011};}

constraint functs{ 
		(inst_data[6:0]==7'b0110011) -> (inst_data[31:25] inside {7'b0000000 , 7'b0100000}); 
		(inst_data[6:0]==7'b0110011 && inst_data[31:25]) -> (inst_data[14:12] inside {3'b101 ,3'b000});
		(inst_data[6:0]==7'b0000011) -> ((inst_data[14:12] inside {3'b000,3'b001,3'b010,3'b100,3'b101}) & (inst_data[31]==0));
		(inst_data[6:0]==7'b1100011) -> (inst_data[14:12] inside {3'b000,3'b001,3'b100,3'b101,3'b110,3'b111});
		(inst_data[6:0]==7'b0100011) -> (inst_data[14:12] inside {3'b000,3'b001,3'b010});
		((inst_data[6:0]==7'b0010011) && (inst_data[13:12]==2'b01)) -> (inst_data[31:25] inside {7'b000000 , 7'b0100000});
}
endclass	
	
`endif




