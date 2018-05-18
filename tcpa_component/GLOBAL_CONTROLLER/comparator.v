/******************************************************************************
    * (C) Copyright 2014 Chair for Hardware/Software Co-Design,
    University of Erlangen-Nuremberg. All Rights Reserved
    *
    * MODULE:   comparator.v
    * DEVICE:     
    * PROJECT:  Global Controller 
    * AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
    * DATE:     
    *
    * ABSTRACT: This design compares the two input signals and produces the 
    *           output signal equals to logic 1 if both inputs are equal else
    *           logic 0.     
    *            
*******************************************************************************/

module comparator (a,b,out);
  
  parameter ITERATION_VARIABLE_WIDTH = 16; // default value. Ericles: The previous value was 8. Consequently the GC was able to do only 256 iteractions

  input signed [ITERATION_VARIABLE_WIDTH-1:0] a;
  input signed [ITERATION_VARIABLE_WIDTH-1:0] b;
  
  output out /* synthesis syn_keep = 1 */;
  reg out;

  always@(*)
    begin
        out = (a==b) ? 1'b1:1'b0; 
    end
endmodule
