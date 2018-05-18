/******************************************************************************
	* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
	University of Erlangen-Nuremberg. All Rights Reserved
	*
	* MODULE:   stride_selector_ripple
	* DEVICE:     
	* PROJECT:  Global Controller 
	* AUTHOR:   Srinivas Boppu (srinivas.boppu@informatik.uni-erlangen.de)   
	* DATE:    
	*
	* ABSTRACT:  This design is used in global controller for rectangular iteration
				 spaces. Basically this block waits for stride select signals coming 
				 from the comparators and based on that it adds the appropriate column
				 from path stride matrix to the current iteration variables and generate
				 the next iteration variables.
	*            
*******************************************************************************/

module stride_selector_ripple (conf_clk, conf_bus, reset, sel, x_bus, output_selector, stride_select, ivar_next, conf_ack);

	/*
	  parameters of the design
    */
    parameter DIMENSION = 3; //default value 3
    parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
    parameter MATRIX_ELEMENT_WIDTH = 8; //default value 8
    parameter SELECT_WIDTH = 3; //default value 

	/*
	  inputs
	*/
	input conf_clk;
	input [MATRIX_ELEMENT_WIDTH-1:0] conf_bus;
	input [SELECT_WIDTH-1:0] sel;
    input reset;
	input signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus;
	input [DIMENSION-1:0] output_selector;
	input [0:DIMENSION-1] stride_select;	
		
	/*
	  outputs
	*/
	output signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] ivar_next;
	//reg signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] ivar_next; 
	output conf_ack;
	reg conf_ack;   

    /*
	  internal registers for storing stride vectors
    */
    reg signed [MATRIX_ELEMENT_WIDTH-1:0] s[0:DIMENSION-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;

	/*
	  logic to separate iteration variables from x_bus,which is a single input    
	*/
	genvar i;
	wire [ITERATION_VARIABLE_WIDTH-1:0] ivar[0:DIMENSION-1];
	generate for(i=0; i<DIMENSION;  i=i+1)
		begin
			assign ivar[i] = x_bus[(i*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
		end
	endgenerate

	/*
	  filling internal stride vector registers based on the conf_clk and generating conf_ack after
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
	
  		
    integer p, temp_counter;
    integer q;
    integer pp,qq;
      
    always@(posedge conf_clk or posedge reset)
      begin
          if(reset)
              begin
                  conf_ack <= 1'b0;
	              p <= 0; temp_counter <= 0;
	              q <= 0;
                  for (qq=0; qq < DIMENSION; qq = qq+1)
                    for(pp=0; pp< DIMENSION; pp = pp+1)
                          s[pp][qq] <= 0;  						 
              end	
            else if(conf_ack == 1'b0 && sel == 3'b011) //this module is given a select id of 011	 	
                begin         
                    s[p][q] <= conf_bus;
                   temp_counter <= temp_counter + 1;
                    //once loading the registers is done, set configuration acknowledgment
                    if(temp_output_selector[p+1] == 1'b0)
                        begin								
                           q <= q + 1;
                           p <= 0;  	
                        end
                    else
	                    begin
		                    p <= p+1;
		                end    
                    if(temp_output_selector[q+1] == 1'b0 && temp_output_selector[p+1] == 1'b0)
	                    begin
                        	conf_ack <= 1'b1;
		                    p <= 0;
		                    q <= 0;
		                end    
                end  				     
        end
  		

	
    wire s_array[0:DIMENSION-1];
    genvar j;
    generate
          for (j=0 ; j < DIMENSION ; j=j+1)
              assign s_array[j] = stride_select[j*1+:1];
    endgenerate
                                        
  
    /*
	  separating stride individual element from the selected stride column   
	*/
	wire [0:DIMENSION*DIMENSION*MATRIX_ELEMENT_WIDTH-1] stride_bus;
	genvar u,v;
	generate for (u=0; u<DIMENSION; u=u+1)
                for (v=0; v<DIMENSION; v=v+1)
                    begin
                             assign stride_bus[(u*DIMENSION+v)*MATRIX_ELEMENT_WIDTH+:MATRIX_ELEMENT_WIDTH]= s_array[v] ? s[u][v]:0;                           
		            end
	endgenerate

   
    wire [MATRIX_ELEMENT_WIDTH-1:0] stride_element[0:DIMENSION-1];
    genvar k;
    generate for (k=0; k<DIMENSION; k=k+1)
             my_or #(
                      .DIMENSION(DIMENSION),
                      .MATRIX_ELEMENT_WIDTH(MATRIX_ELEMENT_WIDTH)
                    ) my_or_inst (
                                   //Inputs
                                   .in(stride_bus[k*DIMENSION*MATRIX_ELEMENT_WIDTH+:DIMENSION*MATRIX_ELEMENT_WIDTH]),
                                   //Outputs
                                   .out(stride_element[k])
                                 ); 
    endgenerate


	/*
	   adding the stride vector to current iteration vector  
	*/
	reg [ITERATION_VARIABLE_WIDTH-1:0] ivar_next_element [0:DIMENSION-1];
	  	
   	integer z;
   	always@(*)
	   	begin
		   	for(z=0; z<DIMENSION; z=z+1)
			   begin
				   ivar_next_element[z] = ivar[z] + stride_element[z];
			   end
	   	end
	   	
    /*
    	generating packed wire for output 
    */    
	genvar w;
	generate 
		for (w=0; w< DIMENSION; w= w+1) 
			assign ivar_next[w*ITERATION_VARIABLE_WIDTH+:ITERATION_VARIABLE_WIDTH] = ivar_next_element[w];
	endgenerate
			

endmodule
/******************************************************************************
	*
	* REVISION HISTORY:
	*    
*******************************************************************************/
