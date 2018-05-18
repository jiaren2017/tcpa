
module gc_apb_slave_mem ( 
							clk,
							resetn,
							paddr,
							pwrite,
							pwdata,
							psel,
							penable,
							conf_en,
							rnready,
							config_done,
							prdata,
							dout,
							pdone,
							gc_irq,
							isr_en,
							delay_counter,
							gc_reset
								
	                );
	
	//parameters
	parameter NO_OF_WORDS = 1024;
	
	//inputs
	
	// clock 
	input clk;
	
	//active low reset
	input resetn;
	
	//adrress
	input [31:0] paddr;
	
	//read/write enable
	input pwrite;
	
	//input data/write data
	input [31:0] pwdata;
	
	//select signal
	input psel;
	
	//enable signal
	input penable;
	
	//conf_en 
	input conf_en;
	
	//read not ready
	input rnready;
	
	//config_done
	input config_done;

	//gc_irq = 1 wen GC raises an IRQ. Otherwise, it is 0
	input gc_irq;
	
	//outputs
	output [31:0] prdata;
	reg [31:0] prdata;
	
	//configuration data
	output [31:0] dout;
	reg [31:0] dout;
	
	//memory in the slave device
	reg [31:0] data[0:NO_OF_WORDS-1];
	
	//indicates the memory is populated 
	output pdone;
	reg pdone; 
	
	//reset signal for gc 
	output gc_reset;
	reg gc_reset;
	
	output [31:0] isr_en;
	reg [31:0] isr_en;
	
	output [31:0] delay_counter;
	reg [31:0] delay_counter;
	
	//wires for read/ write
	wire [31:0] prdata_out;
	wire [31:0] data_in;
	
	//reset memory 
	integer i;
	always@(posedge clk or negedge resetn)
		begin
			if(~resetn) 
				begin
					for(i=0; i < NO_OF_WORDS-1; i=i+1)
						begin
							//data[i] <= 0; --introduced by Ericles
						end
					prdata <= 32'd0;	
				end
			else   // enable phase
				begin
					isr_en <= data[1];
					delay_counter <= data[2];

					data[paddr[11:2]] <= data_in;
					prdata <= prdata_out;
					
        
					if((gc_irq == 1'b1) && (pdone == 1'b1) && (gc_reset == 1'b0))
						begin
							data[0][2] <= 1'b1;
						end
					else
						begin
							data[0][2] <= 1'b0;
						end
				end
		end	
	
	//write data capture (setup phase:true )
	assign data_in = (psel && !penable && pwrite) ? pwdata : data[paddr[11:2]]; 
	
	//read data capture (setup phase:true)
	assign prdata_out = (psel && !penable && !pwrite) ? data[paddr[11:2]] : prdata;
		
	//the following logic is to read from the memory once the it is populated 
	//with all programming data.
	always@(posedge clk or negedge resetn)
		begin
			if(~resetn)
				begin
					pdone <= 1'b0;
					gc_reset <= 1'b1; //active high reset
				end	
			else
				begin
					pdone <= data[0][0];
					if(data[0][1] == 1'b1)
						begin 
							gc_reset <= data[0][1];
						end
					else
						begin 
							gc_reset <= 1'b0;
						end
				end	
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
					//Starts from 3, because the 3 first values i.e., addr 0, 1, and 2 are defined as start/stop GC, En GC IRQ, and interrupt delay counter, respectively.
					count <= 3;
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
						if(~gc_reset)
							begin
								next_state = current_state;
								next_dout = 32'd0;
								next_count = count;
							end
						else
							begin
								next_state = S0;
								next_dout = 32'd0;
								next_count = 1;
							end	
								
				end
			endcase
		end					
endmodule	
	
