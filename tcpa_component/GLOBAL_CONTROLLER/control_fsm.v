/********************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   control_fsm
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de).
* DATE:     
*
* ABSTRACT: This module is a finite state machine that controls the whole operation 
			of the global controller IP. This control fsm has 4 states:
			configure, initialization, run and final. In the configure
			state it controls the loader fsm to configure all the submodules in
			the design. Next, initialization stage is like for loop initialization
			and then immediately in the next cycle we go to run stage and at the
			end once we reach the boundaries  we may enter into the final state
			depending on the restart and reconfigure signal.
                        Several extensions has been added by Ericles Sousa.
*            
*******************************************************************************/

//`define FPGA_SYNTHESIS;  

module control_fsm (
					 reset, 
					 gc_clk, 
					 config_done, 
					 restart_mode, 
					 conf_en, 
					 reinitialize, 
					 init_ivar, 
					 init_ic, 
					 ivar_next, 
					 ic_in,
					 restart_ext,
					 start,
					 stop,
					 global_en,
					 dcm_lock,
					 current_state, 
					 x_bus_reg, 
					 iteration_interval,
					 ic
				   );
	
	
	/*
	  parameters of the design	
	*/
	parameter DIMENSION = 3; //default value
	parameter ITERATION_VARIABLE_WIDTH = 16; //default value
	parameter NUM_OF_IC_SIGNALS = 3; //default value
	
	/*
	  inputs 	
	*/
	input reset;   //active high reset of the design
	input gc_clk;  //the clock upon which the global controller design runs 
	
    input config_done; 
    // input from the loader fsm that says that the configuration of all other sub blocks/design is done

	input restart_mode; 
	/* 
       This input is coming from the initializer block where while programming the user can decide when 
       the full iteration space is over whether he wants start from the beginning or not. If YES, the
       user might have programmed the corresponding register in initializer block to 1,so that this input
       is 1
    */
    input reinitialize;
    /*
      This input is coming from the re-initializer block. It is a one bit value and it is high only when
      we reach the last iteration point in the iteration space 
    */
	
    input [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] init_ivar;
    /*
     This input is coming from the initializer block. It denotes the starting initial iteration.
     It is required in this block for the following reasons
     1) If the global controller is programmed in a mode where it has to restart after reaching the final
        iteration, it has to know from where it has to start i.e, the initial iteration.  
    */
	
    input [0:NUM_OF_IC_SIGNALS-1] init_ic;
    /*
     This input is coming from the initializer block. It denotes the starting or initial "ic" conditions.
     It is required in this block for the following reasons.
     1) If the global controller is programmed in a mode where it has to restart after reaching the final
     iteration, it has to know what were the initial "ic" values.    
    */
	
    input [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] ivar_next;
    /*
      this input denotes the next iteration value
    */
	
    input [0:NUM_OF_IC_SIGNALS-1] ic_in;
    /*
      these are the control signals coming from the control signal generator block
    */
	
    input restart_ext;
    /*
      this input is for external control to restart. For example,the user did not programmed the global
      controller design in a restart mode, i.e, when we reach the end of the iteration space it will 
      we will restart again from the initial iteration. If the user did not choose this option the GC
      design or this control fsm will go to a "final" state and just stays there. In this situation 
      if the user issues "restart_ext" signal it will restart from initial iteration and the user need
      not program any registers as this is still same design. The user can also issue a "reset" signal
      in this case,the complete design restarts that means all the registers are erased and the user has
      to start programming all the blocks in the design.
    */
	input start;
	reg start_gc;
	reg first_cycle;
        integer i;
        localparam DELAY = 4;
        reg [0:DIMENSION-1] ic_shift_reg [DELAY-1:0];
        reg [DELAY:0] start_shift_reg; 
        reg [DELAY:0] stop_shift_reg; 
    /*
      this input is required to start the global controller. Once the programming of all the blocks
      is done, it sends out an acknowledgment signal "conf_ack" and waits for the start signal.
    */
	input stop;
    /*
      this input is required for example, the global controller design is already running and there was
      a buffer event (empty or so), in this case someone has to inform the global controller to stop.      
    */
	input dcm_lock;
	/*
	  this input shows the status of the DCM lock, it is high only if the clk_fx o/p is stabilized.
	*/	
		
    /*
      outputs
    */
    output [1:0] current_state /* synthesis syn_preserve = 1 */;
    reg [1:0] current_state;
    /*
      This output represents the current state of the control FSM whether it is in "configure, 
      initialize, run or final stages.      
    */
    
	output conf_en;
	reg conf_en;
	/*
	  this output is required to indicate the loader fsm start configuring all the sub designs/blocks.
	  It is active high only in configure stage, in remaining stages it would be low. 
	*/ 
   
    output signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus_reg;
	reg signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] x_bus_reg;
	/*
	  this output is the current iteration value that needs to be connected to all other sub designs.	  
	*/
	
    output [0:DIMENSION-1] ic;
	reg [0:DIMENSION-1] ic;
	/*
	  these are the final outputs from the global controller, which needs to be connected to ic inputs
	  of the TCPA array processing elements. 
	*/
	
    output reg global_en;
	/*
	  this output signal can be used to enable all peripheries (e.g., AGs) of a TCPA
	*/
    
    input [ITERATION_VARIABLE_WIDTH-1:0] iteration_interval;
	/*
	  this input signal is the iteration interval. It corresponds to the second values of the configuration file of the global controller
	*/
   
    /*
      state encoding
    */	
	parameter S0 = 2'b00,  //configure state
			  S1 = 2'b01,  //initialization state			  
			  S2 = 2'b10,  //run state
			  S3 = 2'b11;  //final state	
	
	/*
	  intermediate registers...etc
	*/
	reg [1:0] next_state /* synthesis syn_preserve = 1 */;
	reg next_conf_en;
	reg signed [0:DIMENSION*ITERATION_VARIABLE_WIDTH-1] next_x_bus_reg;
	reg [0:DIMENSION-1] next_ic;
	reg global_en_s;
	reg [ITERATION_VARIABLE_WIDTH-1:0] counter;
	
	/*
	  procedural block to initialize the state based on the reset  	 
	*/
	
	always@(posedge gc_clk or posedge reset)
	begin
		 if(reset)
			begin		
			 	current_state <= S0;
				conf_en <= 1'b1;
				x_bus_reg <= 0;
				ic <= 0;
				global_en_s <= 0;
                                start_gc <= 0;
				first_cycle <= 1;
				counter <= 8'b0;
                                
				for(i = 0; i <= DELAY-1; i = i+1)
					begin
						ic_shift_reg[i] <= 0; 
						start_shift_reg[i] <= 0;
		                                stop_shift_reg[i] <= 0;
                                	end
			end
		 else
			begin
				if(config_done == 1'b1 && counter == (iteration_interval-1)) begin
					counter <= 8'b0;
			 		current_state <= next_state;

					conf_en <= next_conf_en;
					x_bus_reg <= next_x_bus_reg;
		                        //ic <= next_ic;		
	                                start_shift_reg[0] <= start;
	                                stop_shift_reg[0] <= stop;
					global_en = global_en_s;

					for(i = 0; i <= DELAY-2; i = i+1) begin
	                        		ic_shift_reg[i] <= ic_shift_reg[i+1];
					end 

					if(stop_shift_reg[0] == 0 && start_shift_reg[0] == 1) begin
						global_en_s <= 1; //this signal can be used to enable all peripheries. However, only AGs need to receive it.
					end 

					else begin
						global_en_s <= 0; 
					end
		
					if (first_cycle == 1 && start_shift_reg[0] == 1) begin
					//if (first_cycle == 1 && start == 1) begin
						//PEs only start when IC='1'. Thus, in the fisrt cycle we set all existing ICs to '1'. 
						//Only after that, the IC signals are generated according to a global controller configuration.
						//ic <= 7; //All 3 bits are set to 1
						ic_shift_reg[DELAY-2] <= 7;
						first_cycle <= 0;
					end
					else begin
						ic_shift_reg[DELAY-1] <= next_ic;
			                        //ic_shift_reg[0] <= next_ic;
	                       			ic <= ic_shift_reg[0];		
					end
				end
				else if(config_done == 1'b0) begin
					counter <= 0;
				end 
				else begin
					counter <= counter + 1;
				end 
			end
	end
	
	/*
	  procedural block to calculate the next state
	*/
	//always@(config_done or restart_mode or reinitialize or current_state or ivar_next or init_ivar or ic_in or init_ic or restart_ext or start or stop)
	always@(*)
	begin
		case(current_state)
            S0 : begin								//CONFIGURE stage	
                    if(config_done == 1'b1 && start_shift_reg[0] == 1'b1 && stop_shift_reg[0] == 1'b0 && dcm_lock == 1'b1)
				 	    begin	
						    next_state = S1;
						    next_conf_en = 1'b0; 
						    next_x_bus_reg = init_ivar;
						    next_ic = init_ic;
				 	    end
                    else
                        begin
                                                    next_state = S0;
						    next_conf_en = 1'b1;
						    next_x_bus_reg = 0;
						    next_ic = 0;					    
                        end      
                 end
			S1 : begin									//INITIAL stage
					if(!stop)
						begin  
							next_state = S2;
							next_conf_en = 1'b0;
							next_x_bus_reg = ivar_next;
							next_ic = ic_in;
						end
					else
						begin
							next_state = S1;
							next_conf_en = conf_en;  
							next_x_bus_reg = x_bus_reg;
							next_ic = ic;
						end			  
				 end

			S2 : begin									// RUN stage
					if(!stop)
						begin	 
							if(reinitialize == 1'b1)
				 				begin
				 					if (restart_mode == 1'b1)
				 						begin
				 							next_state = S1;
				 							next_conf_en = 1'b0;
				 							next_x_bus_reg = init_ivar;
				 							next_ic = init_ic;
				 							//synthesis translate_off
				 							//$display ("Run stage: No stop signal, reached final iteration .... restart mode is true going to initial stage");
				 							//synthesis translate_on
				 						end
				 					else					 					
				 						begin
					 						if(restart_ext == 1'b0) //false condition
						 						begin	
				 									next_state = S3;
				 									next_conf_en = 1'b0;
				 									next_ic = ic_in;
				 									next_x_bus_reg = 0;
				 									//synthesis translate_off
				 									//$display ("Run stage: No stop signal, reached final iteration ....restart mode is false, restart_ext is also false going to final stage");
				 									//synthesis translate_on
						 						end
					 						else
						 						begin
							 						next_state = S1;
				 									next_conf_en = 1'b0;
							 						next_x_bus_reg = init_ivar;
				 									next_ic = init_ic;				 									
				 									//synthesis translate_off
				 									//$display ("Run stage: No stop signal, reached final iteration ....restart mode is false, but restart_ext is true going to initial stage");
				 									//synthesis translate_on
							 					end						 						
				 						end			
				 				end
				 			else
				 				begin
				 					next_state = S2;
				 					next_conf_en = 1'b0;
				 					next_x_bus_reg = ivar_next;
				 					next_ic = ic_in;
				 					//synthesis translate_off
				 					//$strobe ("Run stage: No stop signal, not reached final iteration yet....");
				 					//synthesis translate_on
				 				end
						end
					else
						begin
							next_state = S2;
							next_conf_en = conf_en;  
							next_x_bus_reg = x_bus_reg;
							next_ic = ic;
							//synthesis translate_off
				 			//$display ("Run stage:  stop signal issued....will continue in this run stage until stop signal goes low in this stage");
				 			//synthesis translate_on
						end			
				 end
		    S3 : begin										//FINAL stage
		    		if(!stop)
		    			begin
		    				if(restart_ext)
								begin
									next_state = S1;
									next_conf_en = 1'b0;
									next_x_bus_reg = init_ivar;
									next_ic = init_ic;
									//synthesis translate_off
									//$display ("Final stage:  No stop signal ..restart_ext signal is high, starting with initial state again");									 
									//synthesis translate_on						
								end	
							else
								begin
									next_state = S3;
									next_conf_en = 1'b0;
									next_x_bus_reg = 0;
									next_ic = 0;
									//synthesis translate_off
									//$display ("Final stage:  No stop signal ..will continue in this final stage until restart_ext signal goes high (no programming) or reset signal goes high(programming) ");
									//synthesis translate_on
								end
		    			end
		    		else
		    			begin
		    				next_state = S3;
			    			next_conf_en = conf_en;  
							next_x_bus_reg = x_bus_reg;
							next_ic = ic;
		    				        //synthesis translate_off
				 			//$display ("Run stage:  stop signal issued....will continue in this run stage until stop signal goes low in this stage");
				 			//synthesis translate_on
		    			end					
				 end	    	 	 
		endcase 
	end	
endmodule

/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
