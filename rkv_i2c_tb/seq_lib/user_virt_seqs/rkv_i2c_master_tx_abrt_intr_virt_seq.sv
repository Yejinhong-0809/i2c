`ifndef   RKV_I2C_MASTER_TX_ABRT_INTR_VIRT_SEQ_SV
`define   RKV_I2C_MASTER_TX_ABRT_INTR_VIRT_SEQ_SV

class rkv_i2c_master_tx_abrt_intr_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_tx_abrt_intr_virt_seq)
  
  function new(string name = "rkv_i2c_master_tx_abrt_intr_virt_seq" );
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
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } ) 
    rgm.IC_ENABLE.mirror(status);
    fork  
      `uvm_do_on_with( apb_write_packet_seq, 
                       p_sequencer.apb_mst_sqr, 
                      {
                        packet.size() == 8;
                        packet[0] == 8'b1000_0000;
                        packet[1] == 8'b1000_0001;
                        packet[2] == 8'b1000_0010;
                        packet[3] == 8'b1000_0011;
                        packet[4] == 8'b1000_0100;
                        packet[5] == 8'b1000_0101;
                        packet[6] == 8'b1000_0110;
                        packet[7] == 8'b1000_0111;                      
                      })
      `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join_none
    
    #100us;
    rgm.IC_ENABLE.ABORT.set(1);
    rgm.IC_ENABLE.update(status);    
    rgm.IC_ENABLE.mirror(status);
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_ABRT_INTR_ID; })
    rgm.IC_ENABLE.mirror(status);
    if(vif.intr[IC_TX_ABRT_INTR_ID] == 1)  
      `uvm_info(get_type_name(), "tx_abrt interrupt signal is high", UVM_HIGH)
    rgm.IC_TX_ABRT_SOURCE.mirror(status);
    rgm.IC_ENABLE.mirror(status);
    `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_ABRT_INTR_ID; })
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
  endtask
endclass

`endif
