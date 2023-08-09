`ifndef RKV_I2C_MASTER_ABRT_7B_ADDR_NOACK_VIRT_TEST_SV
`define RKV_I2C_MASTER_ABRT_7B_ADDR_NOACK_VIRT_TEST_SV

class rkv_i2c_master_abrt_7b_addr_noack_test extends rkv_i2c_base_test;
  `uvm_component_utils(rkv_i2c_master_abrt_7b_addr_noack_test)
  
  function new(string name = "rkv_i2c_master_abrt_7b_addr_noack_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_top_virtual_sequence();
    rkv_i2c_master_abrt_7b_addr_noack_virt_seq seq = new();
    seq.start(env.sqr);
  endtask
endclass
`endif
