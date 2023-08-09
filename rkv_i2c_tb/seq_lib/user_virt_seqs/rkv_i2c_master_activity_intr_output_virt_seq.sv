`ifndef RKV_I2C_MASTER_ACTIVITY_INTR_OUTPUT_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ACTIVITY_INTR_OUTPUT_VIRT_SEQ_SV

class rkv_i2c_master_activity_intr_output_virt_seq extends rkv_i2c_pkg::rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_activity_intr_output_virt_seq)
  
  function new(string name = "rkv_i2c_master_activity_intr_output_virt_seq");
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
      
    rgm.IC_INTR_MASK.M_ACTIVITY.set('b1);
    rgm.IC_INTR_MASK.M_START_DET.set('b1);
    rgm.IC_INTR_MASK.M_STOP_DET.set('b1);
    rgm.IC_INTR_MASK.update(status);
    
    fork
      `uvm_do_on_with(  i2c_slv_write_resp_seq, 
                        p_sequencer.i2c_slv_sqr,
                       {
                         nack_addr == 0;
                         nack_data == 0;
                         nack_addr_count == 0;   
                        })
    join_none
    
    `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                    { 
                      packet.size() == 2;
                      packet[0] == 'b1100_0000;
                      packet[1] == 'b1100_0001;
                    })
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_ACTIVITY_INTR_ID; })
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_START_DET_INTR_ID; })
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_STOP_DET_INTR_ID; })
    
    if(vif.intr[IC_ACTIVITY_INTR_ID]==1 && vif.intr[IC_START_DET_INTR_ID]==1 && vif.intr[IC_STOP_DET_INTR_ID]==1)
    `uvm_info(get_type_name(), "activity/start_det/stop_det interrupt are arise", UVM_LOW)
    
    `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_ACTIVITY_INTR_ID; })
    `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_START_DET_INTR_ID; })
    `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_STOP_DET_INTR_ID; })    
    
    rgm.IC_RAW_INTR_STAT.mirror(status);
    if(vif.intr[IC_ACTIVITY_INTR_ID]==0 && vif.intr[IC_START_DET_INTR_ID]==0 && vif.intr[IC_STOP_DET_INTR_ID]==0)
    `uvm_info(get_type_name(), "activity/start_det/stop_det interrupt have been clear", UVM_LOW)   
    
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
  endtask
endclass
`endif
