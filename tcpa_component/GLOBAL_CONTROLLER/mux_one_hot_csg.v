/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:    mux_one_hot_csg
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     2012 3:43:35 PM
*
* ABSTRACT:  This module is driven by the iteration vector and depending on the 
select signal driven by a register, one iteration variable will be given as 
output. This output drives a comparator in minmax_comparator_matrix. 
*            
*******************************************************************************/


module mux_one_hot_csg (in, s, out);

	/*
	  parameters of the design
	*/
	parameter NUM_OF_IC_SIGNALS = 3; //default value
	parameter MAX_NO_OF_PROGRAM_BLOCKS = 12; //default value
		
	/*
	  inputs			
	*/
	input signed [0:MAX_NO_OF_PROGRAM_BLOCKS*NUM_OF_IC_SIGNALS-1] in;
	input [MAX_NO_OF_PROGRAM_BLOCKS-1:0] s;

	/*
	  outputs
	*/
	output signed [0:NUM_OF_IC_SIGNALS-1] out;
	reg signed [0:NUM_OF_IC_SIGNALS-1] out;

	/*
	  making an array of the in	 
	*/
	wire [0:NUM_OF_IC_SIGNALS-1] in_array[0:MAX_NO_OF_PROGRAM_BLOCKS-1];
	genvar x;
	generate 
	    for (x=0; x<MAX_NO_OF_PROGRAM_BLOCKS; x=x+1)
        	begin  
                 assign in_array[x]= in[x*NUM_OF_IC_SIGNALS+:NUM_OF_IC_SIGNALS];
            end                    
    endgenerate
	
	reg signed [0:NUM_OF_IC_SIGNALS-1] out_array[0:MAX_NO_OF_PROGRAM_BLOCKS-1];
	
	
	/*
	  procedural block to create out_array
	*/    
    integer n;
    always@(*) 
	    begin
		    for(n=0; n<MAX_NO_OF_PROGRAM_BLOCKS; n=n+1)
				begin    
		    		out_array[n] = s[n] ? in_array[n]: 0;
		    	end	
	    end
   	 
   	reg signed [0:NUM_OF_IC_SIGNALS-1] temp; 
   	/*
	  procedural block to create out which is the or of out_array
	*/  
	integer j;
	always@(*)
    	begin
      	  		temp = 0;  
      			for(j=0; j<MAX_NO_OF_PROGRAM_BLOCKS; j=j+1)
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
