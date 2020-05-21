////////////////////////////////////////////////////////////////////////////////
//
// File name    : serial_data_converter_reference_model.sv
// Project name : Serial Data Converter
//
////////////////////////////////////////////////////////////////////////////////
//
// Description: reference_model for the project serial_data_converter.
//
////////////////////////////////////////////////////////////////////////////////
//
// Comments: 
//
////////////////////////////////////////////////////////////////////////////////

`ifndef __SERIAL_DATA_CONVERTER_REFERENCE_MODEL
`define __SERIAL_DATA_CONVERTER_REFERENCE_MODEL

class serial_data_converter_reference_model extends uvm_component;
    /*-------------------------------------------------------------------------------
    -- UVM Macros - Factory register.
    -------------------------------------------------------------------------------*/
    // Provides implementations of virtual methods such as get_name and create.
    `uvm_component_utils(serial_data_converter_reference_model)

    /*-------------------------------------------------------------------------------
    -- Ports Declartions.
    -------------------------------------------------------------------------------*/
    `uvm_analysis_imp_decl(_in_stream_port)

    /*-- Ports --------------------------------------------------------------------*/
    uvm_analysis_imp_in_stream_port #(serial_data_converter_in_stream_item_type, serial_data_converter_reference_model) in_stream_port = null;
    /*-- Exports ------------------------------------------------------------------*/
    uvm_analysis_port #(serial_data_converter_out_stream_item_type) out_stream_export = null;


    /*-------------------------------------------------------------------------------
    -- Tasks & Functions.
    -------------------------------------------------------------------------------*/
    /*-------------------------------------------------------------------------------
    -- in_stream Write Function.
    -------------------------------------------------------------------------------*/
    bit [serial_data_converter_verification_pack::DATA_WIDTH_IN_IN_BITS - 1 : 0 ] inputed_data[$] = {};
    int count = 0;
    function void write_in_stream_port (serial_data_converter_in_stream_item_type item = null);
        
      inputed_data.push_back(item.data);
      $display("inputed data: ",item.data," data till now: ", inputed_data);
      count++;
    endfunction

    /*-------------------------------------------------------------------------------
    -- Constructor.
    -------------------------------------------------------------------------------*/
    function new (string name = "serial_data_converter_reference_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    /*-------------------------------------------------------------------------------
    -- Build Phase.
    -------------------------------------------------------------------------------*/
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

       /*-- Ports Initialization --------------------------------------------------*/
        this.in_stream_port    = new("in_stream_port", this);
        this.out_stream_export = new("out_stream_export", this);
    endfunction

    /*-------------------------------------------------------------------------------
    -- End of Elaboration Phase.
    -------------------------------------------------------------------------------*/
    function void end_of_elaboration_phase (uvm_phase phase);
        super.end_of_elaboration_phase(phase);


    endfunction

endclass

`endif // __SERIAL_DATA_CONVERTER_REFERENCE_MODEL
