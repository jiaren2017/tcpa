/******************************************************************************
	* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
	University of Erlangen-Nuremberg. All Rights Reserved
	*
	* MODULE:   minmax_comparator_matrix
	* DEVICE:     
	* PROJECT:  Global Controller 
	* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
	* DATE:     
	*
	* ABSTRACT: This block contains the minmax comparators arranged in a lower
	            triangular matrix shape.It basically looks at the incoming vector
		        and generate the stride select signals for the stride selector
				block(ripple or parallel)implementations. For more details look
                at the block diagram. Note that this block has some registers
				that has to be programmed before using it.
	*            
*******************************************************************************/

module minmax_comparator_matrix (
									conf_clk, 
									conf_bus, 
									reset,									 
									sel, 
									x_bus, 
									output_selector, 
									conf_ack, 
									stride_select
								);
	
	/*
	  parameters of the design
	*/
	parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
	parameter DIMENSION = 3; //default value
	parameter SELECT_WIDTH =3; //default value
    parameter NO_REG_TO_PROGRAM = 4; //default value

	/*
	  inputs
	*/
	input conf_clk;
	input [ITERATION_VARIABLE_WIDTH-1:0] conf_bus;
	input [SELECT_WIDTH-1:0] sel;
 	input signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus;
	input [DIMENSION-1:0] output_selector;
	input reset;	
	
	/*
	  outputs
    */
	output [0:DIMENSION-1] stride_select;
	// reg [0:DIMENSION-1] stride_select;
	output conf_ack;
	reg conf_ack;


    reg signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_min_reg[0:DIMENSION-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_max_reg[0:DIMENSION-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg [DIMENSION-1:0] ivar_sel_reg[0:DIMENSION-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg bypass_reg[0:DIMENSION-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
   
	/*
      we need the above declared registers in the lower triangular matrix fashion, but
	  at the moment it is tough to generate some registers in that fashion so declaring 
	  a full two dimensional array but in that we use only lower triangular matrix elements.
	  Synthesis step will optimize.	  
	*/ 
 
	
	/*
	logic to separate iteration variables from x_bus, which is a single input    
	*/
	genvar i;
	wire [ITERATION_VARIABLE_WIDTH-1:0] ivar[0:DIMENSION-1];
	generate for(i=0; i<DIMENSION;  i=i+1)
		begin
			assign ivar[i] = x_bus[(i*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
	end
	endgenerate

	//***************************************************************************************************************//
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

	integer k;
	integer l;
	integer m;	
    integer kk,ll,mm;
	always@(posedge conf_clk or posedge reset)
	begin
		if(reset == 1'b1)
			begin
				conf_ack <= 1'b0;
				k <= 0;
				l <= 0;
				m <= 0;
				for (kk=0; kk<DIMENSION; kk=kk+1 )
       				for (ll=0; ll<=kk; ll=ll+1 )
       					for (mm=0; mm<NO_REG_TO_PROGRAM; mm= mm+1)
       						begin
       							if(mm == 0)
       								ivar_min_reg[kk][ll] <= 0;
       							else if(mm == 1)
       							    ivar_max_reg[kk][ll] <= 0;
       							else if (mm == 2)
       								ivar_sel_reg[kk][ll] <= 0;
       							else if (mm == 3)  
       								bypass_reg[kk][ll] <= 1; //changed from default 0 to 1
       								//synthesis translate_off	
       							else
       								$display ("unknown values for l in minmax_comparator_matrix.v");
       								//synthesis translate_on
       						end
						
			end
		else if (conf_ack == 1'b0 && sel == 3'b100) //this module is given a select id of 100  
			begin
				if(m == 0)
					begin 
						ivar_min_reg[k][l] <= conf_bus;
				 		m <= m + 1;		
					end	
				else if(m == 1)
					begin
						ivar_max_reg[k][l] <= conf_bus;
			 			m <= m + 1;		
					end
				else if (m == 2)
					begin
						ivar_sel_reg[k][l] <= conf_bus;
			 			m <= m + 1;		
					end			
				else   // m==  NO_REG_TO_PROGRAM -1
					begin
						if(l<k)
							begin
								bypass_reg[k][l] <= conf_bus; //only 1 bit is needed here
								m <= 0;
								l <= l+1;
							end
						else    // l==k or l>k
							begin
							   	bypass_reg[k][l] <= conf_bus; //only 1 bit is needed here
								m <= 0;
								l <= 0;
								// synthesis translate_off
									$display("%d row done",k);
									$display("%b output_selector bit value",temp_output_selector[k]);
									$display("%b output_selector+1 bit value",temp_output_selector[k+1]);
								// synthesis translate_on
								k <= k+1;
								if(temp_output_selector[k+1] == 1'b0)
 									begin
 										conf_ack <= 1'b1;
 						  			end
							end		
					end	
			end
	end
    //***************************************************************************************************************//
    
    /*
      generating/declaring wires to connect the multiplexers outputs see below
    */
	wire [ITERATION_VARIABLE_WIDTH-1:0] mux_out_wires[0:DIMENSION-1][0:DIMENSION-1];

   
	/*
	  generating multiplexers to select the appropriate iteration variables for the minmax
	  comparator matrix. Any comparator in any row or column can select any iteration variable
	  from the input based on the ivar_sel_reg, which are again programmed by the user. 	
	*/
	genvar u,v;
	generate 
		for(u = 0; u < DIMENSION ; u = u+1)
			for(v = 0; v < DIMENSION; v =v+1)
				begin
					if( v <= u)
						begin
							mux_ivar_select #(
									       	   .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
									           .DIMENSION(DIMENSION)
									         ) mux_ivar_select_inst
														           (.in(x_bus),
														            .s(ivar_sel_reg[u][v]),
														            .out(mux_out_wires[u][v])
														           );
						end
					else
						assign mux_out_wires[u][v] = 0;
					/*
					  This assignment doesn't make any sense as you cannot initialize a wire in verilog.
					  In the simulation you will see 'Z' or high impedance for these unused mux_out_wires.
					  I wrote this assignment for just completeness and later synthesis tool will through
					  away this logic.
					*/														           
				end
	endgenerate
	
		
	/*
	  generating/declaring wires to connect the outputs of the comparators 	
	*/
	wire comp_out [0:DIMENSION-1][0:DIMENSION-1];

		
	/*
	  generating minmax comparators (instantiation)	
	*/
	genvar p,q;
	generate
		for(p = 0; p < DIMENSION; p = p+1)
			for (q = 0; q < DIMENSION ; q = q+1)
				begin
                    if ( q <= p)
					minmax_comparator #(
										.ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH)
									   ) minmax_comparator_inst (.ivar(mux_out_wires[p][q]), 
                       	                                         .ivar_min(ivar_min_reg[p][q]), 
                       	                                         .ivar_max(ivar_max_reg[p][q]), 
                       	                                         .bypass(bypass_reg[p][q]), 
                       	                                         .c_out(comp_out[p][q])
                       	                                        );
                    else
                        assign comp_out[p][q] = 1'b1;  // undriven are driven with 1's                           
				end
	endgenerate

	/* 
	 * logic to make the comp_out to correct value in case of not using all dimensions.
	 */
	integer K=0;
	integer L=0;
	reg comp_out_temp[0:DIMENSION-1][0:DIMENSION-1];
	always@(*)
		begin
			for(K=0; K<DIMENSION; K=K+1)
				for(L=0; L<DIMENSION; L=L+1)
					begin
						if(temp_output_selector[K] == 1'b0)
							begin
								comp_out_temp[K][L]= 1'b0;	
							end						
						else
							begin
								comp_out_temp[K][L] = comp_out[K][L];
							end
						
					end	
					
		end	

	/*
      making comp_out_bus from comp_out array
    */
    wire [0:DIMENSION*DIMENSION-1] comp_out_bus;
    genvar pp,qq;
    generate
        for(pp = 0; pp < DIMENSION; pp = pp+1)
           for(qq = 0; qq < DIMENSION; qq = qq+1)
                begin
                    assign  comp_out_bus[(pp*DIMENSION+qq)*1+:1] = comp_out_temp[pp][qq]; 
                end
    endgenerate            
          
	/*
	  generating the temporary stride select signal. Here we need this signal because
	  even though you synthesize the design for a particular DIMENSION, you might use
      lesser number of iteration variables in that case the all temp_stride_select 
      signals are not valid and even the comparators outputs.	
	*/
	wire [0:DIMENSION-1] temp_stride_select;
 	genvar ii;
 	generate
 		for(ii=0; ii < DIMENSION; ii = ii+1)
			begin 
			reduction_and #( 
							.DIMENSION(DIMENSION)
						   ) reduction_and_inst (
												 .in(comp_out_bus[ii*DIMENSION+:DIMENSION]),
												 .out(temp_stride_select[ii])
												);
			end  
 	endgenerate

	/*
	  selecting the appropriate stride select signals based on the output_selector 
	  signals.If we use the lesser number of iteration variables compared to the DIMENSION
	  some stride_selects might not be valid and we are not interested in them so, we will
	  select the appropriate ones using the output_selector register signals.		 		
	*/		
	genvar n;
	generate 
		for(n=0; n <DIMENSION ; n=n+1)
			begin	
				assign stride_select[n] = output_selector[n] ? temp_stride_select[n] : 1'b0 ;
			end	
	endgenerate
	    
endmodule


/******************************************************************************
	*
	* REVISION HISTORY:
	*    
*******************************************************************************/
