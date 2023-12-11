//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Yupabal
//
// Create Date: 2023.12.10
// License : https://github.com/Yupabal/matbi_watch_btn_plus1
// Design Name: 
// Module Name: matbi_watch_btn_plus1_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Top module matbi_watch_btn_plus1_top
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module matbi_watch_top(
    clk,
    reset,
	i_run_en,
	i_freq,
	btn,
    o_sec,
    o_min,
    o_hour
    );
parameter P_COUNT_BIT = 30; // (default) 30b, under 1GHz. 2^30 = 1073741824
parameter P_SEC_BIT	 = 6; // 2^6 = 64
parameter P_MIN_BIT	 = 6; // 2^6 = 64 
parameter P_HOUR_BIT = 5; // 2^5 = 32 

input 							clk;
input 							reset;
input 							i_run_en;
input		[P_COUNT_BIT-1:0]	i_freq;
input		[3:0]				btn;
output reg 	[P_SEC_BIT-1:0]		o_sec;
output reg 	[P_MIN_BIT-1:0]		o_min;
output reg 	[P_HOUR_BIT-1:0]	o_hour;

wire w_one_sec_tick;
wire w_btn_tick;

// Gen one sec
matbi_one_sec_gen 
# (
	.P_COUNT_BIT	(P_COUNT_BIT) 
) u_matbi_one_sec_gen(
	.clk 				(clk			),
	.reset 				(reset			),
	.i_run_en			(i_run_en		),
	.i_freq				(i_freq			),
	.o_one_sec_tick 	(w_one_sec_tick	),
	.o_btn_tick			(w_btn_tick)
);

// reg [6-1:0] r_min_cnt;
// reg [12-1:0] r_hour_cnt;
reg	[31:0] sub_min = 0;
reg	[31:0] sub_hour = 0;
reg	[31:0] valid_min = 0;
reg [31:0] valid_hour = 0;
reg		   r_valid_min = 0;
reg		   r_valid_hour = 0;

wire sec_tick = o_sec == 60-1;
wire min_tick = o_min == 60-1;
wire hour_tick = o_hour == 24-1;
wire sec_tick_sub = o_sec == 60-1-1;

	always @(posedge clk) begin
	    if(reset) begin
			o_sec		<= 0;
		end else if(w_one_sec_tick) begin
			if(sec_tick) begin
				o_sec		<= 0;
				r_valid_min <= 0;
			end
			else if (sec_tick_sub) begin
				r_valid_min <= 1'b1;
				o_sec <= o_sec + 1'b1;
			end
			else begin
				o_sec <= o_sec + 1'b1;
				r_valid_min <= 0;
			end
		end
		else begin
			o_sec <= o_sec;
		end
	end

	always @(posedge clk) begin
	    if(reset) begin
			// r_min_cnt 	<= 0;
			o_min		<= 0;
		end
		else if(w_one_sec_tick) begin
			if(min_tick && sec_tick) begin
				o_min <= 0;
				r_valid_hour <= 0;
			end
			else if(min_tick && sec_tick_sub) begin
				r_valid_hour <= 1'b1;
			end
			else if (r_valid_min)  begin
				o_min <= o_min + 1'b1;
				r_valid_hour <= 0;
			end
			else begin
				o_min <= o_min;
				r_valid_hour <= 0;
			end
		end
		else if(w_btn_tick) begin
			if(sub_min) begin
				if(min_tick) begin
					o_min <= 0;
				end
				else begin
					o_min <= o_min + 1'b1;
				end
			end
			else begin
				o_min <= o_min;
			end
		end
		else begin
			o_min <= o_min;
		end
	end

	always @(posedge clk) begin
	    if(reset) begin
			// r_hour_cnt 	<= 0;
			o_hour		<= 0;
		end else if(w_one_sec_tick) begin
			if(hour_tick && min_tick && sec_tick) begin
				o_hour <= 0;
				// r_valid_day <= 0;
			end
			// else if(hour_tick && min_tick && sec_tick_sub) begin
			// 	r_valid_day <= 1'b1;
			// end
			else if (r_valid_hour)  begin
				o_hour <= o_hour + 1'b1;
				// r_valid_day <= 0;
			end
			else begin
				o_hour <= o_hour;
				// r_valid_day <= 0;
			end
		end
		else if(w_btn_tick) begin
			if(sub_min && min_tick) begin
				if(hour_tick) begin
					o_hour <= 0;
				end
				else begin
					o_hour <= o_hour + 1'b1;
				end
			end
			else if(sub_hour) begin
				if(hour_tick) begin
					o_hour <= 0;
				end
				else begin
					o_hour <= o_hour + 1'b1;
				end
			end
			else begin
				o_hour <= o_hour;
			end
		end
		else begin
			o_hour <= o_hour;
		end
	end

	always @(posedge clk) begin
		if(btn[0] | btn[1]) begin
			if(btn[0]) begin
				sub_min <= 1'b1;
			end
			else if(btn[1]) begin
				sub_hour <= 1'b1;
			end
			else begin
				sub_min <= 0;
				sub_hour <= 0;
			end
		end
		else begin
			sub_min <= 0;
			sub_hour <= 0;
		end
	end

endmodule
