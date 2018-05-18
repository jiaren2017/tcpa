/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   loader_fsm
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
* DATE:     
*
* ABSTRACT: This modules select different blocks in the global controller that  
*           needs to be configured one by one. Each individual blocks may have
            some registers to be configured. 
*******************************************************************************/

module loader_fsm ( conf_clk, 
		    		conf_en, 
		    		reset, 
		    		conf_ack,
		    		pdone,
		    		config_done, 
		    		current_select,
		    		config_busy
                  );
	
	/*
	  inputs
	*/
	input conf_en;
	input conf_ack;
	input conf_clk;
	input reset;
	
	//input indicating that apb slave memory is populated
	//with the relevant programming data
	input pdone;
	
	/*
	  outputs	
	*/
	output config_done;
	reg config_done;
	output [2:0] current_select /* synthesis syn_preserve = 1 */;
	reg [2:0] current_select;
	output config_busy;
	reg config_busy;
	
	/*
	  state encoding 	
	*/
	
	parameter S0 = 3'b000, //idle state
		  	  S1 = 3'b001, //clock generator configuration
		      S2 = 3'b010, //initializer configuration 
		      S3 = 3'b011, //stride selector configuration, path stride matrix 
		      S4 = 3'b100, //next state rectangular module configuration 
		      S5 = 3'b101, //control signal generator configuration
		      S6 = 3'b110, //reinitializer 
		      S7 = 3'b111; //config done

	/*
	  intermediate registers...etc
	*/
	reg [2:0] next_select /* synthesis syn_preserve = 1 */;
	reg next_config_done;	
	
	/*
	  procedural block to initialize the state based on the reset  	 
	*/
	always@(posedge conf_clk or posedge reset)
	begin
		if (reset)
            begin 
	    		current_select <= S0;
               	config_done <= 1'b0; 
			end
        else
        	begin
           		current_select <= next_select;
		        config_done <= next_config_done;	        	
			end
	end
    	
	/*
	  procedural block to calculate the next select
	*/
   
    always@(*)
	begin
		case(current_select)
            	S0 : begin
	            		if(conf_en == 1'b1 && pdone == 1'b1) //pdone added:10/06/2014
                        	begin 
	                        	next_select = S1;
                        		next_config_done = 1'b0;	                        	
                        	end
	            		else
		            		begin
			            		next_select = S0;
			            		next_config_done = 1'b0;
			            		// synthesis translate_off
                        		$strobe ("loader fsm idle state......");
                        		// synthesis translate_on
			            		
			            	end	
					 end
				S1 : begin
						if (conf_ack == 1'b1)
            				begin   
            					next_select = S2;
	                    		next_config_done = 1'b0;
	                    		// synthesis translate_off
	                    		$strobe ("configuring clock generator...DONE");
	                    		// synthesis translate_on
							end
						else
							begin	
								// synthesis translate_off
								$strobe ("configuring clock generator...");
								// synthesis translate_on
								next_select = S1;
	                    		next_config_done = 1'b0;								
							end
					 end 	 
				S2 : begin
						if (conf_ack == 1'b1)
            				begin   
            					next_select = S3;
	                    		next_config_done = 1'b0;
	                    		// synthesis translate_off
	                    		$strobe ("configuring initializer...DONE");
	                    		// synthesis translate_on
							end
						else
							begin	
								// synthesis translate_off
								$strobe ("configuring initializer...");
								// synthesis translate_on
								next_select = S2;
	                    		next_config_done = 1'b0;
							end
					 end	
				S3 : begin
						if (conf_ack == 1'b1)
            				begin
            					next_select = S4;
              					next_config_done = 1'b0;
              					// synthesis translate_off
              					$strobe ("configuring stride selector...DONE");
              					// synthesis translate_on	
           					end
           				else
           					begin
           						// synthesis translate_off
           						$strobe ("configuring stride selector...");
           						// synthesis translate_on
           						next_select = S3;
           						next_config_done = 1'b0;
							end
					 end	
				S4 : begin
						if (conf_ack == 1'b1)
							begin
								next_select = S5;
								next_config_done = 1'b0;
								// synthesis translate_off
								$strobe ("configuring next state rectangular/non-rectangular module...DONE");
								// synthesis translate_on	
							end
						else
							begin
								// synthesis translate_off
								$strobe ("configuring next state rectangular/non-rectangular module...");
								// synthesis translate_on
								next_select = S4;
								next_config_done = 1'b0;
							end
					 end
            	S5 : begin
                 		if(conf_ack == 1'b1)
                    		begin
                    			next_select = S6;
                    			next_config_done = 1'b0;
                    			// synthesis translate_off
                    			$strobe ("configuring control signal generator...DONE");
                    			// synthesis translate_on	
                    		end
                    	else
                    		begin
                        		// synthesis translate_off
                        		$strobe ("configuring control signal generator...");
                        		// synthesis translate_on
                        		next_select = S5;
                        		next_config_done = 1'b0;
							end    
                     end
                 S6 : begin
                 		if(conf_ack == 1'b1)
                    		begin
                        		next_select = S7;
                        		next_config_done = 1'b1;
                        		// synthesis translate_off
                        		$strobe ("configuring reinitializer...DONE");
                        		// synthesis translate_on	
                    		end
                    	else
                    		begin
                        		// synthesis translate_off
                        		$strobe ("configuring reinitializer generator...");
                        		// synthesis translate_on
                        		next_select = S6;
                        		next_config_done = 1'b0;
							end    
                     end                     
                S7 : begin
                 		next_select = S7;
                    	next_config_done = 1'b1;
                    	// synthesis translate_off
                    	$strobe ("loader fsm config_done state...CONFIG DONE");
                    	// synthesis translate_on 
            	     end	

		endcase 
	end	
	
	always@(*)
		begin
			config_busy = conf_ack;
		end	
endmodule

/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
