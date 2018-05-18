`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    14:16:05 12/28/08
// Design Name:    
// Module Name:    my_CG_MOD
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

// User defined clock gating module
// rc_lps_ug.pdf, p. 120

module my_CG_MOD (ck_in, enable,test,ck_out);

	input ck_in,enable,test;
	output ck_out;

//	wire tm_out, ck_inb;
//	reg enl;
//
//	assign tm_out = enable | test;
//	assign ck_inb = ~ck_in;
//	
//
//	always @ (ck_inb or tm_out)
//		if (ck_inb)
//			enl = tm_out;
//	
//	assign ck_out = ck_in & enl;

  //GCKESX4 GATING_INST(.E (enable), .CK (ck_in), .TE (test), .Q
  //     (ck_out));

  CKLNQD4 GATING_INST(.E (enable), .CP (ck_in), .TE (test), .Q (ck_out));

endmodule

