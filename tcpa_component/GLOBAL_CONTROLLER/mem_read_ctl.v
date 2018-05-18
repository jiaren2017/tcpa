module mem_read_ctl ( 
						clk,
						resetn,								
						conf_en,
						rnready,
						config_done,
						pdone,
						dout								
	                );
	
	//parameters
	parameter NO_OF_WORDS = 256;
	
	//inputs
	
	// clock 
	input clk;
	
	//active low reset
	input resetn;
		
	//conf_en 
	input conf_en;
	
	//read not ready
	input rnready;
	
	//config_done
	input config_done;
		
	//pdone 
	input pdone;
	
	//configuration data
	output [31:0] dout;
	reg [31:0] dout;
	
	//memory in the slave device
	reg [31:0] data[0:NO_OF_WORDS-1];
	
	initial
		begin
			$readmemh("/home/boppu/data_fir_csg12.dat", data); 
		end	
		
	//reading from memory
	reg [1:0] current_state;
	reg [1:0] next_state;
	reg [31:0] next_dout;	
	integer count;
	integer next_count;	
	
	/*
      state encoding
    */	
	parameter S0 = 2'b00,  //reset state
			  S1 = 2'b01,  //read state			  
			  S2 = 2'b10,  //wait state
			  S3 = 2'b11;  //done state	
	
	always@(posedge clk or negedge resetn)
		begin
			if(~resetn)
				begin
					current_state <= S0;
					dout <= 32'd0;
					count <= 1;
				end
			else
				begin
					current_state <= next_state;
					dout <= next_dout;
					count <= next_count;
				end	
		end
	always@(*)
		begin
			case(current_state)
				S0:begin //RESET state
						if(pdone == 1'b1 && conf_en == 1'b1)
							begin
								next_state = S1;
								next_dout = data[count];
								next_count = count + 1;
							end
						else
							begin
								next_state = current_state;
								next_dout = 32'd0;
								next_count = count;
							end	
				   end
				S1:begin //READ state
						if(rnready == 1'b1)
							begin
								next_state = S2;
								next_dout = dout;
								next_count = count;
							end
						else if(config_done == 1'b1)
							begin
								next_state = S3;
								next_dout = 32'd0;
								next_count = count;
							end
						else
							begin
								next_state = current_state;
								next_dout = data[count];
								next_count = count + 1;
							end	
				   end	
				S2:begin //WAIT state
						next_state = S1;
						next_dout = data[count];
						next_count = count+1;
				   end			
				S3:begin //memory read done state
						next_state = current_state;
						next_dout = 32'd0;
						next_count = count;
				end
			endcase
		end					
endmodule	
	
