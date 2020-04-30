//////////////////////////////////////////////////////////////////
///
/// Project Name: 	aes_encrypter
///
/// File Name: 		aes_encrypter.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Ariel Kalish
///
/// Date Created: 	26.4.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description:    the model will encrypt message using AES128
///
//////////////////////////////////////////////////////////////////
module avalon_enforcer
#(
	parameter int      DATA_WIDTH_IN_BYTES = 16,
	parameter int      BLOCK_SIZE = 128,
	parameter logic    G_RST_POLARITY = 1

)
(
	input logic             clk,
	input logic             rst,

	avalon_st_if.slave      avalon_st_in,
	avalon_st_if.master     avalon_st_out,

	dvr_if.slave            key_and_sync_in,

	output logic            sync_error

);
//////////////////////////////////////////
//// Imports /////////////////////////////
//////////////////////////////////////////

import encryption_functions::*;

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum logic [1:0] {
		WAITING_FOR_KEY,
		GENERATE_SYNC,
		ENCRYPT_MSG
	} manage_sm_t;


//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

// responsible to keep the current sync
logic   [DATA_WIDTH_IN_BYTES-1:0] [$bits(byte)-1 : 0] sync;
// responsible to keep the first_key (from the expanded key is made)
logic   [DATA_WIDTH_IN_BYTES-1:0] [$bits(byte)-1 : 0] first_key;
// responsible to keep the current round key
logic   [DATA_WIDTH_IN_BYTES-1:0] [$bits(byte)-1 : 0] round_key;
// responsible to keep the current encrypted_sync
logic   [DATA_WIDTH_IN_BYTES-1:0] [$bits(byte)-1 : 0] current_encrypt;
// responsible to keep the final encrypted_sync
logic   [DATA_WIDTH_IN_BYTES-1:0] [$bits(byte)-1 : 0] final_encrypt;
// responsible to keep the current encryption round  
int                                                   round;
// the after it passed should_transfer but before byte_checker
logic                                                 sync_error;
// current state
msg_sm_t                                              state;


//////////////////////////////////////////
//// Logic ///////////////////////////////
//////////////////////////////////////////

// this part is responsible on sm movements
always_ff @(posedge clk or negedge rst) begin: state_machine
	if(rst == G_RST_POLARITY) begin
		state <= WAITING_FOR_KEY;
	end else begin
		// state machine cases are unique
		unique case (state)
			// the module is currently waiting for a key
			// when there is a valid key_and_sync it moves to GENERATE_SYNC
			WAITING_FOR_KEY: begin

				if (key_and_sync_in.valid == 1) begin
					state <= GENERATE_SYNC;
				end
			end
			// the module currently AES encrypt the sync
			// when it is done it will move to ENCRYPT_MSG
			GENERATE_SYNC: begin
				if (round == 10) begin
					state <= ENCRYPT_MSG;
				end
			end	
			// the module currently waits for an avalon msg to come, when it comes it encrypts it.
			ENCRYPT_MSG: begin
				if (avalon_st_in.valid == 1 && avalon_st_in.eop == 1 && avalon_st_out.rdy ==1) begin
					state <= WAITING_FOR_KEY;
				end
				else if (avalon_st_in.valid == 1 && avalon_st_in.eop == 0 && avalon_st_out.rdy ==1) begin
					state <= GENERATE_SYNC;
				end
			end	
		endcase
	end
end: state_machine

always_ff @(posedge clk or negedge rst) begin: sequential_logic
			unique case (state)
			// the sequental logic for each case
			WAITING_FOR_KEY: begin
				sync = key_and_sync_in.data[255:128];
				round = 1;
				first_key = key_and_sync_in.data[127:0];
				round_key = key_generator(first_key,round);
				current_encrypt = sync ^ key_and_sync_in.data[127:0];
				final_encrypt = 0;
				sync_error = 0;
				
			end
			GENERATE_SYNC: begin
				sync = (round==10)?sync:sync+1;
				round = round+1;
				round_key = key_generator(round_key,round);
				current_encrypt = main_cycle(current_encrypt,round_key);
				final_encrypt = main_cycle(current_encrypt,round_key);;
				sync_error = (sync == 2**128 - 1);
			end	
			// the module currently waits for an avalon msg to come, when it comes it encrypts it.
			ENCRYPT_MSG: begin
				round = 1;
				round_key = key_generator(first_key,round);
				current_encrypt = first_key ^ sync;
				sync_error = (sync == 2**128 - 1);
			end	
		endcase

end: sequential_logic

always_comb begin: comb_logic
			avalon_st_out.empty = avalon_st_in.empty ;
			avalon_st_out.eop = avalon_st_in.eop ;
			avalon_st_out.sop = avalon_st_in.sop ;
			unique case (state)
			// the comb logic for each case
			WAITING_FOR_KEY: begin
				avalon_st_out.data = 0;
				key_and_sync_in.rdy = 1;
				avalon_st_in.rdy = 0;
				avalon_st_out.valid = 0;
				
			end
			GENERATE_SYNC: begin
				avalon_st_out.data = 0;
				key_and_sync_in.rdy = 0;
				avalon_st_in.rdy = 0;
				avalon_st_out.valid = 0;
			end	
			// the module currently waits for an avalon msg to come, when it comes it encrypts it.
			ENCRYPT_MSG: begin
				avalon_st_out.data = avalon_st_in.valid ? avalon_st_in.data ^ final_encrypt : 0;
				key_and_sync_in.rdy = 0;
				avalon_st_in.rdy = avalon_st_out.rdy;
				avalon_st_out.valid = avalon_st_in.valid ;
			end	
		endcase
end: comb_logic