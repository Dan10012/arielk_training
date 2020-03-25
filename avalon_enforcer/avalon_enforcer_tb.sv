//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforcer
///
/// File Name: 		avalon_enforcer_tb.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Yael Karisi
///
/// Date Created: 	19.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	?????
///
//////////////////////////////////////////////////////////////////

module unknown_module_tb();

	localparam int DATA_WIDTH_IN_BYTES = 16;

	logic clk;
	logic rst;

	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES));
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES));

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
		.missing_sop_indi(missing_sop_indi),
	);

	always #5 clk = ~clk;

	initial begin 
		clk 				= 1'b0;
		rst 				= 1'b0;
		start 				= 1'b0;

		lane_in.CLEAR_MASTER();
		first_lane_out.CLEAR_SLAVE();
		second_lane_out.CLEAR_SLAVE();

		#50;
		rst 				= 1'b1;

		@(posedge clk);
		lane_in.valid 		= 1'b1;
		lane_in.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		lane_in.sop 		= 1'b1;
		@(posedge clk);
		select 				= 1'b1;
		@(posedge clk);
		start 				= 1'b1;
		@(posedge clk);
		@(posedge clk);
		lane_in.sop = 1'b0;
		@(posedge clk);
		@(posedge clk);
		lane_in.eop = '1;
		@(posedge clk);
		lane_in.CLEAR_MASTER();

		#15;

		$finish();

	end

endmodule