/******************************************************************************
	* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
	University of Erlangen-Nuremberg. All Rights Reserved
	*
	* MODULE:   minmax_comparator
	* DEVICE:     
	* PROJECT:  Global Controller 
	* AUTHOR:   Srinivas Boppu   
	* DATE:     
	*
	* ABSTRACT:  This block compares the current iteration variable value with
	* ivar_min and ivar_max. If the current value lies in this min max range
	* outout is logic 1 else 0. In the bypass mode it always produces logic 1
	* as default value. 
	*            
*******************************************************************************/


module min_max_comparator_ic (ivar, ivar_min, ivar_max, bypass, c_out);

	/*
	  parameters of the design	
	*/
	parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
	
	/*
      inputs
    */
	input signed [ITERATION_VARIABLE_WIDTH-1:0] ivar;
	input signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_min;
    input signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_max;
	input bypass;
	/*
	  outputs
    */
	output c_out;
	reg c_out;

	
	/*
	  procedural block to update/calculate the output of the
	  comparator. Whenever there is a change in i/ps, o/p is 
	  updated. if bypass is '1', irrespective the other i/ps
      output is always 1. 
	*/
	
	always@(ivar or ivar_min or ivar_max or bypass)
	begin
		if(bypass)
			c_out = 1'b1;
		else
		begin
			if ((ivar >= ivar_min) && (ivar <= ivar_max))
				c_out = 1'b1;
			else
				c_out = 1'b0; 	 	
		end
	end

endmodule
/******************************************************************************
	*
	* REVISION HISTORY:
	*    
*******************************************************************************/
