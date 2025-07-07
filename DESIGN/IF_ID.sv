module IF_ID(

	           input clk,
	           input reset,
	           input stalling,
              input [31:0] PC_in,
              input [31:0] inst_data_in,
	           input ACK_in,
	           output logic ACK_out,
              output logic [31:0] PC_out,
              output logic [31:0] inst_data_out
                                                     );
	 
	 
	


	



always_ff @(posedge clk) begin

  if(reset) begin 

      PC_out = 0;
      //inst_data_out = 0;
      ACK_out = 0;

  end


  if(~stalling)begin
  
     PC_out <= PC_in;
     inst_data_out <= inst_data_in;
     ACK_out <= ACK_in;
	  
     end
	  
	  
end


endmodule
