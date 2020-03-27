//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforcer
///
/// File Name: 		avalon_enforcer.sv
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


module avalon_enforcer
#(
	parameter int DATA_WIDTH_IN_BYTES = 16
)
(
	input logic 			clk,
	input logic 			rst,

	avalon_st_if.slave 		untrusted_msg,
	avalon_st_if.master 	enforced_msg,

	output logic 			missing_sop_indi,
	output logic 			unexpected_sop_indi

);


//////////////////////////////////////////
//// Imports /////////////////////////////
//////////////////////////////////////////


import general_pack::*;

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum {
		IN_MSG,
		BETWEEN_MSG
	} msg_sm_t;

//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

logic 						enb;
logic 	[DATA_WIDTH_IN_BYTES - 1 : 0] 	cleaner;
logic 	[(DATA_WIDTH_IN_BYTES*8) - 1 : 0] 	data_mid;
logic 	[log2up_func(DATA_WIDTH_IN_BYTES) - 1 : 0] 	empty_mid;
msg_sm_t 		state = BETWEEN_MSG;

//////////////////////////////////////////
//// Logic ///////////////////////////////
//////////////////////////////////////////

// this part hadles the state machine
always_ff @(posedge clk or negedge rst) begin
		case (state)
			BETWEEN_MSG: begin
				if (untrusted_msg.sop == 1 && untrusted_msg.valid == 1 && untrusted_msg.rdy == 1 && untrusted_msg.eop == 0) begin
					state <= IN_MSG;
				end
			end
			IN_MSG: begin
				if (untrusted_msg.valid == 1 && untrusted_msg.eop == 1 && untrusted_msg.rdy == 1 ) begin
					state <= BETWEEN_MSG;
				end
			end	
		endcase
end



assign untrusted_msg.rdy  = enforced_msg.rdy;

always_comb begin

	if (rst == 1) begin 
		enforced_msg.valid = 0;
		enforced_msg.sop = 0;
		enforced_msg.data = 0;
		enforced_msg.empty = 0;
		enforced_msg.eop = 0;
	end


	else begin
		if (state == BETWEEN_MSG) begin
			missing_sop_indi     = (untrusted_msg.valid & !untrusted_msg.sop);
			unexpected_sop_indi  = 0;
		    enforced_msg.sop     = (untrusted_msg.valid & untrusted_msg.sop);
		    enforced_msg.valid   = (untrusted_msg.valid & untrusted_msg.sop);
		    enb                  = (untrusted_msg.valid & untrusted_msg.sop);
		end else begin
			missing_sop_indi     = 0;
			unexpected_sop_indi  = (untrusted_msg.valid & untrusted_msg.sop);
		    enforced_msg.sop     = 0;
		    enforced_msg.valid   = untrusted_msg.valid;
		    enb                  = untrusted_msg.valid;
		end



		if (untrusted_msg.eop == 1) begin
			empty_mid = untrusted_msg.empty;
		end else begin
			empty_mid = 0;
		end



		if (enb == 1) begin
			enforced_msg.eop = untrusted_msg.eop;
			enforced_msg.empty = empty_mid;
			data_mid = untrusted_msg.data;
		end else begin 
			enforced_msg.eop = 0;
			enforced_msg.empty = 0;
			data_mid = 0;
		end


		
		for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
			if ( untrusted_msg.empty > i) begin
				cleaner[i] = 0;
			end else begin 
				cleaner[i] = 1;
			end
		end

		for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
			for (int j = i; j < i+8; j++) begin
				if ( cleaner[i] == 0) begin
					enforced_msg.data[j] = 0;
				end else begin 
					enforced_msg.data[j] = data_mid[j];
				end
			end
		end
	end
end





endmodule