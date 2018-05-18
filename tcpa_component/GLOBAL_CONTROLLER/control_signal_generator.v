/******************************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
* University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   control_signal_generator
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
* DATE:     
*
* ABSTRACT:  This piece of block is responsible for generating the required control signals.
             In this block you have the program blocks which are programmable by the user.
             You program only the required number of program blocks, rest of the unused or
             not programmed blocks won't influence the results. In the second part of the
             design, you will find the max bound registers which are also programmable by
             the user. Here, the main idea is that while we are scanning the iteration 
             space, we have to know which program block we are in and we have to compare
             the current value of the iteration variable with the max bound registers in 
             that program block and generate the required IC signals. For further details
             have a look in the doc folder. 
*            
******************************************************************************************/

module control_signal_generator (
								  conf_clk,
								  conf_bus, 
								  sel,
								  reset,
								  x_bus, 
								  output_selector,
								  pb_selector,
								  ic_selector, 
								  conf_ack, 
								  ic_out
								 );
	
	//parameters of this module
	parameter DIMENSION = 3;  //default value, represents the dimension of the iteration space
	parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
	parameter SELECT_WIDTH = 3; //default value, used for selecting this block for programming
	parameter NO_REG_TO_PROGRAM =4; //default value
	
	/*
	  following parameter indicates the number of program blocks that are going to be programmed.	  
	*/
	parameter MAX_NO_OF_PROGRAM_BLOCKS = 12; //default value
	
	/*
	  following parameter tells you that how many control signals are going to be generated.
	  Based on this parameter we can determine the number of max bound registers that  
	  will get programmed. For each program block, we have to program NUM_OF_IC_SIGNALS registers.
      In total, the number of such registers is equal to the product of 
      MAX_NO_OF_PROGRAM_BLOCKS * NUM_OF_IC_SIGNALS	
	*/	
    parameter NUM_OF_IC_SIGNALS = 3 ; //default value
	
	//inputs
	
	input conf_clk;
    // configuration clock
	
    input [ITERATION_VARIABLE_WIDTH-1:0] conf_bus;
    //configuration bus
	
    input [SELECT_WIDTH-1:0] sel;
    //select signal for programming registers in this block

	input [DIMENSION-1:0] output_selector;
    /* 
      even though you have synthesized the block for higher DIMENSION, at runtime you can limit
      the no.of dimensions. This input represents that. This value is coming from initializer block.
    */ 
	input [MAX_NO_OF_PROGRAM_BLOCKS-1:0] pb_selector;
    /* 
      even though you have synthesized the block for higher MAX_NO_OF_PROGRAM_BLOCKS, at runtime you can limit
      the no.of program blocks. This input represents that. This value is also coming from initializer block.
    */
	input [NUM_OF_IC_SIGNALS-1:0] ic_selector;
 	/*
      even though you have synthesized the block for higher NUM_OF_IC_SIGNALS, at runtime you can limit
      the no.of ic control signals. This input represents that. This value is also coming from initializer block.
    */
    
    input signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus;
    // current/present values of the iteration variables
	
    input reset;
	// reset of the block
	
	//outputs

	output [0:NUM_OF_IC_SIGNALS-1] ic_out;
	//reg [0:DIMENSION-1] ic_out;
    //these are the actual outputs that needs to be connected for tcpa

	output conf_ack;
	reg conf_ack;
    // this output goes high only after the configuration of this block is over

	/*
	  internal registers to hold the min, max values of the program blocks.
	  Remember that for each iteration variable we need two registers to hold 
	  min, max bounds of that iteration variable in that program block. That means
	  we need total "DIMENSION*2*MAX_NO_OF_PROGRAM_BLOCKS" registers.  	
	*/

	reg signed [ITERATION_VARIABLE_WIDTH-1:0] min_pb_reg_bank[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
	reg signed [ITERATION_VARIABLE_WIDTH-1:0] max_pb_reg_bank[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
	reg [DIMENSION-1:0] ivar_sel_reg[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
	//changed from 0:DIMENSION-1 to DIMENSION-1:0
	reg ignore_pb_comparator_reg [0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
	
	
	/*
	  internal registers to hold the min and max bound values for ic conditions in each program block 
	  These are used for generating the control signals. The number of registers depend on
	  the number of control signals that you want to generate. For each program
	  block we need DIMENSION* NUM_OF_IC_SIGNALS registers. In total number of registers 
	  required is MAX_NO_OF_PROGRAM_BLOCKS*NUM_OF_IC_SIGNALS*DIMENSION	
	*/
	reg signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_min_reg[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg signed [ITERATION_VARIABLE_WIDTH-1:0] ivar_max_reg[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg [DIMENSION-1:0] ic_ivar_sel_reg[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
    reg bypass_reg[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1] /* synthesis syn_preserve = 1 */;
	
	
	
    
    
    /*************************************************************************************************************/
    /*        filling internal registers: configuration of the block                                             */
    /*************************************************************************************************************/ 
	/*
	  filling internal registers based on the conf_clk and generating conf_ack after
	  loading is done	
	*/
	
    /*
	  creating temp_output_selector with extra one bit as in the case of programming
	  all the registers upto DIMENSION, we are going to refer to DIMENSION+1 bit 
	  and if it is zero the conf_ack or some other signal to 1 so that configuration
      stops. To work for all the cases appending the output_selector with 0 at MSB 
      position 		
	*/
	
	wire [DIMENSION:0] temp_output_selector;
	assign temp_output_selector = {1'b0,output_selector};
	
	/*
	  creating temp_pb_selector with extra one bit as in the case of programming
	  all the registers upto DIMENSION, we are going to refer to MAX_NO_OF_PROGRAM_BLOCKS+1 bit 
	  and if it is zero the conf_ack or some other signal is set to 1 accordingly. 
	  To work for all the cases appending the output_selector with 0 at MSB position 		
	*/
	wire [MAX_NO_OF_PROGRAM_BLOCKS:0] temp_pb_selector;
	assign temp_pb_selector = {1'b0,pb_selector};
	
	/*
	  creating temp_ic_selector with extra one bit as in the case of programming
	  all the registers upto NUM_OF_IC_SIGNALS, we are going to refer to NUM_OF_IC_SIGNALS+1 bit 
	  and if it is zero the conf_ack or some other signal is set to 1 accordingly. 
	  To work for all the cases appending the output_selector with 0 at MSB position 		
	*/
	wire [NUM_OF_IC_SIGNALS:0] temp_ic_selector;
	assign temp_ic_selector = {1'b0,ic_selector};
	
	   
    integer kk,ll,mm,nn;	
	
	integer k;
	integer l;
	integer p;
	integer q;
	integer m;
	integer n;
	integer r;

	//always@(posedge conf_clk or posedge reset)
	always@(posedge conf_clk)
		begin
			if(reset == 1'b1)
				begin
					/*
					 * initializing looping variables to avoid feedback muxes
					 */
					 
					 k <= 0;
					 l <= 0;
					 p <= 0;
					 q <= 0;				
					 m <= 0;
					 n <= 0;
					 r <= 0;
					/*
					 * 
					 */
					conf_ack <= 1'b0;                
					/*
                      all comparators min,max registers set to zero
                    */
                    for(ll=0; ll<MAX_NO_OF_PROGRAM_BLOCKS; ll=ll+1)
				    	for(kk=0; kk<DIMENSION; kk=kk+1)
				    		begin
				    			min_pb_reg_bank[ll][kk] <= 0;
				    			max_pb_reg_bank[ll][kk] <= 0;
				    			ivar_sel_reg[ll][kk] <= 0;
				    			ignore_pb_comparator_reg[ll][kk] <= 1'b1; //default value is 1
				    		end
                    /*
                      resetting all comparator registers in the ic calculation
                    */        
				    for(ll=0; ll<MAX_NO_OF_PROGRAM_BLOCKS;ll=ll+1)
				    	for(kk=0; kk<NUM_OF_IC_SIGNALS; kk=kk+1)
					    	for(mm=0; mm<DIMENSION; mm=mm+1)
						    	for(nn=0; nn<NO_REG_TO_PROGRAM; nn=nn+1)
				    				begin
				    					if(nn == 0)
       										ivar_min_reg[ll][kk][mm] <= 0;
       									else if(nn == 1)
       							    		ivar_max_reg[ll][kk][mm] <= 0;
       									else if (nn == 2)
       										ic_ivar_sel_reg[ll][kk][mm] <= 0;
       									else if (nn == 3)  
       										bypass_reg[ll][kk][mm] <= 1; //changed from default 0 to 1
       										//synthesis translate_off	
       									else
       										$display ("unknown values for l in minmax_comparator_matrix.v");
       										//synthesis translate_on
					    		
				    				end                   
				end	
			else if (conf_ack == 1'b0 && sel == 3'b101) //this module is given a select id of 5
				begin
					if(m == 0 && n==0)
						begin 
							min_pb_reg_bank[k][l] <= conf_bus;
							m <= m + 1;		
						end	
					else if(m == 1 && n==0)
						begin
							max_pb_reg_bank[k][l] <= conf_bus;
							m <= m + 1;		
						end
					else if (m == 2 && n==0)
						begin
							ivar_sel_reg[k][l] <= conf_bus;
							m <= m + 1;		
						end			
					else if (m == 3 && n==0)  
						begin
							ignore_pb_comparator_reg[k][l] <= conf_bus; //only one bit is needed here
							if(temp_output_selector[l+1] == 1'b0)
 								begin
 									n <= 1;
 									m <= 0;
 									l <= 0;	
 						  		end
 						  	else
 						  		begin
 						  			m <= 0;
 						  			n <= 0;
 						  			l <= l+1;
 						  		end	
 						end
					else if (m==0 && n==1)
						begin
							if(p==0)
								begin
									ivar_min_reg[k][q][r] <= conf_bus;
				 					p <= p + 1;										
								end
							else if(p==1)
								begin
									ivar_max_reg[k][q][r] <= conf_bus;
									p <= p + 1;		
								end
							else if(p==2)
								begin
									ic_ivar_sel_reg[k][q][r] <= conf_bus;
			 						p <= p + 1;		
								end
							else if(p==3)
								begin
									bypass_reg[k][q][r] <= conf_bus;
									if (temp_pb_selector[k+1] == 1'b0 && temp_output_selector[r+1] == 1'b0 && temp_ic_selector[q+1] == 1'b0 )
										begin
											//configuration is done.
											conf_ack <= 1'b1;
										end	
									else if (temp_output_selector[r+1] == 1'b0 && temp_ic_selector[q+1] == 1'b0)
										begin
											p <= 0;
											q <= 0;
											r <= 0;
											m <= 0; 
											n <= 0;
											k <= k+1;
										end	
									else if(temp_output_selector[r+1] == 1'b0)
										begin
											p <= 0;
											r <= 0;
											q <= q+1;
										end									
									else
										begin
											p <=0;
											r <= r+1;
										end									
								end									
						end
					
							
				end                   
		end	
    /*************************************************************************************************************/    
       
	/*
     	 generating/declaring wires to connect the multiplexers outputs see below
    */
	wire [ITERATION_VARIABLE_WIDTH-1:0] mux_out_wires[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1];

	/*
	  generating multiplexers to select the appropriate iteration variables for the min max
	  comparator matrix. Any comparator in any row or column can select any iteration variable
	  from the input based on the ivar_sel_reg, which are again programmed by the user. 	
	*/
	genvar u,v;
	generate 
		for(u = 0; u < MAX_NO_OF_PROGRAM_BLOCKS; u = u+1)
			for(v = 0; v < DIMENSION; v =v+1)
				begin
						mux_ivar_select_csg #(
								       	   	   .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
								       	   	   .DIMENSION(DIMENSION)
								       	   	 ) mux_ivar_select_csg_inst (
								       	   	 						  .in(x_bus),
								       	   	 						  .s(ivar_sel_reg[u][v]),
								       	   	 						  .out(mux_out_wires[u][v])
								       	   	 						);																	           
				end
	endgenerate
	
	/*
	  generating/declaring wires to connect the outputs of the comparators 	
	*/
	wire comp_out [0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1];
	
	/*
	  instantiating min_max_comparator for program blocks 
	*/
      
    genvar i,j;
	generate 
		for (i=0; i < MAX_NO_OF_PROGRAM_BLOCKS; i=i+1)
			for (j=0; j < DIMENSION; j=j+1)
				begin
					min_max_comparator_csg #(
											 .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH)
											) minmax_comparator_csg_inst (
									   							 		   // Inputs
									   							 		   .ivar(mux_out_wires[i][j]),
									   							 		   .ivar_min(min_pb_reg_bank[i][j]),
									   							 		   .ivar_max(max_pb_reg_bank[i][j]),
									   							 		   .ignore_pb_comparator(ignore_pb_comparator_reg[i][j]),
									   							 		   // Outputs
									   							 		   .c_out (comp_out[i][j])
									   							 		 );
				end 	
	endgenerate
	
	/* 
	 * logic to make the comp_out to correct value in case of not using all program blocks and 
	 * or even all dimensions.
	 */
	integer K=0;
	integer L=0;
	reg comp_out_temp[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:DIMENSION-1];
	always@(*)
		begin
			for(K=0; K<MAX_NO_OF_PROGRAM_BLOCKS; K=K+1)
				for(L=0; L<DIMENSION; L=L+1)
					begin
						if(temp_pb_selector[K] == 1'b0)
							begin
								comp_out_temp[K][L]= 1'b0;	
							end	
						else if(temp_output_selector[L] == 1'b0)
							begin
								comp_out_temp[K][L] = 1'b1;
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
    wire [0:MAX_NO_OF_PROGRAM_BLOCKS*DIMENSION-1] comp_out_bus;
    genvar pp,qq;
    generate
        for(pp = 0; pp < MAX_NO_OF_PROGRAM_BLOCKS; pp = pp+1)
           for(qq = 0; qq < DIMENSION; qq = qq+1)
                begin
                    assign  comp_out_bus[(pp*DIMENSION+qq)*1+:1] = comp_out_temp[pp][qq]; 
                end
    endgenerate            
          
	/*
	  buf enable signal	
	*/
	wire buf_enable[0:MAX_NO_OF_PROGRAM_BLOCKS-1];
    
 	genvar ii;
 	generate
 		for(ii=0; ii < MAX_NO_OF_PROGRAM_BLOCKS; ii = ii+1)
			begin 
			reduction_and_csg #( 
								.DIMENSION(DIMENSION)
							   ) reduction_and_csg_inst (
												 		  .in(comp_out_bus[ii*DIMENSION+:DIMENSION]),
												 		  .out(buf_enable[ii])
												 		);
			end  
 	endgenerate
 	
 	          
    /*
     	 generating/declaring wires to connect the multiplexers outputs see below
    */
	wire [ITERATION_VARIABLE_WIDTH-1:0] ic_mux_out_wires[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1];
    
	/*
	  generating multiplexers to select the appropriate iteration variables for the if else
	  comparators that are generating IC signals. Any if else comparator can select from any iteration variable
	  from the input based on the if_else_ivar_sel_reg, which are again programmed by the user. 	
	*/
	genvar uu,vv,ww;
	generate 
		for(uu = 0; uu < MAX_NO_OF_PROGRAM_BLOCKS; uu = uu+1)
			for(vv = 0; vv <NUM_OF_IC_SIGNALS; vv = vv+1)
				for(ww = 0; ww <DIMENSION; ww = ww+1)
					begin
						mux_ivar_select_csg #(
								       	   	   .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
								       	   	   .DIMENSION(DIMENSION)
								       	   	 ) mux_ivar_select_csg_if_else_inst (
								       	   	 						  			 .in(x_bus),
								       	   	 						  			 .s(ic_ivar_sel_reg[uu][vv][ww]),
								       	   	 						  			 .out(ic_mux_out_wires[uu][vv][ww])
								       	   	 									);																	           
					end
	endgenerate
	
	wire comp_out_ic[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1][0:DIMENSION-1];
	genvar i1,j1,k1;
	generate 
		for (i1=0; i1 < MAX_NO_OF_PROGRAM_BLOCKS; i1=i1+1)
			for(j1=0; j1 < NUM_OF_IC_SIGNALS; j1=j1+1)
				for (k1=0; k1 < DIMENSION; k1=k1+1)
					begin
						min_max_comparator_ic #(
											 	.ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH)
											) min_max_comparator_ic_inst (
									   							 		   // Inputs
									   							 		   .ivar(ic_mux_out_wires[i1][j1][k1]),
									   							 		   .ivar_min(ivar_min_reg[i1][j1][k1]),
									   							 		   .ivar_max(ivar_max_reg[i1][j1][k1]),
									   							 		   .bypass(bypass_reg[i1][j1][k1]),
									   							 		   // Outputs
									   							 		   .c_out (comp_out_ic[i1][j1][k1])
									   							 		 );
				end 	
	endgenerate
	
	
	wire [0:DIMENSION-1] comp_out_ic_wires[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1];
	genvar c;
	genvar d;
	genvar e;
	generate 
		for(c=0; c < MAX_NO_OF_PROGRAM_BLOCKS; c=c+1)
			for(d=0; d < NUM_OF_IC_SIGNALS; d=d+1 )
				for(e=0; e < DIMENSION; e=e+1 )
					begin
						assign comp_out_ic_wires[c][d][e] = comp_out_ic[c][d][e];
					end	
	endgenerate
	/*
	 * 
	 */
	wire ic_out_wires_temp[0:MAX_NO_OF_PROGRAM_BLOCKS-1][0:NUM_OF_IC_SIGNALS-1];
	genvar x;
	genvar y;
	generate
		for(x = 0; x < MAX_NO_OF_PROGRAM_BLOCKS; x = x+1)
			for (y=0; y<NUM_OF_IC_SIGNALS; y=y+1)
				begin
					assign ic_out_wires_temp[x][y] = &comp_out_ic_wires[x][y];
				end		
	endgenerate
	
	/*
	 * creating ic_out_bus
	 */
	wire [0:MAX_NO_OF_PROGRAM_BLOCKS*NUM_OF_IC_SIGNALS-1] ic_out_bus;
	genvar aa;
	genvar bb;
	generate
		for(aa = 0; aa < MAX_NO_OF_PROGRAM_BLOCKS; aa = aa+1)
			for(bb = 0; bb < NUM_OF_IC_SIGNALS; bb = bb+1)
				begin
					assign ic_out_bus[(aa*NUM_OF_IC_SIGNALS+bb)*1+:1]= ic_out_wires_temp[aa][bb];    
				end
	endgenerate
	
	
	/*
	 * converting buf_enable unpacked array into packed array
	 */    
    wire [MAX_NO_OF_PROGRAM_BLOCKS-1:0] buf_enable_temp;
    genvar zz;
    generate 
	    for (zz=0; zz<MAX_NO_OF_PROGRAM_BLOCKS; zz=zz+1)
        	begin  
                 assign buf_enable_temp[zz]= buf_enable[zz];
            end                    
    endgenerate
    
    /*
     * selecting appropriate ic values based on the program block
     */    
    
    mux_one_hot_csg # (
    				   .MAX_NO_OF_PROGRAM_BLOCKS(MAX_NO_OF_PROGRAM_BLOCKS),
    				   .NUM_OF_IC_SIGNALS(NUM_OF_IC_SIGNALS)
    				  ) mux_one_hot_csg_inst (
    				  						 	//Inputs
    				  						 	.in(ic_out_bus),
    				  						 	.s(buf_enable_temp),
    				  						 	.out(ic_out)
    				  						 	//Outputs
    				  						 );
    
endmodule
