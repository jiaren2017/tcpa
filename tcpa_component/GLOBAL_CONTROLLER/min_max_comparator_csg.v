/******************************************************************************
	* (C) Copyright 2012  Chair for Hardware/Software Co-Design,
	University of Erlangen-Nuremberg. All Rights Reserved
	*
	* MODULE:   minmax_comparator
	* DEVICE:     
	* PROJECT:  Global Controller 
	* AUTHOR:   Srinivas Boppu   
	* DATE:     2012 12:43:56 PM
	*
	* ABSTRACT: This block is used to implement the program blocks 
	*            
*******************************************************************************/


module min_max_comparator_csg (ivar, ivar_min, ivar_max, ignore_pb_comparator, c_out);

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
	input ignore_pb_comparator;
	/*
	  outputs
    */
	output c_out;
	reg c_out;

	
	/*
	  procedural block to update/calculate/checck whether the current iteration 
      in a progam block represented by ivar_min and ivar_max bound. if 
      'ignore_pb_comparator' is set, output of the comparator is '0'. If the
      user wants to use this comparator, while programming he has to set 
      'ignore_pb_comparator' value to '0' so that the comparator is active.
	*/
	
	always@(ivar or ivar_min or ivar_max or ignore_pb_comparator)
	begin
		if(ignore_pb_comparator)
			c_out <= 1'b1;
		else
		begin
			if ((ivar >= ivar_min) && (ivar <= ivar_max))
				c_out <= 1'b1;
			else
				c_out <= 1'b0; 	 	
		end
	end

endmodule
/******************************************************************************
	*
	* REVISION HISTORY:
	*    
*******************************************************************************/
