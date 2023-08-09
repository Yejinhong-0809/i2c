`ifndef RKV_I2C_MASTER_FS_CNT_VIRT_SEQ_SV
`define RKV_I2C_MASTER_FS_CNT_VIRT_SEQ_SV

class rkv_i2c_master_fs_cnt_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_fs_cnt_virt_seq)
  
  function new(string name = "rkv_i2c_master_fs_cnt_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    //cfg.i2c_cfg.slave_cfg[0].bus_speed = lvc_i2c_pkg::FAST_MODE;  //no these codes are not influent for simulation
    //env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]);
    
    rgm.IC_FS_SPKLEN.mirror(status);
    rgm.IC_HS_SPKLEN.mirror(status);
    
    rgm.IC_FS_SPKLEN.IC_FS_SPKLEN.set(0);
    rgm.IC_FS_SPKLEN.update(status);
    rgm.IC_FS_SPKLEN.mirror(status); //min value is 1 even if we set 0, this value is related to real the time of SCL HIGH Cycle
    rgm.IC_HS_SPKLEN.IC_HS_SPKLEN.set(0);
    rgm.IC_HS_SPKLEN.update(status);
    rgm.IC_HS_SPKLEN.mirror(status);
    //IC_FS_SCL_HCNT default value is 0x3c---60   IC_FS_SCL_LCNT default value is 0x82---130
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 2;
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } )     
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;
     
     //400KHz == 400 Kb/s
     rgm.IC_ENABLE.ENABLE.set(0);
     rgm.IC_ENABLE.update(status);
     rgm.IC_FS_SCL_HCNT.IC_FS_SCL_HCNT.set(125);
     rgm.IC_FS_SCL_HCNT.update(status);
     rgm.IC_FS_SCL_LCNT.IC_FS_SCL_LCNT.set(125);
     rgm.IC_FS_SCL_LCNT.update(status);
     rgm.IC_ENABLE.ENABLE.set(1);
     rgm.IC_ENABLE.update(status);     
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;

     //100KHz == 100 Kb/s
     rgm.IC_ENABLE.ENABLE.set(0);
     rgm.IC_ENABLE.update(status);
     rgm.IC_FS_SCL_HCNT.IC_FS_SCL_HCNT.set(500);
     rgm.IC_FS_SCL_HCNT.update(status);
     rgm.IC_FS_SCL_LCNT.IC_FS_SCL_LCNT.set(500);
     rgm.IC_FS_SCL_LCNT.update(status);
     rgm.IC_ENABLE.ENABLE.set(1);
     rgm.IC_ENABLE.update(status);     
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;
  endtask
endclass

`endif
