/******************************************************************************
* (C) Copyright 2012  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   reduction_and.v
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     2012 3:43:35 PM
*
* ABSTRACT: This modeule performs the reduction and 
*            
*******************************************************************************/


	module reduction_and_csg (in,out);
	
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
