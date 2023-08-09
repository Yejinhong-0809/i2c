`ifndef   RKV_I2C_MASTER_TX_EMPTY_INTR_VIRT_SEQ_SV
`define   RKV_I2C_MASTER_TX_EMPTY_INTR_VIRT_SEQ_SV

class rkv_i2c_master_tx_empty_intr_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_tx_empty_intr_virt_seq)  
  
  function new(string name = "rkv_i2c_master_tx_empty_intr_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 2;       
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_FS_SCL_HCNT == 200;
                      IC_FS_SCL_LCNT == 200;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 1;
                      ENABLE == 1;
                    } )
    `uvm_do_on_with( apb_write_packet_seq, 
                     p_sequencer.apb_mst_sqr, 
                    {
                        packet.size() == 1;
                        packet[0] == 8'b1010_1010;                      
                    })
    fork
      `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join_none
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_EMPTY_INTR_ID; })
    if(vif.intr[IC_TX_EMPTY_INTR_ID] != 1)
      `uvm_error(get_type_name(), "Error:IC_TX_EMPTY interrupt is low")
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
  endtask
endclass
    
`endif
