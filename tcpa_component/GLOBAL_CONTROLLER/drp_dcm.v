/******************************************************************************
* (C) Copyright 2012  Chair for Hardware/Software Co-Design,
University of Erlangen-Nuremberg. All Rights Reserved
*
* MODULE:   drp_dcm.v
* DEVICE:     
* PROJECT:  Global Controller 
* AUTHOR:   Srinivas Boppu (Srinivas.Boppu@informatik.uni-erlangen.de)   
* DATE:     2012 12:19:40 PM
*
* ABSTRACT: This module generates the required clocks for the Global Controller.
* You can customize the file content form Templates "verilog File"
*            
*******************************************************************************/

`timescale 1ns / 1ps

module drp_dcm ( clkin_in, 
                 rst_in, 
                 clk0_out, 
                 locked_out,
                 dclk,
                 den,
                 di,
                 daddr,
                 dwe,
                 dout,
                 drdy,
                 clkfx_out                                               
               );

   input clkin_in;
   input rst_in;
   input dclk;
   input [6:0] daddr;
   input [15:0] di;
   input dwe;
   input den;
   
   output clk0_out;
   output locked_out;
   output [15:0] dout;
   output drdy;
   output clkfx_out;
   
   wire clkfb_in;   
   wire clk0_buf;
   wire clkfx_buf;      
                          
   BUFG  CLK0_BUFG_INST (.I(clk0_buf), 
                         .O(clkfb_in)
                        );
                        
   BUFG  CLKFX_BUFG_INST (.I(clkfx_buf), 
                          .O(clkfx_out)
                        );

   //Ericles Sousa: If you face any clock buffer cascade problem, please replace the port map assingment of "CLK0_BUFG_INST" and "CLK0_BUFG_INST" by the following lines:
   //assign   clkfb_in  = clk0_buf;
   //assign   clkfx_out = clkfx_buf;
   //assign   clk0_out  =  clkfb_in;
                  
   DCM_ADV #( .CLK_FEEDBACK("1X"), 
   			  .CLKDV_DIVIDE(2.0), 
   			  .CLKFX_DIVIDE(2), 
   			  .CLKFX_MULTIPLY(4), 
   			  .CLKIN_DIVIDE_BY_2("FALSE"), 
   			  .CLKIN_PERIOD(10.000), 
   			  .CLKOUT_PHASE_SHIFT("NONE"), 
   			  .DCM_AUTOCALIBRATION("TRUE"), 
   			  .DCM_PERFORMANCE_MODE("MAX_SPEED"), 
   			  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
   			  .DFS_FREQUENCY_MODE("LOW"), 
   			  .DLL_FREQUENCY_MODE("LOW"), 
   			  .DUTY_CYCLE_CORRECTION("TRUE"), 
   			  .FACTORY_JF(16'hF0F0), 
   			  .PHASE_SHIFT(0), 
   			  .STARTUP_WAIT("FALSE"), 
   			  .SIM_DEVICE("VIRTEX5") 
   			  ) DCM_ADV_INST ( .CLKFB(clkfb_in),                         	   
                         	   .CLKIN(clkin_in), 
                         	   .DADDR(daddr), 
                         	   .DCLK(dclk), 
                         	   .DEN(den), 
                         	   .DI(di), 
                         	   .DWE(dwe), 
                         	   .PSCLK(1'b0), 
                         	   .PSEN(1'b0), 
                         	   .PSINCDEC(1'b0), 
                         	   .RST(rst_in), 
                         	   .CLKDV(), 
                         	   .CLKFX(clkfx_buf), 
                         	   .CLKFX180(), 
                         	   .CLK0(clk0_buf), 
                         	   .CLK2X(), 
                         	   .CLK2X180(), 
                         	   .CLK90(), 
                         	   .CLK180(), 
                         	   .CLK270(), 
                         	   .DO(dout), 
                         	   .DRDY(drdy), 
                         	   .LOCKED(locked_out), 
                         	   .PSDONE()
                         	);
                         	
endmodule

/******************************************************************************
*
* REVISION HISTORY:
*    
*******************************************************************************/
