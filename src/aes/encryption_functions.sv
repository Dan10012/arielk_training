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
/// Description:    the model will encrypt message using AES128
///
//////////////////////////////////////////////////////////////////

package encryption_functions;

	import aes_model_pack ::*;

	function logic [$bits(byte) - 1 : 0] mul2 (logic [$bits(byte) - 1 : 0] in_byte);			
		logic [$bits(byte) - 1 : 0] out_byte;
		if (in_byte[7] == 0) begin
				out_byte = in_byte<<1;
		end
		else begin 
				out_byte = in_byte<<1;
				out_byte = out_byte XOR 8'h1b;
		end
		return out_byte;
	endfunction :

	function logic [$bits(byte) - 1 : 0] mul3 (logic [$bits(byte) - 1 : 0] in_byte);			
		logic [$bits(byte) - 1 : 0] byte_mul2;
		logic [$bits(byte) - 1 : 0] out_byte;
		byte_mul2 = mul2(in_byte);
		out_byte = byte_mul2 XOR in_byte;
		return out_byte;
	endfunction :


	function logic [3:0][$bits(byte) - 1 : 0] mixcoulomns (logic [$bits(byte) - 1 : 0] in_row);	
		logic [$bits(byte) - 1 : 0] byte1_mul2 = mul2(in_row[0]);
		logic [$bits(byte) - 1 : 0] byte1_mul3 = mul3(in_row[0]);
		logic [$bits(byte) - 1 : 0] byte2_mul2 = mul2(in_row[1]);
		logic [$bits(byte) - 1 : 0] byte2_mul3 = mul3(in_row[1]);
		logic [$bits(byte) - 1 : 0] byte3_mul2 = mul2(in_row[2]);
		logic [$bits(byte) - 1 : 0] byte3_mul3 = mul3(in_row[2]);
		logic [$bits(byte) - 1 : 0] byte4_mul2 = mul2(in_row[3]);
		logic [$bits(byte) - 1 : 0] byte4_mul3 = mul3(in_row[3]);
		logic [3:0][$bits(byte) - 1 : 0] out_row;
		out_row[0] = byte1_mul2 XOR byte2_mul3 XOR in_row[2] XOR in_row[3];		
		out_row[1] = byte2_mul2 XOR byte3_mul3 XOR in_row[3] XOR in_row[0];		
		out_row[2] = byte3_mul2 XOR byte4_mul3 XOR in_row[0] XOR in_row[1];		
		out_row[3] = byte4_mul2 XOR byte1_mul3 XOR in_row[1] XOR in_row[2];		
		return out_row;
	endfunction :

	function  logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] sub_and_shift (logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] input_block);
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] current;
		for (int i = 0; i < (2*$bits(byte)); i++) begin
					current[i] = SUB_BYTES_TABLE[input_block[i]];
		end	
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] out_block;
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
	endfunction : 

	function  logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] main_cycle (logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] input_block, logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] round_key);
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] shifted_block;
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] mixed_block;
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] after_round;
		shifted_block = sub_and_shift(input_block);
		mixed_block[3:0] = mixcoulomns(shifted_block[3:0]);
		mixed_block[7:4] = mixcoulomns(shifted_block[7:4]);
		mixed_block[11:8] = mixcoulomns(shifted_block[11:8]);
		mixed_block[15:12] = mixcoulomns(shifted_block[15:12]);
		after_round = round_key XOR mixed_block;
		return after_round;
	endfunction : 

	function  logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] last_cycle (logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] input_block, logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] round_key);
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] shifted_block;
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] after_round;
		shifted_block = sub_and_shift(input_block);
		after_round = round_key XOR shifted_block;
		return after_round;
	endfunction : 

	function  logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] key_generator (logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] key_in, int round);
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] shifted_block;
		logic [(2*$bits(byte)) - 1 : 0][$bits(byte) - 1 : 0] after_round;
		shifted_block = sub_and_shift(input_block);
		after_round = round_key XOR shifted_block;
		return after_round;
	endfunction : 





endpackage
