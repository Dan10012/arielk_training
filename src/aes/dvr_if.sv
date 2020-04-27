//////////////////////////////////////////////////////////////////
///
/// Project Name: 	aes_encrypter
///
/// File Name: 		avalon_st_if.sv
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
/// Description: 	Defines DVR interface 
///
//////////////////////////////////////////////////////////////////

import general_pack::*;

interface avalon_st_if #(parameter DATA_WIDTH_IN_BYTES = 32);
	logic 	[(DATA_WIDTH_IN_BYTES*$bits(byte)) - 1 : 0] data;
	logic 												valid;
	logic 												rdy;


	modport slave 	(input data, input valid, output rdy);

	modport master 	(output data, output valid, input rdy);

endinterface