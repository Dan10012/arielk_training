//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforcer
///
/// File Name: 		avalon_st_if.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Ariel Kalish
///
/// Date Created: 	19.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	Defines Avalon Stream interface 
///
//////////////////////////////////////////////////////////////////

import general_pack::*;

interface avalon_st_if #(parameter DATA_WIDTH_IN_BYTES = 16);
	logic 	[(DATA_WIDTH_IN_BYTES*$bits(byte)) - 1 : 0] data;
	logic 												valid;
	logic 												rdy;
	logic 												sop;
	logic 												eop;
	logic 	[log2up_func(DATA_WIDTH_IN_BYTES) - 1 : 0] 	empty;

	modport slave 	(input data, input valid, output rdy, input sop, input eop, input empty);

	modport master 	(output data, output valid, input rdy, output sop, output eop, output empty);

endinterface