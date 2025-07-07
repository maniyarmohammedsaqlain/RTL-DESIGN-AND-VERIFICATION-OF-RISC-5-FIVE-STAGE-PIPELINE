`include "uvm_macros.svh"
import uvm_pkg::*;
`include "TRANSACTION.sv"
`include "MEM_REF_MODEL.sv"
`include "REG_REF_MODEL.sv"

`ifndef SCOREBOARD
`define SCOREBOARD

class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

uvm_analysis_export #(transaction) SB_ex_port;

uvm_tlm_analysis_fifo  #(transaction) SB_TLM_port;

transaction item;

mem_ref_model mem_ref_model_h;

reg_ref_model reg_ref_model_h;

logic[31:0] IF,ID,IEXE,IMEM,IWB,temp_inst ;

logic[31:0] PC_t = 0;

logic[31:0] PC = 0,PT=0;

logic[31:0] PC_IF,PC_ID,PC_IEXE,PC_IMEM,PC_IWB;

logic[31:0] reg31_IWB;

logic[31:0] Wdata_IMEM;

logic[31:0] Wdata2reg_1,Wdata2reg_2_EXE,Wdata2reg_2_MEM,Wdata2reg_2_WB;

bit x,y,forward;
/////SIGN EXTENSION//////////
function [31:0] SignExt;
    input [11:0] imm;
    SignExt = {{20{imm[11]}}, imm};
endfunction
///ZEROES EXTENSION//////////
function [31:0] ZeroExt;
    input [15:0] imm;
    ZeroExt = {16'b0, imm};
endfunction
/////////CONSTRUCTOR//////////
function new(string name="Scoreboard",uvm_component parent);
    super.new(name,parent);
   // `uvm_info(get_type_name(),"inside Scoreboard constructor",UVM_LOW)
endfunction
/////////BUILD PHASE//////////
function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   //`uvm_info(get_type_name(),"inside Scoreboard's build phase",UVM_LOW)
    SB_ex_port= new("SB_ex_port",this);
    SB_TLM_port= new("SB_TLM_port",this);
    mem_ref_model_h = new("mem_ref_model_h");
    reg_ref_model_h = new("reg_ref_model_h");
    if(!(uvm_config_db #(mem_ref_model)::get(this,"","mrm",mem_ref_model_h)))
       `uvm_error(get_type_name(),"error in getting mem_ref_model")
    if(!(uvm_config_db #(reg_ref_model)::get(this,"","rrm",reg_ref_model_h)))
       `uvm_error(get_type_name(),"error in getting reg_ref_model")
  mem_ref_model_h.init_mem();
  reg_ref_model_h.init_reg();
endfunction
/////////CONNECT PHASE//////////
function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   SB_ex_port.connect(SB_TLM_port.analysis_export);
endfunction
////RESET SCB AND MEMORIES////
task reset_scoreboard();
    IF = 32'b0;
    ID = 32'b0;
    IEXE = 32'b0;
    IMEM = 32'b0;
    IWB = 32'b0;

    temp_inst = 32'b0;

    PC_t = 0;
    PC = 0;
    PT = 0;

    PC_IF = 0;
    PC_ID = 0;
    PC_IEXE = 0;
    PC_IMEM = 0;
    PC_IWB = 0;

    reg31_IWB = 0;

    Wdata_IMEM = 0;

    Wdata2reg_1 = 0;
    Wdata2reg_2_EXE = 0;
    Wdata2reg_2_MEM = 0;
    Wdata2reg_2_WB = 0;

    x = 0;
    y = 0;
    forward = 0;
    `uvm_info("SCB","--------RESET DETECTED--------",UVM_NONE);
    mem_ref_model_h.init_mem();
    reg_ref_model_h.init_reg();
endtask

//////
//////////////RUN PHASE/////////////
task run_phase(uvm_phase phase);
   super.run_phase(phase); 
  //`uvm_info(get_type_name(),"inside Scoreboard's run phase",UVM_LOW);
  item= transaction::type_id::create("item");
  
  forever begin
    SB_TLM_port.get(item);
//////INSTURCTION PIPELINING REGISTERS/////////
       temp_inst = IWB;
       IWB = IMEM;
       IMEM = IEXE;
       IEXE = ID;
       ID = IF;
       IF = item.inst_data;
       reg31_IWB = item.reg31;

/////PROGRAM COUNTER STORING//////

       PC_IWB = PC_IMEM;
       PC_IMEM = PC_IEXE;
       PC_IEXE = PC_ID;
       PC_ID = PC_IF;
       PC_IF = item.PC;

        
       Wdata2reg_2_WB = Wdata2reg_2_MEM ;
       Wdata2reg_2_MEM = Wdata2reg_2_EXE ;
/////HAZARD DETECTION UNIT/////

      forward = ( (IMEM[11:7] == IEXE[19:15]) || (IMEM[11:7] == IEXE[24:20]) );
      x =(IMEM[6:0]==7'b0110011 || IMEM[6:0]==7'b0000011 || IMEM[6:0]==7'b0010011 || IMEM[6:0]==7'b0100011 || IMEM[6:0]==7'b1100011) ;
      y =(IWB[6:0]==7'b0110011 || IWB[6:0]==7'b0000011 || IWB[6:0]==7'b0010011 || IMEM[6:0]==7'b0100011 || IMEM[6:0]==7'b1100011) ;

      if(item.opera==2'b00)
	begin
	reset_scoreboard();
	end
      else if(item.opera==2'b10 && item.I_Req == 1'b1)
	begin
	`uvm_info("SCB_INTRUPT","-----------INTERRUPT DETECTED------------",UVM_NONE);
	end
      else if(item.opera==2'b11 && item.inst_data==32'b0000000)
	begin
	`uvm_info("SCB_INVALID","---------INVALID INSTRUCTION DETECTED------------",UVM_NONE);
	end

      else if(item.opera==2'b01 && x && forward) 
                               reg_ref_model_h.write_reg(IMEM[11:7],Wdata2reg_2_MEM);                       
      

      if(y) begin
                         
                           reg_ref_model_h.write_reg(IWB[11:7],Wdata2reg_2_WB); 
                          if( Wdata2reg_2_WB != reg31_IWB )   
                                          `uvm_error(get_type_name(),$sformatf("invalid data ! the actual data = %h ,the expected data = %h   inst= %h ",reg31_IWB,Wdata2reg_2_WB,IWB))
		
      end





      if( (PC_IF != PC) && (IMEM[6:0] == 7'b1100011))begin
                            `uvm_info(get_type_name(),$sformatf("invalid data ! the actual data = %h ,the expected data = %h inst= %h",PC_IF,PC,IMEM),UVM_NONE);
      end
///////INSTRUCTION DATA VERIFYING FOR R TYPE//////
    if(IEXE[6:0]==7'b0110011 ) begin 
    
        logic[31:0] rs1,rs2,rd;
        rs1 = reg_ref_model_h.read_reg(IEXE[19:15]);
        rs2 = reg_ref_model_h.read_reg(IEXE[24:20]);

        if(IEXE[31:25]==7'b0000000) begin 
            
         case(IEXE[14:12])  

             3'b000: rd = rs1 + rs2;
             3'b001: rd =  rs1 <<  rs2;
             3'b010: rd = (rs1 <   rs2);
             3'b011: rd = (rs1 <   rs2);
             3'b100: rd =  rs1 ^ rs2;
             3'b101: rd =  rs1 >>  rs2;
             3'b110: rd =  rs1 |   rs2;
             3'b111: rd =  rs1 &   rs2;

 
           endcase

        end



       else if (IEXE[31:25]==7'b0100000) begin 

        logic[31:0] rs1,rs2,rd;
        rs1 = reg_ref_model_h.read_reg(IEXE[19:15]);
        rs2 = reg_ref_model_h.read_reg(IEXE[24:20]);

         case(IEXE[14:12])  

             3'b000: rd =  rs1 - rs2;
             3'b101: rd =  rs1 >>> rs2;

           endcase

       end




Wdata2reg_2_EXE = rd;


  end
/////////////////////////////////////////////////////
  


////////////I TYPE /////////////



else if (IEXE[6:0] == 7'b0000011) begin
    logic[31:0] rs1, rs2, rd, address;
    logic[7:0] mem_byte;
    logic[15:0] mem_halfword;
    logic[31:0] mem_word;

    rs1 = reg_ref_model_h.read_reg(IEXE[19:15]);
    address = rs1 + {{20{IEXE[31]}}, IEXE[31:20]}; 

    case (IEXE[14:12] && (address > -1))

        3'b000: begin 
            mem_byte = mem_ref_model_h.read_mem(address, 8);
            rd = {{24{mem_byte[7]}}, mem_byte}; 
        end

        3'b001: begin 
            mem_halfword = mem_ref_model_h.read_mem(address, 16);
            rd = {{16{mem_halfword[15]}}, mem_halfword}; 
        end

        3'b010: begin 
            mem_word = mem_ref_model_h.read_mem(address, 32);
            rd = mem_word;
        end

        3'b100: begin 
            mem_byte = mem_ref_model_h.read_mem(address, 8);
            rd = {24'b0, mem_byte}; 
        end

        3'b101: begin 
            mem_halfword = mem_ref_model_h.read_mem(address, 16);
            rd = {16'b0, mem_halfword}; 
        end

    endcase

    if (address < 0)
        rd = 0;

    Wdata2reg_2_EXE = rd;
end

//-------------------------------------------------------------///////



     else if (IEXE[6:0] == 7'b0010011 ) begin

        logic[31:0] rs1,rs2,rd;
        rs1 = reg_ref_model_h.read_reg(IEXE[19:15]);

        case (IEXE[14:12])
            3'b000: rd = rs1 + SignExt(IEXE[31:20]);              // ADDI
            3'b001: rd = rs1 << IEXE[24:20];                      // SLLI
            3'b010: rd = (rs1 < SignExt(IEXE[31:20]));            // SLTI
            3'b011: rd = (rs1 < $unsigned(SignExt(IEXE[31:20]))); // SLTIU
            3'b100: rd = rs1 ^ SignExt(IEXE[31:20]);              // XORI
            3'b101: begin
                if (IEXE[31:25] == 7'b0000000)
                    rd = rs1 >> IEXE[24:20];                      // SRLI
                else if (IEXE[31:25] == 7'b0100000)
                    rd = rs1 >>> IEXE[24:20];                     // SRAI
            end
            3'b110: rd = rs1 | SignExt(IEXE[31:20]);              // ORI
            3'b111: rd = rs1 & SignExt(IEXE[31:20]);              // ANDI
        endcase
 
          Wdata2reg_2_EXE = rd;


    end 


 

    // S-type instructions (Store operations)
     if (IMEM[6:0] == 7'b0100011) begin
        logic[31:0] rs1,rs2,rd,address;
        rs1 = reg_ref_model_h.read_reg(IMEM[19:15]);
        rs2 = reg_ref_model_h.read_reg(IMEM[24:20]);
        address = rs1 + SignExt({IMEM[31:25], IMEM[11:7]});

        case (IMEM[14:12])
            3'b000: begin 
                         mem_ref_model_h.write_mem(address,8,rs2[7:0]);   // SB: Store Byte
                         if(Wdata_IMEM[7:0] != rs2[7:0])
                                  `uvm_error(get_type_name(),$sformatf("invalid data ! the actual data = %h ,the expected data = %h   inst = %h",Wdata_IMEM[7:0],rs2[7:0],IMEM))
		         else
				  `uvm_info("SCOREOBARD","--------PASSED--------",UVM_NONE);

                    end


            3'b001: begin 
                        mem_ref_model_h.write_mem(address,16,rs2[15:0]); // SH: Store Halfword
                         if(Wdata_IMEM[15:0] != rs2[15:0])
                                  `uvm_error(get_type_name(),$sformatf("invalid data ! the actual data = %h ,the expected data = %h  inst = %h",Wdata_IMEM[15:0],rs2[15:0],IMEM))
			 else
				  `uvm_info("SCOREOBARD","--------PASSED--------",UVM_NONE);

                    end

            3'b010: begin 
                        mem_ref_model_h.write_mem(address,32,rs2);       // SW: Store Word
                         if(Wdata_IMEM != rs2)
                                  `uvm_error(get_type_name(),$sformatf("invalid data ! the actual data = %h ,the expected data = %h   inst = %h",Wdata_IMEM,rs2,IMEM))
			 else
				  `uvm_info("SCOREOBARD","--------PASSED--------",UVM_NONE);

                    end


        endcase




    end

 
    // B-type instructions (Branch operations)
     if (IEXE[6:0] == 7'b1100011) begin
        logic[31:0] rs1,rs2,rd,BTA;
        rs1 = reg_ref_model_h.read_reg(IEXE[19:15]);
        rs2 = reg_ref_model_h.read_reg(IEXE[24:20]);
        BTA = PC_IEXE + {{20{IEXE[31]}}, IEXE[7], IEXE[30:25], IEXE[11:8], 1'b0};

        case (IEXE[14:12])
            3'b000: if (rs1 == rs2) PC = BTA; else  PC=PC_IEXE+12;       // BEQ: Branch if Equal
            3'b001: if (rs1 != rs2) PC = BTA; else  PC=PC_IEXE+12;         // BNE: Branch if Not Equal
            3'b100: if ($signed(rs1) < $signed(rs2)) PC = BTA; else  PC=PC_IEXE+12; // BLT: Branch if Less Than
            3'b101: if ($signed(rs1) >= $signed(rs2)) PC = BTA; else  PC=PC_IEXE+12;// BGE: Branch if Greater or Equal
            3'b110: if ($unsigned(rs1) < $unsigned(rs2)) PC = BTA; else  PC=PC_IEXE+12;// BLTU: Branch if Less Than Unsigned
            3'b111: if ($unsigned(rs1) >= $unsigned(rs2)) PC = BTA; else  PC=PC_IEXE+12;// BGEU: Branch if Greater or Equal Unsigned
            
        endcase
   


                          
        if(PC == BTA)  begin 

          ID =32'bx;
          IF=32'bx;
          PT=1;

       end
end
end
endtask
endclass

`endif
