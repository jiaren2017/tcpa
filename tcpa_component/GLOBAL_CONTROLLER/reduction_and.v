/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   reduction_and.v
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     
*
* ABSTRACT: This module performs the reduction and operation 
*            
*******************************************************************************/


module reduction_and (in,out);
	
    /*
	  parameters of the design
	*/
	parameter DIMENSION = 3; //default value
		
	/*
	  inputs			
	*/
	input [0:DIMENSION-1] in;

	/*
	  outputs
	*/
	output out;
	reg out;

	/*
	  procedural block
	*/
    always@(in) 
    begin
	    out = &in;
	end		

endmodule

/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
