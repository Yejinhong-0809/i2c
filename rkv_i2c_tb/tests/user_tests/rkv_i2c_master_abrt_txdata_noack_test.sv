`ifndef RKV_I2C_MASTER_ABRT_TXDATA_NOACK_VIRT_TEST
`define RKV_I2C_MASTER_ABRT_TXDATA_NOACK_VIRT_TEST

class rkv_i2c_master_abrt_txdata_noack_test extends rkv_i2c_base_test;
  `uvm_component_utils(rkv_i2c_master_abrt_txdata_noack_test)
  
  function new(string name = "rkv_i2c_master_abrt_txdata_noack_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_top_virtual_sequence();
    rkv_i2c_master_abrt_txdata_noack_virt_seq seq = new();
    seq.start(env.sqr);
  endtask 
endclass

`endif