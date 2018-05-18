/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   initializer.v
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     
*
* ABSTRACT:  This module is configured for the following, it is one of the first 
* design module that get configured.
* 
* 1) output_selector_reg (output_selector): this selects the DIMENSION. You might
* have synthesized your design for higher dimensions. However, at the run time you
* can select the DIMENSIONS as per your requirements.If this feature is required not to
* waste any cycles during the programming all other modules.
* 
* 2) init_ic_reg (init_ic): initial values of the control signals (ICs).
* 
* 3) restart_mode_reg (restart_mode): this register controls whether the control program
* restarts after reaching the last iteration. If it is "1", control program repeats else
* not.
* 
* 4) pb_selector_reg (pb_selector): selects the number of program blocks. You might have
* synthesized your design for higher no.of program blocks.By programming this register
* you can select lesser no.of program blocks. 
* 
* 5) ic_selector_reg (ic_selector): select the number of ic signals. By programming this
* register no.of ic signals can be select even though the design is synthesized for higher
* number of control signals.
* 
* 6) init_ivar_reg (init_ivar): initial values of the iteration variables depends on the
* dimension.
*            
*******************************************************************************/

module initializer (
                     conf_clk,
                     conf_bus,
                     reset,
                     sel,
                     conf_ack,
                     init_ivar,
                     init_ic,
                     output_selector,
                     restart_mode,
                     pb_selector,
                     ic_selector
                   );

    /*
      parameters of the design
    */
    parameter DIMENSION = 3; //default value
    parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
    parameter SELECT_WIDTH = 3; //default value
    parameter MAX_NO_OF_PROGRAM_BLOCKS = 12; //default value
    parameter NUM_OF_IC_SIGNALS = 3; //default value
    //localparam PB_FILL = (((MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH) * ITERATION_VARIABLE_WIDTH) == MAX_NO_OF_PROGRAM_BLOCKS) ?  MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH : ((MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH) +1) ; 
    localparam PB_FILL = 5;//(((MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH) * ITERATION_VARIABLE_WIDTH) == MAX_NO_OF_PROGRAM_BLOCKS) ?  MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH : ((MAX_NO_OF_PROGRAM_BLOCKS/ITERATION_VARIABLE_WIDTH) +1) ; 
    
    /*
      inputs
    */
    input conf_clk;
    input [ITERATION_VARIABLE_WIDTH-1:0] conf_bus;
    input reset;
    input [SELECT_WIDTH-1:0] sel;
        

    /*
      outputs 
    */
    output [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] init_ivar /* synthesis syn_keep = 1 */;
    //reg signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] init_ivar;
    
    output [DIMENSION-1:0] output_selector /* synthesis syn_keep = 1 */;
    //reg [DIMENSION-1:0] output_selector;
    
    output conf_ack;
    reg conf_ack;
    
    output [0:NUM_OF_IC_SIGNALS-1] init_ic /* synthesis syn_keep = 1 */;
    output restart_mode;
    output [MAX_NO_OF_PROGRAM_BLOCKS-1:0] pb_selector /* synthesis syn_keep = 1 */;
    output [NUM_OF_IC_SIGNALS-1:0] ic_selector /* synthesis syn_keep = 1 */; 
       
    /*
      internal registers which gets programmed
    */
    reg signed [ITERATION_VARIABLE_WIDTH-1:0] init_ivar_reg[0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg [DIMENSION-1:0] output_selector_reg /* synthesis syn_preserve = 1 */;
    reg [0:NUM_OF_IC_SIGNALS-1] init_ic_reg /* synthesis syn_preserve = 1 */;
    reg restart_mode_reg /* synthesis syn_preserve = 1 */;
    reg [MAX_NO_OF_PROGRAM_BLOCKS-1:0] pb_selector_reg /* synthesis syn_preserve = 1 */;
    reg [NUM_OF_IC_SIGNALS-1:0] ic_selector_reg /* synthesis syn_preserve = 1 */;

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
	assign temp_output_selector = {1'b0,output_selector_reg};
    
    reg [PB_FILL-1:0] pb_fill_reg;
    wire [PB_FILL:0] temp_pb_fill_select;
    assign temp_pb_fill_select ={1'b1,pb_fill_reg};

    integer i;
    integer j;
    integer k;
    integer z;
	integer l;
    always@(posedge conf_clk or posedge reset)
        begin
            if(reset == 1'b1)
            	begin            		
            		conf_ack <= 1'b0;
            		output_selector_reg <= 0;
            		init_ic_reg <= 0;
            		restart_mode_reg <= 0;
            		pb_selector_reg <= 0;
            		ic_selector_reg <= 0;
            		pb_fill_reg <=0;
	            	i <= 0;
	            	j <= 0;	            	
	            	z <= 0;
	            	l = 0;
            		for(k=0; k<DIMENSION; k=k+1)
            			begin
            				init_ivar_reg[k] <= 0;
            			end	            			
            	end
            else if(conf_ack == 1'b0  && sel == 3'b010)  //this module is given a select id of 2, 010       
                begin
	                pb_fill_reg <= 0;	                
                    if (i == 0)
                        begin
                            output_selector_reg <= conf_bus;
                            i <= i+1;
                        end
                    else if (i == 1)
                    	begin
	                    	for(l=0; l<NUM_OF_IC_SIGNALS; l=l+1)
            					begin            				
	            					init_ic_reg[l] <= conf_bus[l];
            					end	        
                            i <= i+1;
                        end
                    else if (i == 2)
                    	begin
                    		restart_mode_reg <= conf_bus;
                    		i <= i+1;
                    	end
                    else if (i == 3)
                    	begin
                    		pb_selector_reg[z*ITERATION_VARIABLE_WIDTH+:ITERATION_VARIABLE_WIDTH] <= conf_bus;                    		
                            if (temp_pb_fill_select[z+1] == 1'b1)
	                          begin  
                    		  	i <= i+1;
		                        z <= 0;  
	                          end
                            else
	                            begin
		                            z <= z+1;
		                        end    
                    	end		
                    else if (i == 4)
                    	begin
                    		ic_selector_reg <= conf_bus;
                    		i <= i+1;
                    	end		          
                    else
                        begin    
                            init_ivar_reg[j] <= conf_bus;                            
                            if(temp_output_selector[j+1] == 1'b0)
                                begin
                                    //once loading the registers is done, setting configuration acknowledgment
                                    conf_ack <= 1'b1;
	                                j <= 0;
                                end
                            else
	                            begin
		                            j <= j + 1;
		                        end    
                        end
                        
                end
             
        end

    /*
      creating wires from programmed registers
    */     
    wire [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] wire_init_ivar;
    genvar p;
    generate for(p = 0; p < DIMENSION ; p = p+1)
        begin
            assign wire_init_ivar[p*ITERATION_VARIABLE_WIDTH+:ITERATION_VARIABLE_WIDTH] = init_ivar_reg[p];   
        end
    endgenerate
            
    assign init_ivar = wire_init_ivar;
    assign output_selector = output_selector_reg;
    assign init_ic = init_ic_reg;
    assign restart_mode = restart_mode_reg;
    assign pb_selector = pb_selector_reg;
    assign ic_selector = ic_selector_reg;
  	  	
endmodule
/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
