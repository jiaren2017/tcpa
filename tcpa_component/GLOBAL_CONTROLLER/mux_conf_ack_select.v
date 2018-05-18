/******************************************************************************
* (C) Copyright 2012  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   mux_conf_ack_select
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu   
* DATE:     
*
* ABSTRACT: This module is used to select the appropriate configuration acknowledge
            signal from different components(conf_ack)
*            
*******************************************************************************/
module mux_conf_ack_select (in1, in2, in3, in4, in5, in6, sel, out);
    
    /*
      parameters of the design	
    */
    parameter SELECT_WIDTH = 3; //
    
    /*
      inputs	
    */
    input in1,in2,in3,in4,in5,in6;
    input [SELECT_WIDTH-1:0] sel;  
     
    /*
      outputs
    */ 
    output out;
    reg out;

    /*
      procedural block to update the out
    */
    always@(in1 or in2 or in3 or in4 or in5 or in6 or sel)
        begin
            case(sel)
                3'b000: out = 1'b0;     //idle state in loader fsm
                3'b001: out = in1;      //clock generator
                3'b010: out = in2;      //initializer
                3'b011: out = in3;      //stride selector
                3'b100: out = in4;      //nextstate :minmax_comparator_matrix
                3'b101: out = in5;      //control signal generator
                3'b110: out = in6;      //reinitializer rectangular block          
                default: out = 1'b0;
            endcase     
        end    
endmodule
/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
