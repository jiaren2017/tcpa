/******************************************************************************
* (C) Copyright 2014  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   clock_generatorDCM
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

module clock_generatorDCM (
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
		conf_ack
		  );
		
		/*
		  parameters of the design
		*/
		parameter D_ADDRESS = 7; // DRP address bus width
		parameter D_IN = 16; // DRP data in bus width
		parameter D_O = 16; // DRP data out bus width
		parameter DATA_WIDTH = 8; //data bus width of the configuration data bus (conf_bus)
		parameter SELECT_WIDTH = 3;
		
		//input source clock for the DCM
		input clkin_in; 
		
		//global reset of the design
		input reset;
		
		//dynamic reconfiguration port clock
		input dclk_in;
		
		//configuration clock
		input conf_clk;
		
		//configuration bus;
		input [DATA_WIDTH-1:0] conf_bus;
		
		//select ID for configuring the clock generator
		input [SELECT_WIDTH-1:0] sel;
	
		//same as clkin_in but it comes out from DCM as output, can be used it but is not used in global controller design
		output clk0_out; 
		
		//this is the output clock on which the global controller design runs 
		output clkfx_out; 
		
		//shows the status of the DCM
		output locked_out; 
		reg locked_out;
		
		//configuration acknowledgment
	    output conf_ack;
	    reg conf_ack;
	  
		reg rst_dcm; // register for the dcm reset
		reg next_rst_dcm;
		
		reg den;  // DRP port enable register
		reg next_den;
		
	    reg dwe; // DRP port write enable register
	    reg next_dwe;
		
		// registers for the current, next states
		reg [2:0] current_state;
		reg [2:0] next_state;
		
		// registers for the address for the DRP port
		reg [D_ADDRESS-1:0] daddr;
		reg [D_ADDRESS-1:0] next_daddr;
		
		// counter to count the number of reads 
		reg [1:0] count;
		reg [1:0] next_count;
		
		// input data bus for the DRP port of DCM
		reg [D_IN-1:0] di;
		reg [D_IN-1:0] next_di;
		
		    //this register holds the output of the dout port for further processing
		reg [D_O-1:0] dout_reg;
	  
		/*
		 this register get programmed according to the iteration interval. 
		 This is the only one register that get programmed by the configuration
		 logic,(configuration bus, configuration clock) 
		*/

	   	reg [DATA_WIDTH-1:0] div_reg /* synthesis syn_preserve = 1 */;
	
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
	        
	        
	    // Dynamic Reconfiguration Protocol Implementation, refer to UG191.pdf,page No: 108
	    
	    /*
	      state encoding	
	   	*/
	
       	/*
          reset state
       	*/ 	
       	parameter RESET = 3'b000;
	    
	   	/*
	      den, enable read for reading phase
       	*/	

       	parameter READ_PREPARE = 3'b001; 
	    
        /*
          read wait: waiting for drdy to go high, look for DRP documention (ug191.pdf) for more information
       	*/ 
       	parameter READ_WAIT = 3'b010; // read wait
	    /*
          process the readout registers, here the data read from address 50h,41h,51h and finally 00h
          and processed. For more details look for DRP doument from xilinx (ug191.pdf)
       	*/	
       	parameter PROCESS_DATA = 3'b011; 
	    /*
          den enable (write), preparing to write data  
       	*/

       	parameter WRITE_PREPARE = 3'b100; 
       	/*
 	      write wait: waiting for drdy to go high
       	*/

       	parameter WRITE_WAIT = 3'b101; // write wait
       	/*
	      drp done release reset of dcm, wair for lock
	   	*/
	   	parameter DRP_DONE = 3'b110;
	   	/*
	      locked sate
       	*/	
       	parameter LOCKED = 3'b111; 
	  

       	wire [D_O-1:0] dout;
       	wire drdy;
       	wire drp_dcm_locked_out;
     
		/*******************************************************************************************/
          	/*  Look up table for M and D values                                                       */
		/*******************************************************************************************/
		reg [D_IN-1:0] m_d_reg;
		always@(div_reg)
			begin
				case(div_reg)					
				0: m_d_reg = 16'h0101; // 0 corresponds to divide by 1 same as below
				1: m_d_reg = 16'h0101; // 1 corresponds to multiply 2(01) divide by 2(01)
				2: m_d_reg = 16'h0103; // 2 corresponds to multiply 2(01) divide by 4(03)
				3: m_d_reg = 16'h0105; // 3 corresponds to multiply 2(01) divide by 6(05)
				4: m_d_reg = 16'h0107; // 4 corresponds to multiply 2(01) divide by 8(05)
				5: m_d_reg = 16'h0109; // 5 corresponds to multiply 2(01) divide by 10(09)
				6: m_d_reg = 16'h010B; // 6 corresponds to multiply 2(01) divide by 12(0B)
				7: m_d_reg = 16'h010D; // 7 corresponds to multiply 2(01) divide by 14(0D)
				8: m_d_reg = 16'h010F; // 8 corresponds to multiply 2(01) divide by 16(0F), look ug191.pdf
                //changing default case to divided by 1
				//default : $display ("Please check div_register");		
				default : m_d_reg = 16'h0101;		
				endcase
			end 	
 		/*******************************************************************************************/

	  	always@(posedge dclk_in or posedge reset)
	  	begin
	  		if(reset == 1'b1)
	  			begin
	  				current_state <= RESET;
	  				rst_dcm <= 1'b1;
	  				den <= 1'b0;
	  				dwe <= 1'b0;
	  				daddr <= 7'b0;
	  				di <= 16'b0;
	  				count <= 2'b0;
					dout_reg <= 0;			
				  end
			else if (conf_ack == 1'b1)			
				begin
					current_state <= next_state;
					rst_dcm <= next_rst_dcm;
					den <= next_den;
					dwe <= next_dwe;
					daddr <= next_daddr;
					di <= next_di;
					count <= next_count;
					dout_reg <= dout;
				end
	   	end		
	   	always@(*)
	   	begin
			case(current_state)
		  	RESET: begin
		  	       	if(conf_ack == 1'b1)
		  	        	begin  
		  	        		next_rst_dcm = 1'b1;
		  	        		next_den = 1'b0;
		  	        		next_dwe = 1'b0;
		  	        		next_daddr=7'b0;
		  	        		next_di = 16'b0;	
		  	        		next_state = READ_PREPARE;
		  	        		next_count = count;
		  	        	end
		  	        else
		  	        	begin
		  	        		next_rst_dcm = rst_dcm;
		  	        		next_den = den;
		  	        		next_dwe = dwe;
		  	        		next_daddr = daddr;
		  	        		next_di = di;	
		  	        		next_state = RESET;
		  	        		next_count = count;
		  	        	end			 
		   	       end
	 	  	READ_PREPARE: begin
							next_rst_dcm = 1'b1;
					  		next_den = 1'b1;
					  		next_dwe = 1'b0;
					  		next_daddr=7'h50;
					  		next_di = 16'b0;
					  		next_state = READ_WAIT;
					  	
					  		//input address logic
					  		if (count == 2'b00)
					  			next_daddr= 7'h50;
					  		else if (count == 2'b01)
					  			next_daddr= 7'h41;
					  		else if (count == 2'b10)
					  			next_daddr= 7'h51;
					  		else
					  			next_daddr= 7'd0;
					  						  		
					  		next_count = count;	
		 		       	end	 
		 	READ_WAIT: begin
							next_den = 1'b0;
							next_dwe = 1'b0;
							next_daddr= 7'b0;
							next_di = 16'b0;
						
							if(drdy == 1'b1 && count < 2'b11)
								begin
					  				next_state = PROCESS_DATA;
									next_rst_dcm = 1'b1;
								end
					  		else if (drdy == 1'b1 && count == 2'b11)
					  	    	begin
									next_state = DRP_DONE;
									next_rst_dcm = 1'b0;
								end
					  		else    
					  			begin
									next_state = READ_WAIT;
									next_rst_dcm = 1'b1;	
								end	
					  				
		    				next_count = count;
		    			end
		  	PROCESS_DATA: begin
							next_rst_dcm = 1'b1;
						
							//input masking logic
							if(count == 2'b00)
								next_di = m_d_reg;  
							else if (count == 2'b01)
						     	next_di = {dout_reg[15:3],1'b0,dout_reg[1:0]};
							else if (count == 2'b10)
						     	next_di = {dout_reg[15:4],1'b0,1'b0,dout_reg[1:0]};
							else
								next_di = 0;
						     							
							next_den = 1'b0;
							next_dwe = 1'b0;
							next_daddr=7'b0;
							next_state = WRITE_PREPARE;
							next_count = count;
		    		      end
		  	WRITE_PREPARE: begin
							next_rst_dcm = 1'b1;
							next_di = di;
							next_den = 1'b1;
							next_dwe = 1'b1;
						
							//input address logic
	                    	if (count == 2'b00)
		                    	next_daddr= 7'h50;
	                    	else if (count == 2'b01)
                        		next_daddr= 7'h41;
	                    	else if (count == 2'b10)
                        		next_daddr= 7'h51;
                        	else
                        		next_daddr= 7'd0;
						
							next_state = WRITE_WAIT;
							next_count = count;
		   			   	   end
		  WRITE_WAIT: begin
						next_rst_dcm = 1'b1;
						next_den = 1'b0;
						next_dwe = 1'b0;
						next_daddr=7'h00;
                    	next_di = di;  
						if(drdy == 1'b1) // if DRDY increment the counter value
							begin
								next_state = READ_PREPARE;
					  			next_count = count + 1;
					  		end
						else
							begin
					  			next_state = WRITE_WAIT;
					  			next_count = count;
					  		end				
		    		  end
		  DRP_DONE: begin
			    		next_rst_dcm = rst_dcm;
                    	next_di = di;
                    	next_daddr= daddr;
                    	next_den = den;
		  	        	next_dwe = dwe;
                    	next_count = count;

			        	if(locked_out == 1'b1)
					    	begin
				      			next_state = LOCKED;
				      		end
			          	else
				        	begin
					       		next_state = DRP_DONE;
				        	end	
		            end
		  LOCKED: begin
			  	    next_rst_dcm = rst_dcm;
                    next_di = di;
                    next_daddr =daddr;
                    next_den = den;
		  	        next_dwe = dwe;
			        next_state = LOCKED;
                    next_count = count;
		          end
         //adding default state         
         default: begin
                    next_rst_dcm = rst_dcm;
		  	        next_den = den;
		  	        next_dwe = dwe;
		  	        next_daddr = daddr;
		  	        next_di = di;	
		  	        next_state = RESET;
		  	        next_count = count;
                  end        
                  
		  endcase
	   end
	   
	   //  DCM instantiation
	   drp_dcm drp_dcm_inst (
                              // Inputs
                              .clkin_in(clkin_in),
                              .rst_in(rst_dcm),
                              .dclk(dclk_in),
                              .den(den),
                              .di(di),
                              .daddr(daddr),
                              .dwe(dwe),
                              // Outputs
                              .clk0_out(clk0_out),
                              .locked_out(drp_dcm_locked_out),
                              .dout(dout),
                              .drdy(drdy),
                              .clkfx_out(clkfx_out)                             
                           );
       //making sure that locked_out is low when reset
       always@(posedge dclk_in or posedge reset)
       begin
       		if(reset==1'b1)
       			locked_out <= 1'b0;
       		else
       			locked_out <= drp_dcm_locked_out;
       end       			               	
                           
endmodule
/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
