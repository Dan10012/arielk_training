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

	function logic [7:0] mul2 (logic [7:0] in_byte);			
		logic [7:0] out_byte;
		if (in_byte[7] == 0) begin
				out_byte = in_byte<<1;
		end
		else begin 
				out_byte = in_byte<<1;
				out_byte = out_byte XOR 8'h1b;
		end
		return out_byte;
	endfunction :

	function logic [7:0] mul3 (logic [7:0] in_byte);			
		logic [7:0] byte_mul2;
		logic [7:0] out_byte;
		byte_mul2 = mul2(in_byte);
		out_byte = byte_mul2 XOR in_byte;

	endfunction :

	function void ();
		
	endfunction : 

endpackage
