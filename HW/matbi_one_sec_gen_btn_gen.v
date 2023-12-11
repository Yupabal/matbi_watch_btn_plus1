//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Yupabal
//
// Create Date: 2023.12.10
// License : https://github.com/Yupabal/matbi_watch_btn_plus1
// Design Name: 
// Module Name: matbi_one_sec_gen_btn_gen
// Project Name:
// Target Devices:
// Tool Versions:
// Description: To generate one sec and btn tick
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
 
`timescale 1ns / 1ps
module matbi_one_sec_gen(
    clk,
    reset,
	i_run_en,
	i_freq,
    o_one_sec_tick,
	o_btn_tick
    );
parameter P_COUNT_BIT = 30; // (default) 30b 
input 						clk;
input 						reset;
input 						i_run_en;
input [P_COUNT_BIT-1:0]		i_freq;
output reg					o_one_sec_tick;
output reg					o_btn_tick;

	reg 	[P_COUNT_BIT-1:0] 	r_counter; 

	always @(posedge clk) begin
	    if(reset) begin
			r_counter <= {P_COUNT_BIT{1'b0}};
			o_one_sec_tick <= 1'b0;
			o_btn_tick <= 0;
	    end else if (i_run_en) begin
			if(r_counter == i_freq -1) begin
				r_counter <= 0;
				o_one_sec_tick <= 1'b1;
			end
			else if(r_counter==70000000) begin //Only this can be activated on 100MHz. If you use this watch on any frequency, you will need divider('/'). But divider use many logic resources.
				o_btn_tick <= 1'b1;
				r_counter <= r_counter + 1'b1;
			end
			else begin
				r_counter <= r_counter + 1'b1;
				o_one_sec_tick <= 1'b0;
				o_btn_tick <= 0;
			end
		end else begin
			o_one_sec_tick <= 1'b0;
			o_btn_tick <= 0;
		end
	end
endmodule