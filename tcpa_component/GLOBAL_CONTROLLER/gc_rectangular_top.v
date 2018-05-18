/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   gc_rectangular_top
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
* DATE:     
*
* ABSTRACT:  This is the top level design for rectangular global controller design.
*            
*******************************************************************************/

module gc_rectangular_top ( 
				conf_clk, 
				conf_bus, 
				reset,   
				tcpa_clk, 
				stop, 
				start, 
				global_en,
				restart_ext,
				dclk_in,
				pdone,
				ic,
				config_done,
				config_busy,
				conf_en,
				cready,
				current_i,
				current_j,
				current_k,
				x_bus,
				ivar_next_bus,
				reinitialize,
				gc_done,
				dcm_lock,
				gc_clk
	    		  );
	
	/* 
	  parameters of the design
	*/
	parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
	parameter DIMENSION = 3; //default value
	parameter SELECT_WIDTH = 3; //default value
	parameter NO_REG_TO_PROGRAM = 4; //default value
	parameter MATRIX_ELEMENT_WIDTH = 8; //default value
 	parameter DATA_WIDTH = 8; //default value
 	parameter MAX_NO_OF_PROGRAM_BLOCKS = 35; //35 for MatMul //for FIR it has to be 12 //default value
 	parameter NUM_OF_IC_SIGNALS = 3; //default value
 	
	/*
	  inputs	
	*/
	
	// configuration clock
	input conf_clk;
	
	// configuration bus, later connected to APB slave interface
	//or the memory in the APB slave interface 	
	input [ITERATION_VARIABLE_WIDTH-1:0] conf_bus;
	
	// global reset
	input reset;
	
	// tcpa design clock 
	input tcpa_clk;
	
	// clock for the dynamic reconfiguration port, please refer to "ug191.pdf" from xilinx for more details
	input dclk_in;
	
	// stop signal for global controller.Ex: in case if buffer empty some one should inform global controller
	input stop;
	
	// start signal for GC, after initial configuration need this signal to start GC. After stopping to restart GC also we need this signal
	input start;
	
	//by forcing this signal from outside, we can restart the global controller again
	input restart_ext;
	
	//signal indicating that memory in apb_slave is populated with the relevant programming data
	input pdone; 
	
	/*
	  outputs  	
	*/

	//these signals are connected to tcpa at ic ports
	output [0:NUM_OF_IC_SIGNALS-1] ic;
	
	//indicates that various registers in different instances present in the gc are programmed.
	//this signal is used in slave interface; when this signal goes high we stop reading from
	//apb slave memory
	output config_done;
	
	//indicates that loader fsm is changing state; it can't take any value from the memory
	//this signal is only high for one clock cycle
	output config_busy;
	
	//indicates that loader fsm is ready 
	//once the apb slave memory is populated with relevant data (pdone goes high) 
	//configuration starts
	output conf_en;
	
	//this output signal is can be used to enable all peripheries (e.g., AGs) of a TCPA
	output global_en;
	
	//this is to inform the others that gc is programmed and dcm lock is done.
	//basically a start signal and stop signal are expected to either start or stop
	//the gc from a central managing component
	output cready;
	reg cready;
    output [31:0] current_i;
    output [31:0] current_j;
    output [31:0] current_k;
    output [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus;
    output [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] ivar_next_bus;    
    output reinitialize;
    output gc_done;
    output dcm_lock;
    output gc_clk;


	// wires connecting the different module/instances	
	wire config_done;
	wire [1:0] current_state;
	wire config_busy;
	wire conf_ack;
	wire [SELECT_WIDTH-1:0] sel;
	wire [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus;
	wire [DIMENSION-1:0] output_selector;
	wire conf_ack_ns;
	wire [0:DIMENSION-1] stride_select;
	wire conf_ack_ss;
	wire [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] ivar_next_bus;
	wire conf_ack_csg;
	wire [0:NUM_OF_IC_SIGNALS-1] ic_in;
	wire conf_ack_initializer;
	wire [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] init_ivar;
	wire [0:NUM_OF_IC_SIGNALS-1] init_ic;
	wire reinitialize;
	wire gc_done;
	wire conf_ack_reinitializer_rect;
	wire restart_mode;
	wire restart_ext;
	wire gc_clk;
	wire [ITERATION_VARIABLE_WIDTH-1:0] iteration_interval;
	
	wire [MAX_NO_OF_PROGRAM_BLOCKS-1:0] pb_selector;
	wire [NUM_OF_IC_SIGNALS-1:0] ic_selector;
	
	wire dcm_lock;
	
	
	/*
	  instantiating sub modules
	*/		
	
	control_fsm #(
		       .DIMENSION(DIMENSION),
		       .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH) 
			 )control_fsm_inst (
					   // Inputs
					   .reset(reset),
					   .gc_clk(gc_clk),   
					   .config_done(config_done),
					   .restart_mode(restart_mode),
					   .reinitialize(reinitialize),
					   .init_ivar(init_ivar),
					   .init_ic(init_ic),
					   .ivar_next(ivar_next_bus),
					   .ic_in(ic_in),
					   .restart_ext(restart_ext),
					   .start(start),
					   .stop(stop),
					   .dcm_lock(dcm_lock),					  
					   // Outputs
					   .global_en(global_en),
					   .conf_en(conf_en),
					   .current_state(current_state),
					   .x_bus_reg(x_bus),
					   .iteration_interval(iteration_interval),
					   .ic(ic)
					 );
	
    //loader fsm instantiation								  
	 
    loader_fsm loader_fsm_inst (
    						     // Inputs
    						     .conf_clk(conf_clk),
    						     .conf_en(conf_en),
    						     .reset(reset),
    						     .conf_ack(conf_ack),
    						     .pdone(pdone),
    						     // Outputs
    						     .config_done(config_done),
    						     .current_select(sel),
    						     .config_busy(config_busy)
    						   );
    //minmax matrix comparator matrix instantiation to calculate
    //the next state (iteration variables) 								  
	
	minmax_comparator_matrix #(
							   .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
							   .DIMENSION(DIMENSION), 
							   .SELECT_WIDTH(SELECT_WIDTH), 
							   .NO_REG_TO_PROGRAM(NO_REG_TO_PROGRAM)
							  ) minmax_comparator_matrix_inst (
							  							 	    // Inputs
							  							 	    .conf_clk(conf_clk),
							  							 	    .conf_bus(conf_bus),
							  							 	    .reset(reset),
							  							 	    .sel(sel),
							  							 	    .x_bus(x_bus),
							  							 	    .output_selector(output_selector),							  							 	    
							  							 	    // Outputs
							  							 	    .conf_ack(conf_ack_ns),
							  							 	    .stride_select(stride_select)
							  							 	  );
	stride_selector_ripple #(
							 .DIMENSION(DIMENSION), 
							 .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
							 .MATRIX_ELEMENT_WIDTH(MATRIX_ELEMENT_WIDTH), 
							 .SELECT_WIDTH(SELECT_WIDTH)
							) stride_selector_ripple_inst (
															// Inputs
															.conf_clk(conf_clk),
															.conf_bus(conf_bus),
															.reset(reset),
															.sel(sel),
															.x_bus(x_bus),
															.output_selector(output_selector),
															.stride_select(stride_select),
															// Outputs
															.ivar_next(ivar_next_bus),
															.conf_ack(conf_ack_ss)
														  );						  							 	                                                                                  
	/*
	  logic to separate next iteration variables from ivar_next_bus, which is a single input
	  to see them element wise.	
	*/
	genvar z;
	wire [ITERATION_VARIABLE_WIDTH-1:0] i_next[0:DIMENSION-1];
	generate
		for(z=0; z<DIMENSION; z=z+1)
			begin
				assign i_next[z] = ivar_next_bus[(z*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
			end
	endgenerate
	
	genvar y;
	wire [ITERATION_VARIABLE_WIDTH-1:0] i_current[0:DIMENSION-1];
	generate
		for(y=0; y<DIMENSION; y=y+1)
			begin
				assign i_current[y] = x_bus[(y*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
			end
				assign	current_i[31:ITERATION_VARIABLE_WIDTH] = 0;
				assign	current_j[31:ITERATION_VARIABLE_WIDTH] = 0;
				assign	current_k[31:ITERATION_VARIABLE_WIDTH] = 0;
				assign	current_i[ITERATION_VARIABLE_WIDTH-1:0] = i_current[2];
				assign	current_j[ITERATION_VARIABLE_WIDTH-1:0] = i_current[0];
				assign	current_k[ITERATION_VARIABLE_WIDTH-1:0] = i_current[1];
	endgenerate
										  
    control_signal_generator #(
								.DIMENSION(DIMENSION), 
								.ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
								.SELECT_WIDTH(SELECT_WIDTH), 
								.MAX_NO_OF_PROGRAM_BLOCKS(MAX_NO_OF_PROGRAM_BLOCKS), 
								.NUM_OF_IC_SIGNALS(NUM_OF_IC_SIGNALS)
							  ) control_signal_generator_inst (
							  									// Inputs
							  									.conf_clk(conf_clk),
							  									.conf_bus(conf_bus),
							  									.sel(sel),
							  									.reset(reset),
							  									.x_bus(ivar_next_bus),   //changing x_bus or i_current to ivar_next_bus or i_next
							  									.output_selector(output_selector),
							  									.pb_selector(pb_selector),
							  									.ic_selector(ic_selector),
							  									// Outputs
							  									.conf_ack(conf_ack_csg),
							  									.ic_out(ic_in)
							  								  );             						  								  
    initializer #(
      			   .DIMENSION(DIMENSION), 
      			   .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH), 
      			   .SELECT_WIDTH(SELECT_WIDTH),
      			   .MAX_NO_OF_PROGRAM_BLOCKS(MAX_NO_OF_PROGRAM_BLOCKS), 
      			   .NUM_OF_IC_SIGNALS(NUM_OF_IC_SIGNALS)
      			 ) initializer_inst ( 
                                      // Inputs
									  .conf_clk(conf_clk),
									  .conf_bus(conf_bus),
									  .reset(reset),
                                      .sel(sel),
									  // Outputs
                                      .init_ivar(init_ivar),
                                      .init_ic(init_ic),
                                      .output_selector(output_selector),
                                      .conf_ack(conf_ack_initializer),
                                      .restart_mode(restart_mode),
                                      .pb_selector(pb_selector),
                                      .ic_selector(ic_selector)                                     
                                    );                            
    	
   
   	mux_conf_ack_select #(
   						  .SELECT_WIDTH(SELECT_WIDTH)	
   						) mux_conf_ack_select_inst (
                                                	 .in1(conf_ack_clock_generator),
                                                	 .in2(conf_ack_initializer),
                                                	 .in3(conf_ack_ss),
                                                	 .in4(conf_ack_ns),
                                                	 .in5(conf_ack_csg),
                                                	 .in6(conf_ack_reinitializer_rect), 
                                                	 .sel(sel),
                                                	 .out(conf_ack)
                                                   );
                                                   
                                           
   reinitializer_rect #(
		 				.DIMENSION(DIMENSION), 
		 				.SELECT_WIDTH(SELECT_WIDTH), 
		 				.ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH)
		 			   ) reinitializer_rect_inst (
		 			   							    // Inputs
		 			   							   .conf_bus(conf_bus),
		 			   							   .conf_clk(conf_clk),
		 			   							   .reset(reset),
		 			   							   .x_bus(x_bus),
		 			   							   .sel(sel),
		 			   							   .output_selector(output_selector),
		 			   							   // Outputs
		 			   							   .conf_ack(conf_ack_reinitializer_rect),
												   .gc_done(gc_done),
		 			   							   .reinitialize(reinitialize)
		 			   							 );                                      
    
    wire gc_clk_clkfx;

	clock_generator #(
			   		  .DATA_WIDTH(DATA_WIDTH),
			   		  .SELECT_WIDTH(SELECT_WIDTH),
					  .ITERATION_VARIABLE_WIDTH(ITERATION_VARIABLE_WIDTH)
			  		 ) clock_generator_inst (
						   						//Inputs
						   						.clkin_in(tcpa_clk),
						   						.reset(reset),
						   						.dclk_in(dclk_in),
						   						.conf_clk(conf_clk),
						   						.conf_bus(conf_bus),
						   						.sel(sel),
						   						//Outputs
						   						.clk0_out(tcpa_clk_out),
						   						.clkfx_out(gc_clk_clkfx),
						   						.locked_out(dcm_lock),
												.div_reg(iteration_interval),
                                        		.conf_ack(conf_ack_clock_generator)
                                     		);
	
	//cready logic
	always@(*)
		begin
			cready = config_done && dcm_lock;
		end
      
    BUFGCTRL bufgctrl (.O(gc_clk), .CE0(1'b1), .CE1(1'b1), .I0(tcpa_clk), .I1(gc_clk_clkfx), .IGNORE0(1'b1), .IGNORE1(1'b1), .S0(~dcm_lock), .S1(dcm_lock));

endmodule
/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
