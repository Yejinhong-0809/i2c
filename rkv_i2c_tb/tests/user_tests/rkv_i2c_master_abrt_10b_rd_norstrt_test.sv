`ifndef RKV_I2C_MASTER_ABRT_10B_RD_NORSTRT_TEST_SV
`define RKV_I2C_MASTER_ABRT_10B_RD_NORSTRT_TEST_SV

class rkv_i2c_master_abrt_10b_rd_norstrt_test extends rkv_i2c_pkg::rkv_i2c_base_test;
  `uvm_component_utils(rkv_i2c_master_abrt_10b_rd_norstrt_test)
  
  function new(string name = "rkv_i2c_master_abrt_10b_rd_norstrt_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
/*  	cfg.i2c_cfg.slave_cfg[0].enable_10bit_addr = 1;   
	env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]);	 */ 
  endfunction
  
  task run_top_virtual_sequence();
    rkv_i2c_master_abrt_10b_rd_norstrt_virt_seq seq = new();
    seq.start(env.sqr);
  endtask
  
endclass

`endif
