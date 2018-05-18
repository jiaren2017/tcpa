module my_or_csg (in,out);
  
  parameter MAX_NO_OF_PROGRAM_BLOCKS = 12;
  parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions
  
  input signed [0:MAX_NO_OF_PROGRAM_BLOCKS*ITERATION_VARIABLE_WIDTH-1] in;
  output signed [ITERATION_VARIABLE_WIDTH-1:0] out;
  reg signed [ITERATION_VARIABLE_WIDTH-1:0] out;

  genvar i;
  wire [ITERATION_VARIABLE_WIDTH-1:0] in_array[0:MAX_NO_OF_PROGRAM_BLOCKS-1];
  generate for(i=0; i<MAX_NO_OF_PROGRAM_BLOCKS;  i=i+1)
    begin
	  assign in_array[i] = in[(i*ITERATION_VARIABLE_WIDTH)+:ITERATION_VARIABLE_WIDTH];
	end
  endgenerate
      
  reg signed [ITERATION_VARIABLE_WIDTH-1:0] temp;
   
  integer j;
  always@(*)
    begin
      temp = 0;  
      for(j=0; j<MAX_NO_OF_PROGRAM_BLOCKS; j=j+1)
          begin
              temp = temp | in_array[j];
          end    
      out <= temp;  
    end   
       
endmodule
