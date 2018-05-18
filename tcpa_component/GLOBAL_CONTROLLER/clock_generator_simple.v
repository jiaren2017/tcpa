
/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   clock_generator
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
* DATE:     
*
* ABSTRACT: This module generates a clock that depends on the iteration interval.
*           User has to program the "div_reg" using the configuration bus,
* 			configuration clock and generate conf_ack signal. Meanwhile, DRP port logic
*           is waiting for conf_ack go high and once it is high the the DRP fsm
*           goes through different read and write stages and appropriate clocks 
*           are generated. Stable clock frequencies are observed on clk0_out, 
*           clkfx_out when locked_out signal is high.
*******************************************************************************/

module clock_generator (
		//clk input for the DCM
		clkin_in,
		//Global reset
		reset,
		// dynamic reconfiguration port, clk
		dclk_in,
		//clk output from the DCM, same as clkin
		clk0_out,
		//required clock output from the DCM that is divided/multiplied
		clkfx_out,
		//status of the DCM, high denotes that clk0_out, clkfx_out are stable
		locked_out,
		//configuration clock to program the registers in this module
		conf_clk,
		//data bus for the configuration data
		conf_bus,
		sel,
		//Iteration interaval
	   	div_reg,
		conf_ack
		  );
		
		/*
		  parameters of the design
		*/
		parameter D_ADDRESS = 7; // DRP address bus width
		parameter D_IN = 16; // DRP data in bus width
		parameter D_O = 16; // DRP data out bus width
		parameter DATA_WIDTH = 8; //data bus width of the configuration data bus (conf_bus)
		parameter ITERATION_VARIABLE_WIDTH = 16; //default value
		parameter SELECT_WIDTH = 3;
		
		//input source clock for the DCM
		input clkin_in /* synthesis syn_noprune=1 */; 
		
		//global reset of the design
		input reset /* synthesis syn_noprune=1 */;
		
		//dynamic reconfiguration port clock
		input dclk_in /* synthesis syn_noprune=1 */;
		
		//configuration clock
		input conf_clk;
		
		//configuration bus;
		input [DATA_WIDTH-1:0] conf_bus;
		
		//select ID for configuring the clock generator
		input [SELECT_WIDTH-1:0] sel;
	
		//same as clkin_in but it comes out from DCM as output, can be used it but is not used in global controller design
		output clk0_out /* synthesis syn_noprune=1 */; 
		
		//this is the output clock on which the global controller design runs 
		output clkfx_out /* synthesis syn_noprune=1 */; 
		
		//shows the status of the DCM
		output locked_out /* synthesis syn_noprune=1 */; 
		reg locked_out /* synthesis syn_noprune=1 */; 
		
		output [ITERATION_VARIABLE_WIDTH-1:0] div_reg;
	   	reg [ITERATION_VARIABLE_WIDTH-1:0] div_reg /* synthesis syn_noprune = 1 */;

	    output conf_ack;
	    reg conf_ack;
	  
			
		  
		/*
		 this register get programmed according to the iteration interval. 
		 This is the only one register that get programmed by the configuration
		 logic,(configuration bus, configuration clock) 
		*/

	   //reg [DATA_WIDTH-1:0] div_reg /* synthesis syn_noprune = 1 */;
	
	    //configuring the div_reg for the iteration interval
	    always@(posedge conf_clk or posedge reset)
	    begin
	    if(reset == 1'b1)
	    	begin
	    		conf_ack <= 1'b0;
	    		div_reg <= 0;
			end	
	    else if (conf_ack == 1'b0 && sel == 3'b001)  // sel is 3'b001
	    	begin
	    		div_reg <= conf_bus;
	    		conf_ack <= 1'b1;
	    	end	
	    end	
	    
        assign clk0_out = clkin_in;
        assign clkfx_out = clkin_in;
	    
	    always@(*)
		    begin
			    if (conf_ack == 1'b1)
				    locked_out = 1'b1;
			    else
				    locked_out = 1'b0;
			end    
	           			               	
                           
endmodule
/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
