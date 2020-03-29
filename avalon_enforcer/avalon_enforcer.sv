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
/// Description: 	the model will handle avalon st message and will enforce them so the output will be a valid avalon st message
///
//////////////////////////////////////////////////////////////////


module avalon_enforcer
#(
	parameter int DATA_WIDTH_IN_BYTES = 16
)
(
	input logic 			clk,
	input logic 			rst,

	avalon_st_if.slave      untrusted_msg,
	avalon_st_if.master     enforced_msg,

	output logic 			missing_sop,
	output logic 			unexpected_sop

);

//////////////////////////////////////////
//// Imports /////////////////////////////
//////////////////////////////////////////

import general_pack::*;

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum logic {
		IN_MSG,
		BETWEEN_MSG
	} msg_sm_t;

//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

logic                                               enb;
logic 	[DATA_WIDTH_IN_BYTES - 1 : 0] 	            cleaner;
logic 	[(DATA_WIDTH_IN_BYTES*8) - 1 : 0] 	        data_mid;
msg_sm_t 		                                    state;

//////////////////////////////////////////
//// Logic ///////////////////////////////
//////////////////////////////////////////

// this part handles state machine
always_ff @(posedge clk or posedge rst) begin

	if(~rst) begin
		state <= BETWEEN_MSG;
		missing_sop          = 0;
		unexpected_sop       = 0;
		enforced_msg.sop     = 0;
		enforced_msg.valid   = 0;
		enb                  = 0;

	end else begin
		unique case (state)
			BETWEEN_MSG: begin
				missing_sop          = (untrusted_msg.valid & !untrusted_msg.sop);
				unexpected_sop       = 0;
				enforced_msg.sop     = (untrusted_msg.valid & untrusted_msg.sop);
				enforced_msg.valid   = (untrusted_msg.valid & untrusted_msg.sop);
				enb                  = (untrusted_msg.valid & untrusted_msg.sop);
				if (untrusted_msg.sop == 1 && untrusted_msg.valid == 1 && untrusted_msg.rdy == 1 && untrusted_msg.eop == 0) begin
					state <= IN_MSG;
				end
			end
			IN_MSG: begin
				missing_sop          = 0;
				unexpected_sop       = (untrusted_msg.valid & untrusted_msg.sop);
				enforced_msg.sop     = 0;
				enforced_msg.valid   = untrusted_msg.valid;
				enb                  = untrusted_msg.valid;
				if (untrusted_msg.valid == 1 && untrusted_msg.eop == 1 && untrusted_msg.rdy == 1 ) begin
					state <= BETWEEN_MSG;
				end
			end	
		endcase
	end
end


// this handles rdy
assign untrusted_msg.rdy  = enforced_msg.rdy;

always_comb begin

		// this take care of enb dependant values
		if (enb == 1) begin
			enforced_msg.eop   = untrusted_msg.eop;
			enforced_msg.empty = untrusted_msg.eop ? 0 : untrusted_msg.eop;
			data_mid           = untrusted_msg.data;
		end else begin 
			enforced_msg.eop   = 0;
			enforced_msg.empty = 0;
			data_mid           = 0;
		end


		// this takes care of the cleaner
		for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
			if ( enforced_msg.empty > i) begin
				cleaner[i] = 0;
			end else begin 
				cleaner[i] = 1;
			end
		end

		// this parts sets the empty according to cleaner
		for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
			for (int j = i*$bits(byte) ; j < (i*8)+8; j++) begin
				if ( cleaner[i] == 0) begin
					enforced_msg.data[j] = 0;
				end else begin 
					enforced_msg.data[j] = data_mid[j];
				end
			end
		end
end





endmodule