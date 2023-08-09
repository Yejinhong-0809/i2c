`ifndef RKV_I2C_MASTER_ABRT_TXDATA_NOACK_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ABRT_TXDATA_NOACK_VIRT_SEQ_SV

class rkv_i2c_master_abrt_txdata_noack_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_abrt_txdata_noack_virt_seq)
  
  function new(string name = "rkv_i2c_master_abrt_txdata_noack_virt_seq");
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
                        TX_EMPTY_CTRL  == 0;
                        ENABLE == 1;
                     })
    fork
      `uvm_do_on_with(  i2c_slv_write_resp_seq, 
                        p_sequencer.i2c_slv_sqr,
                       {
                         nack_addr == 0;
                         nack_data == 1;
                         nack_addr_count == 0;   
                        })
    join_none
    
    `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                    { 
                      packet.size() == 2;
                      packet[0] == 'b1100_0000;
                      packet[1] == 'b1100_0001;
                    })
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_ABRT_INTR_ID; })
    
    if(vif.intr[IC_TX_ABRT_INTR_ID] == 1)   `uvm_info(get_type_name(), "tx_abrt interupt signal is rise", UVM_LOW)
      
    rgm.IC_TX_ABRT_SOURCE.mirror(status);
    
    `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, {intr_id == IC_TX_ABRT_INTR_ID;})
    if(vif.intr[IC_TX_ABRT_INTR_ID] == 0)   `uvm_info(get_type_name(), "tx_abrt interupt signal has been clear", UVM_LOW) 
    
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    
    #10us
    `uvm_info(get_type_name(), "=====================FINISH=====================", UVM_LOW)    
  endtask
endclass

`endif