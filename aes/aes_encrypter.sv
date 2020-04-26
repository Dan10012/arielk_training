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
/// Date Created: 	25.3.2020
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
	parameter int DATA_WIDTH_IN_BYTES = 16,
	parameter int BLOCK_SIZE = 128,

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
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum logic {
		WAITING_FOR_KEY,
		GENERATE_SYNC,
		ENCRYPT_MSG
	} manage_sm_t;