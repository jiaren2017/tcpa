/******************************************************************************
    * (C) Copyright 2014 Chair for Hardware/Software Co-Design,
    University of Erlangen-Nuremberg. All Rights Reserved
    *
    * MODULE:   reinitializer_rect
    * DEVICE:     
    * PROJECT:  Global Controller 
    * AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
    * DATE:    
    *
    * ABSTRACT:  This design is used in global controller for rectangular iteration
                 spaces. This block, once the last point in the iteration space has
                 reached produces the reinitialize signal so that depending on the
                 mode of the global controller, the same control program can be 
                 executed.  
    *            
*******************************************************************************/

module reinitializer_rect (
							conf_bus,
							conf_clk,
							reset,
							x_bus,
							sel, 
							output_selector,
							conf_ack,							 
							gc_done,
							reinitialize
						  );
  
  /*
    parameters of the design
  */
  parameter DIMENSION = 3; //default value
  parameter SELECT_WIDTH = 3; //default value
  parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions

  /*
    inputs
  */
  input [ITERATION_VARIABLE_WIDTH-1:0]conf_bus;
  input conf_clk;
  input reset;  
  input [DIMENSION-1:0] output_selector;
  input [SELECT_WIDTH-1:0] sel;
  input signed [0:ITERATION_VARIABLE_WIDTH*DIMENSION-1] x_bus;
  
  /*
    outputs
  */
  output reinitialize;
  reg reinitialize;
  output gc_done;
  reg gc_done;
  output conf_ack;
  reg conf_ack;


   /* internal registers */
   reg signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_max_reg[0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
   
   /*  
      logic to separate iteration variables from x_bus, which is a single input 
   */
   genvar z;
   wire [ITERATION_VARIABLE_WIDTH-1:0] ivar[0:DIMENSION-1];
   generate
       for(z=0; z<DIMENSION; z=z+1)
           begin
               assign ivar[z] = x_bus[(z*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
           end 
   endgenerate


  /*
    filling internal registers based on the conf_clk and generating conf_ack after
    loading is done	
	*/
  /*
   creating temp_output_selector with extra one bit as in the case of programming
   all the registers upto DIMENSION, we are going to refer to DIMENSION+1 bit 
   and if it is zero the conf_ack is set to 1. To work for all the cases appending
   the output_selector with 0 at MSB position 		
  */
 
  wire [DIMENSION:0] temp_output_selector;
  assign temp_output_selector = {1'b0,output_selector};
  
  
  integer l;  
  integer k;  
  always@(posedge conf_clk or posedge reset)
    begin
        if(reset == 1'b1)
            begin
                k <= 0;
                conf_ack <= 1'b0;                
                for(l=0; l<DIMENSION; l=l+1)
                    begin
                        ivar_max_reg[l] <= 0;                        
                    end    
            end    
        else if(conf_ack == 1'b0 && sel == 3'b110)  //this module is have a select id of 6
            begin
            	ivar_max_reg[k] <= conf_bus;
            	k <= k+1;
            	if(temp_output_selector[k+1] == 1'b0)
	      		begin
				conf_ack <= 1'b1;                        
			end    
            end    
    end    
  
  wire [0:DIMENSION-1] out;
  genvar p;
  generate 
	for(p=0; p<DIMENSION;p=p+1)
  		begin
  			comparator #(.ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH))
			comparator (.a(ivar[p]), .b(ivar_max_reg[p]), .out(out[p]));
  		end
  endgenerate 				
  
  
  /*
    procedural assignment
  */
 always@(*)
 	begin
	
        if (!conf_ack)
		begin
			reinitialize = 1'b0; 
			gc_done = 1'b0;
		end
        else
		begin
			reinitialize = &out; //reduction and    
			gc_done = &out;
 		end			
 	end			

endmodule
