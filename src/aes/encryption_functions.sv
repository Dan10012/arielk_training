//////////////////////////////////////////////////////////////////
///
/// Project Name: 	aes_encrypter
///
/// File Name: 		encryption_function.sv
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
/// Description:    this package has functions for encryptions
///
//////////////////////////////////////////////////////////////////

package encryption_functions;

	import aes_model_pack ::*;

	/*-- Parameters --------------------------------*/
	localparam int ROW_SIZE = 4;


	/*-- Functions ---------------------------------*/

	// this function multiplie a num in 2 inside galois field
	function logic [$bits(byte) - 1 : 0] mul2 (logic [$bits(byte) - 1 : 0] in_byte);			
		logic [$bits(byte) - 1 : 0] out_byte;
		if (in_byte[7] == 0) begin
				out_byte = in_byte<<1;
		end
		else begin 
				out_byte = in_byte<<1;
				out_byte = out_byte ^ 8'h1b;
		end
		return out_byte;
	endfunction 

	// this function multiplie a num in 3 inside galois field
	function logic [$bits(byte) - 1 : 0] mul3 (logic [$bits(byte) - 1 : 0] in_byte);			
		logic [$bits(byte) - 1 : 0] byte_mul2;
		logic [$bits(byte) - 1 : 0] out_byte;
		byte_mul2 = mul2(in_byte);
		out_byte = byte_mul2 ^ in_byte;
		return out_byte;
	endfunction 

	// this function dot prudoct coulomn with the right matrix and the xor dor products
	function logic [ROW_SIZE-1:0] [$bits(byte) - 1 : 0] mixcoulomns (logic [ROW_SIZE-1] [$bits(byte) - 1 : 0] in_row);	
		logic [$bits(byte) - 1 : 0] byte1_mul2 = mul2(in_row[0]);
		logic [$bits(byte) - 1 : 0] byte1_mul3 = mul3(in_row[0]);
		logic [$bits(byte) - 1 : 0] byte2_mul2 = mul2(in_row[1]);
		logic [$bits(byte) - 1 : 0] byte2_mul3 = mul3(in_row[1]);
		logic [$bits(byte) - 1 : 0] byte3_mul2 = mul2(in_row[2]);
		logic [$bits(byte) - 1 : 0] byte3_mul3 = mul3(in_row[2]);
		logic [$bits(byte) - 1 : 0] byte4_mul2 = mul2(in_row[3]);
		logic [$bits(byte) - 1 : 0] byte4_mul3 = mul3(in_row[3]);
		logic [3:0][$bits(byte) - 1 : 0] out_row;
		out_row[0] = byte1_mul2 ^ byte2_mul3 ^ in_row[2] ^ in_row[3];		
		out_row[1] = byte2_mul2 ^ byte3_mul3 ^ in_row[3] ^ in_row[0];		
		out_row[2] = byte3_mul2 ^ byte4_mul3 ^ in_row[0] ^ in_row[1];		
		out_row[3] = byte4_mul2 ^ byte1_mul3 ^ in_row[1] ^ in_row[2];		
		return out_row;
	endfunction 

	// this func moves row and sub bytes acording to lut
	function  logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] sub_and_shift (logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] input_block);
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] current;
		logic [2*$bits(byte) - 1 : 0] [$bits(byte) - 1 : 0] out_block;
		for (int i = 0; i < (2*$bits(byte)); i++) begin
					current[i] = SUB_BYTES_TABLE[input_block[i]];
		end	
		out_block[0] = current[0];
		out_block[1] = current[5];
		out_block[2] = current[10];
		out_block[3] = current[15];
		out_block[4] = current[4];
		out_block[5] = current[9];
		out_block[6] = current[14];
		out_block[7] = current[3];
		out_block[8] = current[8];
		out_block[9] = current[13];
		out_block[10] = current[2];
		out_block[11] = current[7];
		out_block[12] = current[12];
		out_block[13] = current[1];
		out_block[14] = current[6];
		out_block[15] = current[11];
		return out_block;
	endfunction  

	// this is the order of one main cycle
	function  logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] main_cycle (logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] input_block, logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] round_key);
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] shifted_block;
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] mixed_block;
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] after_round;
		shifted_block = sub_and_shift(input_block);
		mixed_block[3:0] = mixcoulomns(shifted_block[3:0]);
		mixed_block[7:4] = mixcoulomns(shifted_block[7:4]);
		mixed_block[11:8] = mixcoulomns(shifted_block[11:8]);
		mixed_block[15:12] = mixcoulomns(shifted_block[15:12]);
		after_round = round_key ^ mixed_block;
		return after_round;
	endfunction  

	// this is the order of the last cycle
	function  logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] last_cycle (logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] input_block, logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] round_key);
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] shifted_block;
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] after_round;
		shifted_block = sub_and_shift(input_block);
		after_round = round_key ^ shifted_block;
		return after_round;
	endfunction  

	// this generate next key in order acording to round and last key
	function  logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] key_generator (logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] key_in, int round);
		logic [ROW_SIZE-1:0] [$bits(byte) - 1 : 0] sub_row;
		logic [ROW_SIZE-1:0] [$bits(byte) - 1 : 0] rot_byte;
		logic [ROW_SIZE-1:0] [$bits(byte) - 1 : 0] rcon_word;
		logic [(2*$bits(byte)) - 1 : 0] [$bits(byte) - 1 : 0] key_out;
		for (int i = 0; i < ROW_SIZE; i++) begin
			sub_row[i] = SUB_BYTES_TABLE[key_in[i]];
		end
		rot_byte[2:0] = sub_row [3:1];
		rot_byte[3] = sub_row[0]; 
		rcon_word = rot_byte ^ RCON_TABLE[round];
		key_out[3:0] = rcon_word ^ key_in[3:0];
		key_out[7:4] = key_out[3:0] ^ key_in[7:4];
		key_out[11:8] = key_out[7:4] ^ key_in[11:8];
		key_out[15:11] = key_out[11:8] ^ key_in[15:11];
		return key_out;
	endfunction 





endpackage
