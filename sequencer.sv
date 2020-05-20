

////////////////////////////////////////////////////////////////////////////////
//
// File name    : serial_data_converter_data_in_sequence_item.sv
// Project name : Serial Data Converter
//
////////////////////////////////////////////////////////////////////////////////
//
// Description: sequence for the project serial_data_converter.
//
////////////////////////////////////////////////////////////////////////////////
//
// Comments: 
//
////////////////////////////////////////////////////////////////////////////////

`ifndef __SERIAL_DATA_CONVERTER_DATA_IN_SEQ
`define __SERIAL_DATA_CONVERTER_DATA_IN_SEQ

class serial_data_converter_data_in_sequence extends uvm_sequence #(dvr_sequence_item #(serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS));
    /*-------------------------------------------------------------------------------
    -- UVM Macros - Factory register.
    -------------------------------------------------------------------------------*/
    // Provides implementations of virtual methods such as get_name and create.
    `uvm_object_utils(serial_data_converter_data_in_sequence)
    `uvm_declare_p_sequencer(dvr_sequencer #(serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS))

    /*------------------------------------------------------------------------------
    -- Parameters.
    ------------------------------------------------------------------------------*/
    serial_data_converter_generation_parameters parameters = null;

    /*------------------------------------------------------------------------------
    -- Sizes Constraints.
    ------------------------------------------------------------------------------*/

    /*-------------------------------------------------------------------------------
    -- Tasks & Functions.
    -------------------------------------------------------------------------------*/
    /*-------------------------------------------------------------------------------
    -- Constructor.
    -------------------------------------------------------------------------------*/
    function new (string name = "serial_data_converter_data_in_sequence");
        super.new(name);

    endfunction

    /*-------------------------------------------------------------------------------
    -- Pre Start.
    -------------------------------------------------------------------------------*/
    virtual task pre_start ();
        if ((get_parent_sequence() == null) && (starting_phase != null)) begin
            starting_phase.raise_objection(this);
        end
    endtask

    /*-------------------------------------------------------------------------------
    -- Body.
    -------------------------------------------------------------------------------*/

    virtual task body ();
        bit [serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS - 1 : 0 ] data_in_bytes[$] = {};
        int picker;
        int size = $urandom_range(6,30);
        bit [serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS - 1 : 0 ] random_byte;
        int margin;
        for (int i = 0; i < size; i++) begin
	        std::randomize(picker) with {picker dist{4:=80, [0:3]:=5};};
        	$display("picked:", picker);
          if (picker == 0) begin
		        data_in_bytes.push_back(8'h52);
		    	data_in_bytes.push_back(8'hf3);
		    	data_in_bytes.push_back(8'h75);
		    	data_in_bytes.push_back(8'h20);
	        end        
	        else if (picker == 1) begin
		        data_in_bytes.push_back(8'hde);
		    	data_in_bytes.push_back(8'had);
		    	data_in_bytes.push_back(8'h0d);
		    	data_in_bytes.push_back(8'hea);
		    	data_in_bytes.push_back(8'hf0);
		    	data_in_bytes.push_back(8'hbe);
		    	data_in_bytes.push_back(8'hef);
	        end        
	        else if (picker == 2) begin
		        data_in_bytes.push_back(8'h29);
		    	data_in_bytes.push_back(8'h91);
		    	data_in_bytes.push_back(8'h23);
	        end        
	        else if (picker == 3) begin
		        data_in_bytes.push_back(8'h7b);
		    	data_in_bytes.push_back(8'h47);
		    	data_in_bytes.push_back(8'h53);
		    	data_in_bytes.push_back(8'hff);
		    	data_in_bytes.push_back(8'h0f);
		    	data_in_bytes.push_back(8'h00);
	        end
	        else if (picker == 4) begin
	        	margin = $urandom_range(1,10);
              for (int i = 0; i < margin; i++) begin
	        		random_byte = $urandom;
	        		data_in_bytes.push_back(random_byte);
	        	end
	        end
        end    
        $display(data_in_bytes);
        send_msg(data_in_bytes);
    endtask

    /*------------------------------------------------------------------------------
    -- Pre randomize.
    ------------------------------------------------------------------------------*/
    function void pre_randomize();
        // Get the parameters from the test.
        if(!uvm_config_db #(serial_data_converter_generation_parameters)::get(null, this.get_full_name(), "parameters", this.parameters)) begin
            `uvm_fatal(this.get_name().toupper(), "Couldn't find the generation parameters")
        end

    endfunction

    /*-------------------------------------------------------------------------------
    -- Post Start.
    -------------------------------------------------------------------------------*/
    virtual task post_start ();
        if ((get_parent_sequence() == null) && (starting_phase != null)) begin
            starting_phase.drop_objection(this);
        end
    endtask

    /*-------------------------------------------------------------------------------
    -- Send message.
    -------------------------------------------------------------------------------*/
    task send_msg(bit [serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS - 1 : 0 ] data_in_bytes[$]);
        foreach (data_in_bytes[i]) begin
            `uvm_do_on_with(req, p_sequencer, {
                data == data_in_bytes[i];
            })
        end
    endtask
endclass

`endif // __SERIAL_DATA_CONVERTER_VIRTUAL_SEQ