`ifndef   RKV_I2C_MASTER_SS_CNT_VIRT_SEQ_SV
`define   RKV_I2C_MASTER_SS_CNT_VIRT_SEQ_SV

class rkv_i2c_master_ss_cnt_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_ss_cnt_virt_seq)
  
function new(string name = "rkv_i2c_master_ss_cnt_virt_seq");
  super.new(name);
endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    rgm.IC_FS_SPKLEN.mirror(status);  //default value is 0x5
    
    //IC_SS_SCL_HCNT default value is 0x190---400    IC_SS_SCL_LCNT default value is 0X1d6---470
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 1;       
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } ) 
    fork
      `uvm_do_on_with( apb_write_packet_seq, 
                       p_sequencer.apb_mst_sqr, 
                      {
                        packet.size() == 1;
                        packet[0] == 8'b1010_1010;
                      })
      `uvm_do_on( i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_SS_SCL_HCNT.IC_SS_SCL_HCNT.set(500);
    rgm.IC_SS_SCL_LCNT.IC_SS_SCL_LCNT.set(500);
    rgm.IC_SS_SCL_HCNT.update(status);
    rgm.IC_SS_SCL_LCNT.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 1;       
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } ) 
    fork
      `uvm_do_on_with( apb_write_packet_seq, 
                       p_sequencer.apb_mst_sqr, 
                      {
                        packet.size() == 1;
                        packet[0] == 8'b1010_1010;
                      })
      `uvm_do_on( i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_SS_SCL_HCNT.IC_SS_SCL_HCNT.set(1000);
    rgm.IC_SS_SCL_LCNT.IC_SS_SCL_LCNT.set(1000);
    rgm.IC_SS_SCL_HCNT.update(status);
    rgm.IC_SS_SCL_LCNT.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 1;       
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } ) 
    fork
      `uvm_do_on_with( apb_write_packet_seq, 
                       p_sequencer.apb_mst_sqr, 
                      {
                        packet.size() == 1;
                        packet[0] == 8'b1010_1010;
                      })
      `uvm_do_on( i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;  
  endtask
endclass
`endif