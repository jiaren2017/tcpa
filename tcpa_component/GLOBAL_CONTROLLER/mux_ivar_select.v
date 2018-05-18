/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:    mux_ivar_select
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     
*
* ABSTRACT:  This module is driven by the iteration vector and depending on the 
select signal driven by a register, one iteration variable will be given as 
output. This output drives a comparator in minmax_comparator_matrix. 
*            
*******************************************************************************/


module mux_ivar_select (in, s, out);

	/*
	  parameters of the design
	*/
	parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
	parameter DIMENSION = 3; //default value
		
	/*
	  inputs			
	*/
	input signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] in;
	input signed [DIMENSION-1:0] s;

	/*
	  outputs
	*/
	output signed [ITERATION_VARIABLE_WIDTH-1:0] out;
	reg signed [ITERATION_VARIABLE_WIDTH-1:0] out;
	
	
	/*
	  making an array of the in	 
	*/
	wire [ITERATION_VARIABLE_WIDTH-1:0] in_array[0:DIMENSION-1];
	genvar x;
	generate 
	    for (x=0; x<DIMENSION; x=x+1)
        	begin  
                 assign in_array[x]= in[x*ITERATION_VARIABLE_WIDTH+:ITERATION_VARIABLE_WIDTH];
            end                    
    endgenerate
	
	reg signed [ITERATION_VARIABLE_WIDTH-1:0] out_array[0:DIMENSION-1];	
	

	/*
	  procedural block to create out_array
	*/
	integer n;
    always@(*) 
    begin   	
		for(n=0; n<DIMENSION; n=n+1)
			begin
				out_array[n] = s[n] ? in_array[n]: 0;
			end	
    end
    
    reg signed [ITERATION_VARIABLE_WIDTH-1:0] temp;    
   	/*
	  procedural block to create out which is the or of out_array
	*/  
	integer j;
	always@(*)
    	begin
      	  		temp = 0;
      			for(j=0; j<DIMENSION; j=j+1)
          			begin
              			temp = temp | out_array[j];
          			end    
      			out <= temp;  
    	end        

endmodule

/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
