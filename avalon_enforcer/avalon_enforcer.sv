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
/// Description:    the model will handle avalon stream message 
///                 and  will enforce them so the output will be 
///                 a valid avalon stream message.
///
//////////////////////////////////////////////////////////////////


module avalon_enforcer
#(
	parameter int DATA_WIDTH_IN_BYTES = 16
)
(
	input logic             clk,
	input logic             rst,

	avalon_st_if.slave      untrusted_msg,
	avalon_st_if.master     enforced_msg,

	output logic            missing_sop,
	output logic            unexpected_sop

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

//responsible to identify if the message is suposed to be transferred
logic                                          should_transfer;
// looks which byte of data should pass to enforced according to empty  
logic        [DATA_WIDTH_IN_BYTES - 1 : 0]     byte_checker;
// the after it passed should_transfer but before byte_checker
logic        [(DATA_WIDTH_IN_BYTES*8) - 1 : 0] vld_data;
msg_sm_t                                       state;

//////////////////////////////////////////
//// Logic ///////////////////////////////
//////////////////////////////////////////

// this part handles state machine
always_ff @(posedge clk or negedge rst) begin: state_machine
	if(~rst) begin

		//when rst = 0 all outputs are set to 0
		state <= BETWEEN_MSG;
		missing_sop          = 0;
		unexpected_sop       = 0;
		enforced_msg.sop     = 0;
		enforced_msg.valid   = 0;
		should_transfer      = 0;
	end else begin
		//state machine cases are unique
		unique case (state)
			//the module is currently between messages and wait for a valid sop
			//when there is a valid sop it moves to IN_MSG
			BETWEEN_MSG: begin
				missing_sop          = (untrusted_msg.valid & !untrusted_msg.sop);
				unexpected_sop       = 0;
				enforced_msg.sop     = (untrusted_msg.valid & untrusted_msg.sop);
				enforced_msg.valid   = (untrusted_msg.valid & untrusted_msg.sop);
				should_transfer      = (untrusted_msg.valid & untrusted_msg.sop);
				if (untrusted_msg.sop == 1 && untrusted_msg.valid == 1 && untrusted_msg.rdy == 1 && untrusted_msg.eop == 0) begin
					state <= IN_MSG;
				end
			end
			// the module is currently reading a message and doesn't expect an sop
			// when there is a valid eop it moves to BETWEEN_MSG
			IN_MSG: begin
				missing_sop          = 0;
				unexpected_sop       = (untrusted_msg.valid & untrusted_msg.sop);
				enforced_msg.sop     = 0;
				enforced_msg.valid   = untrusted_msg.valid;
				should_transfer      = untrusted_msg.valid;
				if (untrusted_msg.valid == 1 && untrusted_msg.eop == 1 && untrusted_msg.rdy == 1 ) begin
					state <= BETWEEN_MSG;
				end
			end	
		endcase
	end
end: state_machine

// this handles rdy
assign untrusted_msg.rdy  = enforced_msg.rdy;

// this process checks if the sm decided to transfer 
// the message and if so sets the correct values
always_comb begin: transfer_msg

	
	if (should_transfer == 1) begin
		enforced_msg.eop   = untrusted_msg.eop;
		enforced_msg.empty = untrusted_msg.eop ? untrusted_msg.empty : 1'b0;
		vld_data           = untrusted_msg.data;
	end else begin 
		enforced_msg.eop   = 0;
		enforced_msg.empty = 0;
		vld_data           = 0;
	end

end: transfer_msg


// this process looks which bytes of data should be 0 according to empty
always_comb begin : data_handler
	for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
		// each bit in byte_checker represent a byte in data.
		// number of 0's in byte_checker is according to empty
		if ( enforced_msg.empty > i ) begin
			byte_checker[i] = 0;
		end else begin 
			// looks which byte of data should be 
			byte_checker[i] = 1;
		end
	end 
	// this parts sets the final data according to byte_checker
	for (int i = 0; i < DATA_WIDTH_IN_BYTES; i++) begin
		for (int j = i*$bits(byte); j < (i*$bits(byte))+$bits(byte); j++) begin
			if ( byte_checker[i] == 0) begin
			//if bit in byte_checker is 0 the according byte in data is zero
				enforced_msg.data[j] = 0;
			end else begin 
			//else it is the same as vld_data	
				enforced_msg.data[j] = vld_data[j];
			end
		end
	end
end: data_handler

endmodule