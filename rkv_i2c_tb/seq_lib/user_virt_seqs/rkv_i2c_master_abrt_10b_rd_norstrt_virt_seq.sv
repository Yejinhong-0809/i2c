`ifndef RKV_I2C_MASTER_ABRT_10B_RD_NORSTRT_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ABRT_10B_RD_NORSTRT_VIRT_SEQ_SV

class rkv_i2c_master_abrt_10b_rd_norstrt_virt_seq extends rkv_i2c_pkg::rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  rkv_user_wait_detect_abort_source_seq   user_wait_detect_abort_source_seq;
  
  `uvm_object_utils(rkv_i2c_master_abrt_10b_rd_norstrt_virt_seq)
  
  function new(string name = "rkv_i2c_master_abrt_10b_rd_norstrt_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    p_sequencer.cfg.i2c_cfg.slave_cfg[0].enable_10bit_addr = 1;
	  env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]); //为什么配置对env的重新配置放在virt_seq而不是放在test里面
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                     {
                       SPEED == 2;
                       IC_10BITADDR_MASTER == 1;
                       IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                       IC_FS_SCL_HCNT == 200;
                       IC_FS_SCL_LCNT == 200;
                       IC_RESTART_EN  ==  0;
                       ENABLE == 1;                       
                      })
     fork
       `uvm_do_on_with( i2c_slv_read_resp_seq, 
                        p_sequencer.i2c_slv_sqr,
                       {
                         packet.size() == 1;
                         packet[0] == 'b0001_0001;
                        })
     join_none
     
     `uvm_do_on_with( apb_read_packet_seq, 
                      p_sequencer.apb_mst_sqr,
                     {
                        packet.size() == 1;
                     })
     //`uvm_do_on_with( apb_intr_wait_seq, p_sequencer.apb_mst_sqr, {intr_id == IC_TX_ABRT_INTR_ID;})
     
     `uvm_do_on(user_wait_detect_abort_source_seq, p_sequencer.apb_mst_sqr)
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask
endclass

`endif