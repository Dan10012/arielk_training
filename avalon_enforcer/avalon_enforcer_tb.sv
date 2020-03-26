//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforcer
///
/// File Name: 		avalon_enforcer_tb.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Ariel Kalish
///
/// Date Created: 	25.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	?????
///
//////////////////////////////////////////////////////////////////

module avalon_enforcer_tb();

	localparam int DATA_WIDTH_IN_BYTES = 16;

	logic clk;
	logic rst;

	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) untrusted_msg();
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) enforced_msg();


	logic 			missing_sop_indi;
	logic 			unexpected_sop_indi;


	avalon_enforcer #(
		.DATA_WIDTH_IN_BYTES(16)
	)
		avalon_enforcer_inst
	(
		.clk(clk),
		.rst(rst),
		.untrusted_msg(untrusted_msg.slave),
		.enforced_msg(enforced_msg.master),
		.missing_sop_indi(missing_sop_indi),
		.unexpected_sop_indi(unexpected_sop_indi)
	);

	always #5ns clk = ~clk;

	initial begin 
		clk 				= 1'b0;
		rst 				= 1'b0;
		untrusted_msg.data 	= 0;
		untrusted_msg.valid 	= 1'b0;
		untrusted_msg.sop 	= 1'b0;
		untrusted_msg.eop 	= 1'b0;
		untrusted_msg.empty 	= 0;


		// clear untrusted_msg
		enforced_msg.rdy 	= 1'b1;

		rst 				= 1'b1;
		#50ns;
		rst 				= 1'b0;

		@(posedge clk);
		untrusted_msg.valid 		= 1'b1;
		untrusted_msg.data 		= {DATA_WIDTH_IN_BYTES{8'hff}};
		untrusted_msg.sop 		= 1'b0;
		@(posedge clk);
		@(posedge clk);
		untrusted_msg.valid 		= 1'b1;
		untrusted_msg.data 		= {DATA_WIDTH_IN_BYTES{8'hff}};
		untrusted_msg.sop 		= 1'b1;
		@(posedge clk);
		untrusted_msg.sop 		= 1'b0;
		@(posedge clk);
		untrusted_msg.sop 		= 1'b1;
		@(posedge clk);
		@(posedge clk);
		untrusted_msg.sop 		= 1'b0;
		@(posedge clk);
		untrusted_msg.valid 		= 1'b0;
		untrusted_msg.sop 		= 1'b1;
		untrusted_msg.eop 		= 1'b1;
		@(posedge clk);
		untrusted_msg.valid 		= 1'b1;
		untrusted_msg.sop 		= 1'b0;
		untrusted_msg.eop 		= 1'b0;
		untrusted_msg.empty 		= 4'b1111;		
		@(posedge clk);
		untrusted_msg.valid 		= 1'b1;
		untrusted_msg.sop 		= 1'b1;
		untrusted_msg.eop 		= 1'b1;
		untrusted_msg.data 		= {DATA_WIDTH_IN_BYTES{8'hf0}};
		@(posedge clk);
		untrusted_msg.valid 		= 1'b0;
		untrusted_msg.sop 		= 1'b0;
		untrusted_msg.eop 		= 1'b0;
		untrusted_msg.data       = 0;
		#15ns;


	end

endmodule