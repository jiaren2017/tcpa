module my_or (in,out);
  
  parameter DIMENSION = 3;
  parameter MATRIX_ELEMENT_WIDTH = 8;
  
  input signed [0:DIMENSION*MATRIX_ELEMENT_WIDTH-1] in;
  output signed [MATRIX_ELEMENT_WIDTH-1:0] out;
  reg signed [MATRIX_ELEMENT_WIDTH-1:0] out;

  genvar i;
  wire [MATRIX_ELEMENT_WIDTH-1:0] in_array[0:DIMENSION-1];
  generate for(i=0; i<DIMENSION;  i=i+1)
    begin
	  assign in_array[i] = in[(i*MATRIX_ELEMENT_WIDTH)+:MATRIX_ELEMENT_WIDTH];
	end
  endgenerate
      
  reg signed [MATRIX_ELEMENT_WIDTH-1:0] temp;
   
  integer j;
  always@(*)
    begin
      temp = 0;  
      for(j=0; j<DIMENSION; j=j+1)
          begin
              temp = temp | in_array[j];
          end    
      out <= temp;  
    end    
       
endmodule
